import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/api_config.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/language_picker.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.initialLanguage = 'auto'});

  final String initialLanguage;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _api = ApiService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <ChatMessage>[];
  bool _isSending = false;
  bool? _apiHealthy;
  PlatformFile? _attachedFile;
  String _language = 'auto';

  static const _suggestions = [
    ('What is an FIR?', Icons.description_outlined),
    ('What are my rights after arrest?', Icons.shield_outlined),
    ('How can I apply for bail?', Icons.account_balance_outlined),
    ('What is Section 302 PPC?', Icons.gavel_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _checkApiHealth();
  }

  Future<void> _checkApiHealth() async {
    try {
      final ok = await _api.checkHealth();
      if (mounted) setState(() => _apiHealthy = ok);
    } catch (_) {
      if (mounted) setState(() => _apiHealthy = false);
    }
  }

  Future<void> _pickDocument() async {
    if (_isSending) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'txt'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    if (file.bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read file. Try again.')),
        );
      }
      return;
    }
    setState(() => _attachedFile = file);
  }

  void _clearAttachment() {
    setState(() => _attachedFile = null);
  }

  Future<void> _sendMessage([String? preset]) async {
    final text = (preset ?? _controller.text).trim();
    final file = _attachedFile;

    if (_isSending) return;
    if (text.isEmpty && file == null) return;

    final userId = '${DateTime.now().millisecondsSinceEpoch}_user';
    final loadingId = '${DateTime.now().millisecondsSinceEpoch}_loading';
    final answerId = '${DateTime.now().millisecondsSinceEpoch}_answer';

    final userDisplayText = text.isNotEmpty
        ? text
        : (file != null ? 'Analyze this document' : '');

    setState(() {
      _isSending = true;
      _messages.add(
        ChatMessage(
          id: userId,
          role: MessageRole.user,
          text: userDisplayText,
          attachmentName: file?.name,
        ),
      );
      _messages.add(
        ChatMessage(
          id: loadingId,
          role: MessageRole.assistant,
          text: '',
          isLoading: true,
        ),
      );
      _controller.clear();
      _attachedFile = null;
    });
    _scrollToBottom();

    try {
      final response = file != null
          ? await _api.analyzeDocument(
              bytes: file.bytes!,
              filename: file.name,
              question: text.isEmpty ? null : text,
              language: _language,
            )
          : await _api.ask(text, language: _language);

      if (!mounted) return;
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == loadingId);
        if (idx != -1) {
          _messages[idx] = ChatMessage(
            id: answerId,
            role: MessageRole.assistant,
            text: response.answer,
            sources: List.from(response.sources),
            disclaimer: response.disclaimer,
          );
        }
        _isSending = false;
        _apiHealthy = true;
      });
    } on ApiException catch (e) {
      _replaceLoadingWithError(loadingId, e.message);
    } catch (e) {
      _replaceLoadingWithError(
        loadingId,
        'Could not reach the server.\n\n'
        'Backend URL: ${ApiConfig.baseUrl}\n\n'
        'Start backend: uvicorn main:app --host 0.0.0.0 --port 8000',
      );
    }

    _scrollToBottom();
  }

  void _replaceLoadingWithError(String loadingId, String error) {
    if (!mounted) return;
    setState(() {
      final idx = _messages.indexWhere((m) => m.id == loadingId);
      if (idx != -1) {
        _messages[idx] = ChatMessage(
          id: '${loadingId}_error',
          role: MessageRole.error,
          text: error,
        );
      }
      _isSending = false;
      _apiHealthy = false;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  bool get _canSend =>
      !_isSending && (_controller.text.trim().isNotEmpty || _attachedFile != null);

  @override
  void dispose() {
    _api.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_apiHealthy == false) _buildOfflineBanner(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  key: ValueKey(message.id),
                  message: message,
                );
              },
            ),
          ),
          if (_messages.isEmpty) _buildSuggestions(),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded),
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textDark,
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.balance_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Court Companion',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'AI Legal Assistant',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        _buildLanguageSelector(),
        Tooltip(
          message: ApiConfig.baseUrl,
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _ApiStatusBadge(healthy: _apiHealthy),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Center(
        child: LanguagePicker(
          value: _language,
          onChanged: (value) => setState(() => _language = value),
        ),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Material(
      color: AppColors.error.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.cloud_off_rounded, size: 18, color: AppColors.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Backend offline — start the API server to get answers',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Try asking',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Or attach a PDF/TXT with the clip button below',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((item) {
              final (q, icon) = item;
              return Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  onTap: _isSending ? null : () => _sendMessage(q),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 16, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Text(
                          q,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_attachedFile != null) _buildAttachmentChip(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: _isSending ? null : _pickDocument,
                  tooltip: 'Attach PDF or TXT',
                  icon: Icon(
                    Icons.attach_file_rounded,
                    color: _attachedFile != null
                        ? AppColors.accent
                        : AppColors.muted,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) {
                      if (_canSend) _sendMessage();
                    },
                    onChanged: (_) => setState(() {}),
                    style: GoogleFonts.inter(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: _attachedFile != null
                          ? 'Optional question about your document...'
                          : 'Ask in English, Urdu, Pashto, Punjabi, Sindhi...',
                      prefixIcon: Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: AppColors.muted.withValues(alpha: 0.7),
                        size: 20,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton.filled(
                  onPressed: _canSend ? () => _sendMessage() : null,
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.arrow_upward_rounded),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(50, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentChip() {
    final file = _attachedFile!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentSoft.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.insert_drive_file_rounded,
                  size: 16, color: AppColors.secondary),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.55,
                ),
                child: Text(
                  file.name,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: _isSending ? null : _clearAttachment,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded, size: 16, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApiStatusBadge extends StatelessWidget {
  const _ApiStatusBadge({required this.healthy});

  final bool? healthy;

  @override
  Widget build(BuildContext context) {
    if (healthy == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.muted.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Connecting',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      );
    }

    final online = healthy == true;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: online
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: online
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: online ? AppColors.success : AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            online ? 'Online' : 'Offline',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: online ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
