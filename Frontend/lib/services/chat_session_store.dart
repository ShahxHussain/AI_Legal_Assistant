import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message.dart';

/// Local chat persistence on this device only.
class ChatSessionStore {
  static const _conversationKey = 'court_companion_conversation_id';
  static const _messagesKey = 'court_companion_messages';
  static const _titlesKey = 'court_companion_conversation_titles';
  static const _messagesPrefix = 'court_companion_msgs_';

  Future<String?> getConversationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_conversationKey);
  }

  Future<void> setConversationId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null || id.isEmpty) {
      await prefs.remove(_conversationKey);
    } else {
      await prefs.setString(_conversationKey, id);
    }
  }

  Future<List<ChatMessage>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_messagesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return [
        for (final item in list)
          ChatMessage.fromJson(item as Map<String, dynamic>),
      ];
    } catch (_) {
      return [];
    }
  }

  Future<void> saveMessages(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final visible = messages.where((m) => !m.isLoading).toList();
    final encoded = jsonEncode(visible.map((m) => m.toJson()).toList());
    await prefs.setString(_messagesKey, encoded);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_conversationKey);
    await prefs.remove(_messagesKey);
  }

  Future<Map<String, String>> loadTitles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_titlesKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }

  Future<void> setTitle(String conversationId, String title) async {
    if (conversationId.isEmpty || title.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final titles = await loadTitles();
    titles[conversationId] = _truncateTitle(title);
    await prefs.setString(_titlesKey, jsonEncode(titles));
  }

  Future<void> saveMessagesFor(String conversationId, List<ChatMessage> messages) async {
    if (conversationId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final visible = messages.where((m) => !m.isLoading).toList();
    final encoded = jsonEncode(visible.map((m) => m.toJson()).toList());
    await prefs.setString('$_messagesPrefix$conversationId', encoded);
  }

  Future<List<ChatMessage>> loadMessagesFor(String conversationId) async {
    if (conversationId.isEmpty) return [];
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_messagesPrefix$conversationId');
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return [
        for (final item in list)
          ChatMessage.fromJson(item as Map<String, dynamic>),
      ];
    } catch (_) {
      return [];
    }
  }

  static String _truncateTitle(String text) {
    final clean = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.length <= 42) return clean;
    return '${clean.substring(0, 42)}…';
  }
}
