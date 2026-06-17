import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/conversation_summary.dart';
import '../theme/app_theme.dart';

class ChatHistorySidebar extends StatelessWidget {
  const ChatHistorySidebar({
    super.key,
    required this.conversations,
    required this.onNewChat,
    required this.onSelect,
    required this.onDelete,
    required this.onClose,
    this.loading = false,
    this.compact = false,
  });

  final List<ConversationSummary> conversations;
  final bool loading;
  final bool compact;
  final VoidCallback onNewChat;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onDelete;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 72 : 280,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.border.withValues(alpha: 0.9)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(compact ? 10 : 14, 14, compact ? 10 : 8, 10),
            child: Row(
              children: [
                if (!compact) ...[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.balance_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Court Companion',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                IconButton(
                  tooltip: 'Close sidebar',
                  onPressed: onClose,
                  icon: Icon(
                    compact ? Icons.chevron_right_rounded : Icons.menu_open_rounded,
                    size: 22,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppColors.muted,
                    minimumSize: const Size(40, 40),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
            child: Material(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: onNewChat,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 0 : 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        compact ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.add_rounded,
                        size: 20,
                        color: AppColors.secondary,
                      ),
                      if (!compact) ...[
                        const SizedBox(width: 10),
                        Text(
                          'نئی گفتگو · New chat',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!compact) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Text(
                'Recent',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            Expanded(
              child: loading
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : conversations.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'No chats yet.\nStart a new conversation.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.muted,
                                height: 1.45,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            final item = conversations[index];
                            return _HistoryTile(
                              item: item,
                              onTap: () => onSelect(item.id),
                              onDelete: () => onDelete(item.id),
                            );
                          },
                        ),
            ),
          ] else
            const Spacer(),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatefulWidget {
  const _HistoryTile({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  final ConversationSummary item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  State<_HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends State<_HistoryTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.item.isActive;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          color: active
              ? AppColors.accentSoft.withValues(alpha: 0.55)
              : (_hovered ? AppColors.background : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 16,
                    color: active ? AppColors.secondary : AppColors.muted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  if (_hovered || active)
                    IconButton(
                      tooltip: 'Delete chat',
                      onPressed: widget.onDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.muted,
                        minimumSize: const Size(32, 32),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
