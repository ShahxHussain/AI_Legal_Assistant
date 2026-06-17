import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../config/api_config.dart';
import '../models/chat_message.dart';
import '../models/conversation_summary.dart';
import '../services/api_service.dart';
import '../services/assistant_stream.dart';
import '../services/chat_session_store.dart';
import '../services/device_identity.dart';
import '../theme/app_theme.dart';
import '../widgets/api_status_badge.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_history_sidebar.dart';
import '../widgets/language_picker.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.initialLanguage = kDefaultLanguage});

  final String initialLanguage;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _api = ApiService();
  final _session = ChatSessionStore();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <ChatMessage>[];
  final _conversations = <ConversationSummary>[];

  bool _isSending = false;
  bool _loadingHistory = true;
  bool _loadingConversations = false;
  bool _sidebarOpen = true;
  bool _sidebarInitialized = false;
  bool? _apiHealthy;
  PlatformFile? _attachedFile;
  String _language = kDefaultLanguage;
  String? _deviceId;
  String? _conversationId;

  static const _suggestions = [
    ('What is an FIR?', Icons.description_outlined),
    ('What are my rights after arrest?', Icons.shield_outlined),
    ('How can I apply for bail?', Icons.account_balance_outlined),
    ('What is Section 302 PPC?', Icons.gavel_outlined),
  ];

  static const _sidebarBreakpoint = 900.0;

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _checkApiHealth();
    _loadSession();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_sidebarInitialized) {
      _sidebarOpen = MediaQuery.sizeOf(context).width >= _sidebarBreakpoint;
      _sidebarInitialized = true;
    }
  }

  bool get _isWide => MediaQuery.sizeOf(context).width >= _sidebarBreakpoint;

  Future<String> _ensureDeviceId() async {
    if (_deviceId != null && _deviceId!.isNotEmpty) return _deviceId!;
    _deviceId = await DeviceIdentity.ensureDeviceId();
    return _deviceId!;
  }

  Future<void> _loadSession() async {
    await _ensureDeviceId();
    // Opening chat from home always starts fresh; use sidebar for past chats.
    await _session.clearAll();
    if (mounted) {
      setState(() {
        _messages.clear();
        _conversationId = null;
        _loadingHistory = false;
      });
    }

    try {
      await _loadConversationList();
    } catch (_) {
      // Sidebar may be empty offline.
    }
  }

  Future<void> _loadConversationList() async {
    if (_deviceId == null) return;
    setState(() => _loadingConversations = true);
    try {
      final list = await _api.listConversations(_deviceId!);
      final titles = await _session.loadTitles();
      if (!mounted) return;
      setState(() {
        _conversations
          ..clear()
          ..addAll([
            for (final row in list)
              ConversationSummary.fromApi(
                row,
                titleOverride: titles[row['id'] as String],
                isActive: row['id'] == _conversationId,
              ),
          ]);
        _loadingConversations = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingConversations = false);
    }
  }

  Future<void> _syncFromServer(String conversationId) async {
    if (_deviceId == null) return;
    final data = await _api.getConversation(
      conversationId: conversationId,
      deviceId: _deviceId!,
    );
    final rows = data['messages'] as List<dynamic>? ?? [];
    final loaded = [
      for (final row in rows)
        ChatMessage.fromJson(row as Map<String, dynamic>),
    ];
    if (!mounted || loaded.isEmpty) return;
    setState(() {
      _messages
        ..clear()
        ..addAll(loaded);
      _conversationId = conversationId;
    });
    await _persistLocal();
    await _ensureConversationTitle();
    _scrollToBottom();
  }

  Future<void> _submitFeedback(ChatMessage message, String rating) async {
    if (_deviceId == null || !message.canReceiveFeedback) return;
    if (message.feedbackRating == rating) return;

    try {
      await _api.submitFeedback(
        messageId: message.id,
        deviceId: _deviceId!,
        rating: rating,
        conversationId: _conversationId,
        language: _language,
      );
      if (!mounted) return;
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == message.id);
        if (idx != -1) {
          _messages[idx] = _messages[idx].copyWith(feedbackRating: rating);
        }
      });
      await _persistLocal();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save feedback. Try again when online.'),
        ),
      );
    }
  }

  Future<void> _persistLocal() async {
    await _session.saveMessages(_messages);
    await _session.setConversationId(_conversationId);
    if (_conversationId != null) {
      await _session.saveMessagesFor(_conversationId!, _messages);
    }
  }

  Future<void> _ensureConversationTitle() async {
    if (_conversationId == null) return;
    final titles = await _session.loadTitles();
    if (titles.containsKey(_conversationId)) return;
    ChatMessage? firstUser;
    for (final message in _messages) {
      if (message.role == MessageRole.user && message.text.trim().isNotEmpty) {
        firstUser = message;
        break;
      }
    }
    if (firstUser == null) return;
    await _session.setTitle(_conversationId!, firstUser.text);
    await _loadConversationList();
  }

  Future<void> _openConversation(String id) async {
    if (_isSending || id == _conversationId) {
      _closeSidebarOverlay();
      return;
    }

    if (_conversationId != null && _messages.isNotEmpty) {
      await _session.saveMessagesFor(_conversationId!, _messages);
    }

    setState(() {
      _loadingHistory = true;
      _conversationId = id;
      _messages.clear();
    });

    final local = await _session.loadMessagesFor(id);
    if (mounted) {
      setState(() {
        _messages.addAll(local);
        _loadingHistory = false;
      });
      if (_messages.isNotEmpty) _scrollToBottom();
    }

    await _session.setConversationId(id);
    try {
      await _syncFromServer(id);
    } catch (_) {}
    await _loadConversationList();
    _closeSidebarOverlay();
  }

  Future<void> _startNewChat() async {
    if (_isSending) return;

    if (_conversationId != null && _messages.isNotEmpty) {
      await _session.saveMessagesFor(_conversationId!, _messages);
    }

    setState(() {
      _messages.clear();
      _conversationId = null;
    });
    await _session.clearAll();
    await _loadConversationList();
    _closeSidebarOverlay();
  }

  Future<void> _deleteConversationById(String id) async {
    if (_deviceId == null) return;
    try {
      await _api.deleteConversation(
        conversationId: id,
        deviceId: _deviceId!,
      );
    } catch (_) {}

    if (_conversationId == id) {
      setState(() {
        _messages.clear();
        _conversationId = null;
      });
      await _session.clearAll();
    }
    await _loadConversationList();
  }

  void _toggleSidebar() {
    if (_isWide) {
      setState(() => _sidebarOpen = !_sidebarOpen);
      return;
    }
    _scaffoldKey.currentState?.openDrawer();
  }

  void _closeSidebarOverlay() {
    if (_isWide) return;
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
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

    await _ensureDeviceId();

    const uuid = Uuid();
    final userId = uuid.v4();
    final loadingId = '${uuid.v4()}_loading';
    final answerId = uuid.v4();

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
      if (file != null) {
        final response = await _api.analyzeDocument(
          bytes: file.bytes!,
          filename: file.name,
          question: text.isEmpty ? null : text,
          language: _language,
        );

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
        await _persistLocal();
        await _ensureConversationTitle();
      } else {
        await _streamAnswer(text, loadingId, answerId, userId);
      }
    } on ApiException catch (e) {
      _replaceLoadingWithError(loadingId, answerId, e.message);
    } catch (e) {
      _replaceLoadingWithError(
        loadingId,
        answerId,
        'Could not reach the server.\n\n'
        'Backend URL: ${ApiConfig.baseUrl}\n\n'
        'Start backend: uvicorn main:app --host 0.0.0.0 --port 8000',
      );
    }

    _scrollToBottom();
  }

  Future<void> _streamAnswer(
    String text,
    String loadingId,
    String answerId,
    String userId,
  ) async {
    final result = await streamAssistantAnswer(
      _api,
      question: text,
      language: _language,
      deviceId: _deviceId,
      conversationId: _conversationId,
      onConversationId: (id) {
        if (id == null || !mounted) return;
        setState(() => _conversationId = id);
      },
      onPartial: (partial) {
        if (!mounted) return;
        setState(() {
          final idx = _messages.indexWhere(
            (m) => m.id == loadingId || m.id == answerId,
          );
          if (idx != -1) {
            _messages[idx] = ChatMessage(
              id: answerId,
              role: MessageRole.assistant,
              text: partial,
              isLoading: true,
            );
          }
        });
        _scrollToBottom();
      },
    );

    if (!mounted) return;
    setState(() {
      if (result.userMessageId != null) {
        final uIdx = _messages.indexWhere((m) => m.id == userId);
        if (uIdx != -1) {
          _messages[uIdx] = _messages[uIdx].copyWith(id: result.userMessageId!);
        }
      }
      final idx = _messages.indexWhere(
        (m) => m.id == loadingId || m.id == answerId,
      );
      if (idx != -1) {
        _messages[idx] = ChatMessage(
          id: result.assistantMessageId ?? answerId,
          role: MessageRole.assistant,
          text: result.answer,
          sources: List.from(result.sources),
          disclaimer: result.disclaimer,
          isLoading: false,
        );
      }
      _conversationId = result.conversationId ?? _conversationId;
      _isSending = false;
      _apiHealthy = true;
    });
    await _persistLocal();
    if (_conversationId != null) {
      await _session.setTitle(_conversationId!, text);
    }
    await _loadConversationList();
  }

  void _replaceLoadingWithError(
    String loadingId,
    String answerId,
    String error,
  ) {
    if (!mounted) return;
    setState(() {
      final idx = _messages.indexWhere(
        (m) => m.id == loadingId || m.id == answerId,
      );
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

  String get _activeTitle => 'Court Companion';

  Widget _buildSidebar({bool compact = false}) {
    return ChatHistorySidebar(
      compact: compact,
      conversations: _conversations,
      loading: _loadingConversations,
      onNewChat: _startNewChat,
      onSelect: _openConversation,
      onDelete: _deleteConversationById,
      onClose: () {
        if (_isWide) {
          setState(() => _sidebarOpen = false);
        } else {
          Navigator.of(context).pop();
        }
      },
    );
  }

  Future<void> _flushActiveSession() async {
    if (_conversationId != null && _messages.isNotEmpty) {
      await _session.saveMessagesFor(_conversationId!, _messages);
    }
    await _session.clearAll();
  }

  @override
  void dispose() {
    _flushActiveSession();
    _api.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showInlineSidebar = _isWide && _sidebarOpen;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _isWide
          ? null
          : Drawer(
              width: 280,
              backgroundColor: AppColors.surface,
              child: SafeArea(child: _buildSidebar()),
            ),
      body: Row(
        children: [
          if (showInlineSidebar) _buildSidebar(),
          Expanded(child: _buildMainPane()),
        ],
      ),
    );
  }

  Widget _buildMainPane() {
    return Column(
      children: [
        _buildTopBar(),
        if (_apiHealthy == false) _buildOfflineBanner(),
        Expanded(
          child: _loadingHistory
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return ChatBubble(
                      key: ValueKey(message.id),
                      message: message,
                      onFeedback: message.canReceiveFeedback
                          ? (rating) => _submitFeedback(message, rating)
                          : null,
                    );
                  },
                ),
        ),
        if (_messages.isEmpty) _buildSuggestions(),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              tooltip: _sidebarOpen ? 'Hide chat history' : 'Show chat history',
              onPressed: _toggleSidebar,
              icon: Icon(
                _sidebarOpen && _isWide
                    ? Icons.view_sidebar_outlined
                    : Icons.menu_rounded,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.textDark,
              ),
            ),
            IconButton(
              tooltip: 'Back to home',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.textDark,
              ),
            ),
            Expanded(
              child: Text(
                _activeTitle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textDark,
                ),
              ),
            ),
            LanguagePicker(
              compact: true,
              value: _language,
              onChanged: (value) => setState(() => _language = value),
            ),
            Tooltip(
              message: ApiConfig.baseUrl,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, left: 4),
                child: ApiStatusBadge(healthy: _apiHealthy),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.cloud_off_rounded, size: 18, color: AppColors.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Backend offline — could not reach ${ApiConfig.baseUrl}',
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
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.fromLTRB(6, 4, 12, 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isSending ? null : _pickDocument,
                              customBorder: const CircleBorder(),
                              child: Tooltip(
                                message: 'Attach PDF or TXT',
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: _attachedFile != null
                                        ? AppColors.accentSoft
                                        : AppColors.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.secondary
                                          .withValues(alpha: 0.30),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.attach_file_rounded,
                                    size: 20,
                                    color: _isSending
                                        ? AppColors.muted
                                        : AppColors.secondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
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
                                  : 'Ask in English, Urdu, Pashto, Punjabi...',
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                  child:
                      Icon(Icons.close_rounded, size: 16, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
