import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/api_config.dart';
import '../models/legal_source.dart';
import '../services/api_service.dart';
import '../services/assistant_stream.dart';
import '../services/chat_session_store.dart';
import '../services/device_identity.dart';
import '../services/voice_locales.dart';
import '../services/voice_service.dart';
import '../theme/app_theme.dart';
import '../widgets/api_status_badge.dart';
import '../widgets/formatted_message.dart';
import '../widgets/source_chips_row.dart';
import '../widgets/urdu_voice_help_sheet.dart';
import '../widgets/voice_language_picker.dart';

enum _VoicePhase { idle, listening, thinking, speaking }

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key, this.initialLanguage = kVoiceDefaultLanguage});

  final String initialLanguage;

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  final _api = ApiService();
  final _session = ChatSessionStore();
  final _voice = VoiceService();
  final _scrollController = ScrollController();

  String _language = kVoiceDefaultLanguage;
  String? _deviceId;
  String? _conversationId;
  _VoicePhase _phase = _VoicePhase.idle;
  bool? _apiHealthy;
  bool _voiceReady = false;
  String? _micHint;
  String _liveTranscript = '';
  String _userQuestion = '';
  String _answer = '';
  List<LegalSource> _sources = [];
  String? _disclaimer;
  String? _error;
  String _thinkingStatus = 'Searching legal sources…';

  @override
  void initState() {
    super.initState();
    _language = kVoiceEnabledLanguages.contains(widget.initialLanguage)
        ? widget.initialLanguage
        : kVoiceDefaultLanguage;
    _init();
  }

  @override
  void dispose() {
    _voice.stopListening();
    _voice.stopSpeaking();
    _api.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _deviceId = await DeviceIdentity.ensureDeviceId();
    _conversationId = await _session.getConversationId();
    await _checkApiHealth();
    await _initVoice(requestPermission: false);
  }

  Future<void> _checkApiHealth() async {
    try {
      final ok = await _api.checkHealth();
      if (mounted) setState(() => _apiHealthy = ok);
    } catch (_) {
      if (mounted) setState(() => _apiHealthy = false);
    }
  }

  Future<void> _initVoice({required bool requestPermission}) async {
    final result = await _voice.init(
      requestPermission: requestPermission,
      language: _language,
    );
    if (!mounted) return;
    setState(() {
      _voiceReady = result.sttReady;
      _micHint = result.sttReady ? null : result.hint;
    });
  }

  Future<void> _onVoiceLanguageChanged(String code) async {
    if (_phase == _VoicePhase.listening) {
      await _voice.stopListening();
    }
    await _voice.stopSpeaking();

    setState(() {
      _language = code;
      _phase = _VoicePhase.idle;
      _liveTranscript = '';
    });

    final result = await _voice.init(
      requestPermission: false,
      language: code,
    );
    if (!mounted) return;
    setState(() {
      _voiceReady = result.sttReady;
      _micHint = result.sttReady ? null : result.hint;
    });
  }

  bool get _busy =>
      _phase == _VoicePhase.thinking || _phase == _VoicePhase.speaking;

  String get _statusText {
    switch (_phase) {
      case _VoicePhase.listening:
        if (_liveTranscript.trim().isNotEmpty) {
          return 'Tap stop when you finish speaking';
        }
        return 'Speak now — pauses up to 15s are OK. Tap stop when finished';
      case _VoicePhase.thinking:
        return _thinkingStatus;
      case _VoicePhase.speaking:
        return 'Speaking as the answer arrives…';
      case _VoicePhase.idle:
        if (_voiceReady) {
          if (isUrduVoiceLanguage(_language)) {
            return 'اردو میں بولیں — مکمل ہونے پر روکیں بٹن دبائیں';
          }
          return 'Tap the microphone and ask your legal question';
        }
        return _micHint ??
            'Tap the microphone — allow access when prompted';
    }
  }

  Future<void> _onMicTap() async {
    if (_busy) {
      if (_phase == _VoicePhase.speaking) {
        await _voice.stopSpeaking();
        if (mounted) setState(() => _phase = _VoicePhase.idle);
      }
      return;
    }

    if (!_voiceReady) {
      await _initVoice(requestPermission: true);
      if (!_voiceReady) {
        if (mounted) {
          setState(() {
            _error = _micHint ??
                'Microphone not ready. Tap Retry below or check permissions.';
          });
        }
        return;
      }
    }

    if (_phase == _VoicePhase.listening) {
      await _voice.stopListening();
      final text = _liveTranscript.trim();
      if (text.isNotEmpty) {
        await _submitQuestion(text);
      } else if (mounted) {
        setState(() {
          _phase = _VoicePhase.idle;
          _error = 'No speech detected. Please try again.';
        });
      }
      return;
    }

    setState(() {
      _phase = _VoicePhase.listening;
      _liveTranscript = '';
      _error = null;
    });

    await _voice.startListening(
      onWords: (text, _) {
        if (!mounted) return;
        setState(() => _liveTranscript = text);
      },
    );
  }

  Future<void> _submitQuestion(String question) async {
    if (!mounted) return;

    _voice.resetStreamSpeech();

    setState(() {
      _phase = _VoicePhase.thinking;
      _userQuestion = question;
      _liveTranscript = '';
      _answer = '';
      _sources = [];
      _disclaimer = null;
      _error = null;
      _thinkingStatus = 'Searching legal sources…';
    });
    _scrollToBottom();

    try {
      final result = await streamAssistantAnswer(
        _api,
        question: question,
        language: _language,
        voiceMode: true,
        deviceId: _deviceId,
        conversationId: _conversationId,
        onConversationId: (id) {
          if (id == null) return;
          _conversationId = id;
        },
        onMeta: (sources, disclaimer) {
          if (!mounted) return;
          setState(() {
            _sources = sources;
            _disclaimer = disclaimer;
            _thinkingStatus = 'Generating answer…';
          });
        },
        onPartial: (partial) {
          if (!mounted) return;
          final startedSpeaking = _voice.feedStreamSpeech(partial);
          setState(() {
            _answer = partial;
            if (partial.isNotEmpty) {
              _thinkingStatus = 'Writing answer…';
            }
            if (startedSpeaking) {
              _phase = _VoicePhase.speaking;
            }
          });
          _scrollToBottom();
        },
      );

      if (!mounted) return;
      setState(() {
        _answer = result.answer;
        _sources = result.sources;
        _disclaimer = result.disclaimer;
        _conversationId = result.conversationId ?? _conversationId;
        _apiHealthy = true;
        if (_phase != _VoicePhase.speaking) {
          _phase = _VoicePhase.speaking;
        }
      });
      _scrollToBottom();

      if (result.conversationId != null) {
        await _session.setConversationId(result.conversationId);
      }

      try {
        await _voice.finishStreamSpeech(result.answer);
      } catch (_) {
        // Text answer is already on screen if TTS fails.
      }
      if (mounted) setState(() => _phase = _VoicePhase.idle);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _VoicePhase.idle;
        _error = e.message;
        _apiHealthy = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _phase = _VoicePhase.idle;
        _error =
            'Could not reach the server at ${ApiConfig.baseUrl}. Check your connection.';
        _apiHealthy = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.secondary,
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
            foregroundColor: AppColors.secondary,
            minimumSize: const Size(40, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        title: Text(
          'Voice Assistant',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          if (isUrduVoiceLanguage(_language))
            IconButton(
              tooltip: 'Urdu voice help',
              onPressed: () => UrduVoiceHelpSheet.show(context),
              icon: const Icon(
                Icons.info_outline_rounded,
                color: AppColors.secondary,
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                foregroundColor: AppColors.secondary,
                minimumSize: const Size(40, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          Center(
            child: VoiceLanguagePicker(
              compact: true,
              value: _language,
              onChanged: (v) => _onVoiceLanguageChanged(v),
            ),
          ),
          Tooltip(
            message: ApiConfig.baseUrl,
            child: Padding(
              padding: const EdgeInsets.only(right: 12, left: 8),
              child: Center(child: ApiStatusBadge(healthy: _apiHealthy)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          if (_apiHealthy == false) _buildOfflineBanner(),
          if (_apiHealthy != false && !_voiceReady && _micHint != null)
            _buildMicBanner(),
          Expanded(child: _buildContent()),
          _buildMicSection(),
        ],
      ),
    );
  }

  Widget _buildMicBanner() {
    return Material(
      color: AppColors.accentSoft.withValues(alpha: 0.55),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.mic_rounded, size: 18, color: AppColors.secondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _micHint!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textDark,
                  height: 1.4,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _initVoice(requestPermission: true),
              child: Text(
                'Retry',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Material(
      color: AppColors.error.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.cloud_off_rounded, size: 16, color: AppColors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Backend offline',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final hasContent =
        _userQuestion.isNotEmpty || _answer.isNotEmpty || _error != null;

    if (!hasContent) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.record_voice_over_rounded,
                size: 56,
                color: AppColors.secondary.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 20),
              Text(
                'Speak your legal question',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Same AI as chat — FIR, bail, PPC sections, arrest rights, and more.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'English & Urdu voice · Tap (i) for optional help',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      children: [
        if (_userQuestion.isNotEmpty) _buildUserCard(_userQuestion),
        if (_phase == _VoicePhase.listening && _liveTranscript.isNotEmpty)
          _buildListeningCard(_liveTranscript),
        if (_error != null) _buildErrorCard(_error!),
        if (_answer.isNotEmpty || _phase == _VoicePhase.thinking)
          _buildAnswerCard(),
        if (_sources.isNotEmpty) ...[
          const SizedBox(height: 12),
          SourceChipsRow(sources: _sources),
        ],
        if (_disclaimer != null && _disclaimer!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildDisclaimer(_disclaimer!),
        ],
      ],
    );
  }

  Widget _buildUserCard(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: AppColors.accentSoft.withValues(alpha: 0.65),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(6),
          ),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic_rounded, size: 16, color: AppColors.secondary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListeningCard(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: AppColors.muted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.balance_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Court Companion',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_phase == _VoicePhase.thinking && _answer.isEmpty)
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            FormattedMessage(text: _answer),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentSoft.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontStyle: FontStyle.italic,
          color: AppColors.muted,
        ),
      ),
    );
  }

  Widget _buildMicSection() {
    final listening = _phase == _VoicePhase.listening;
    final thinking = _phase == _VoicePhase.thinking;
    final speaking = _phase == _VoicePhase.speaking;

    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          children: [
            Text(
              _statusText,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.muted,
              ),
              textAlign: TextAlign.center,
            ),
            if (listening && _liveTranscript.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      _liveTranscript,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (thinking && _answer.isEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'This can take 20–40 seconds for legal questions.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: AppColors.muted,
                ),
              ),
            ],
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _onMicTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: listening ? 88 : 76,
                height: listening ? 88 : 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: listening
                      ? AppColors.error.withValues(alpha: 0.12)
                      : speaking
                          ? AppColors.accent.withValues(alpha: 0.15)
                          : AppColors.secondary,
                  border: Border.all(
                    color: listening
                        ? AppColors.error
                        : AppColors.secondary.withValues(alpha: 0.3),
                    width: listening ? 3 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(
                        alpha: listening ? 0.25 : 0.15,
                      ),
                      blurRadius: listening ? 20 : 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: thinking
                    ? const Padding(
                        padding: EdgeInsets.all(22),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        listening
                            ? Icons.stop_rounded
                            : speaking
                                ? Icons.volume_up_rounded
                                : Icons.mic_rounded,
                        color: listening || speaking
                            ? AppColors.secondary
                            : Colors.white,
                        size: 32,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
