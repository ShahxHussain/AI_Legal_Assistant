import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/ask_response.dart';
import 'device_identity.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String> _resolvedDeviceId(String? deviceId) async {
    if (deviceId != null && deviceId.isNotEmpty) return deviceId;
    return DeviceIdentity.ensureDeviceId();
  }

  Future<bool> checkHealth() async {
    try {
      final response = await _client
          .get(Uri.parse(ApiConfig.healthUrl))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return false;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['status'] == 'ok' || json['index_loaded'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Streams NDJSON events from POST /ask/stream:
  /// {"type":"meta"|"delta"|"done"|"error", ...}
  Stream<Map<String, dynamic>> askStream(
    String question, {
    String language = 'urdu_script',
    bool voiceMode = false,
    String? deviceId,
    String? conversationId,
  }) async* {
    final resolvedDeviceId = await _resolvedDeviceId(deviceId);
    final body = <String, dynamic>{
      'question': question,
      'language': language,
      'voice_mode': voiceMode,
      'device_id': resolvedDeviceId,
    };
    if (conversationId != null && conversationId.isNotEmpty) {
      body['conversation_id'] = conversationId;
    }

    final request = http.Request('POST', Uri.parse(ApiConfig.askStreamUrl))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode(body);

    final response =
        await _client.send(request).timeout(const Duration(seconds: 120));

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      String detail = 'Request failed (${response.statusCode})';
      try {
        final json = jsonDecode(body);
        if (json is Map<String, dynamic>) {
          detail = json['detail']?.toString() ?? detail;
        }
      } catch (_) {}
      throw ApiException(detail, statusCode: response.statusCode);
    }

    final lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lines) {
      if (line.trim().isEmpty) continue;
      yield jsonDecode(line) as Map<String, dynamic>;
    }
  }

  Future<AskResponse> ask(
    String question, {
    String language = 'urdu_script',
  }) async {
    final response = await _client
        .post(
          Uri.parse(ApiConfig.askUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'question': question, 'language': language}),
        )
        .timeout(const Duration(seconds: 120));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return AskResponse.fromJson(json);
    }

    String detail = 'Request failed (${response.statusCode})';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      detail = body['detail']?.toString() ?? detail;
    } catch (_) {}

    throw ApiException(detail, statusCode: response.statusCode);
  }

  Future<AskResponse> analyzeDocument({
    required List<int> bytes,
    required String filename,
    String? question,
    String language = 'urdu_script',
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConfig.analyzeDocumentUrl),
    );
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ),
    );
    final q = question?.trim();
    if (q != null && q.isNotEmpty) {
      request.fields['question'] = q;
    }
    request.fields['language'] = language;

    final streamed = await request.send().timeout(const Duration(seconds: 180));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return AskResponse.fromJson(json);
    }

    String detail = 'Upload failed (${response.statusCode})';
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        detail = body['detail']?.toString() ?? detail;
      }
    } catch (_) {}

    throw ApiException(detail, statusCode: response.statusCode);
  }

  Future<String> createConversation({
    required String deviceId,
    String language = 'urdu_script',
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/conversations'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'device_id': deviceId, 'language': language}),
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw ApiException('Could not start conversation (${response.statusCode})');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['id'] as String;
  }

  Future<List<Map<String, dynamic>>> listConversations(String deviceId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/conversations').replace(
      queryParameters: {'device_id': deviceId},
    );
    final response = await _client.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) return [];
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getConversation({
    required String conversationId,
    required String deviceId,
  }) async {
    final uri =
        Uri.parse('${ApiConfig.baseUrl}/conversations/$conversationId').replace(
      queryParameters: {'device_id': deviceId},
    );
    final response = await _client.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw ApiException('Could not load conversation (${response.statusCode})');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> deleteConversation({
    required String conversationId,
    required String deviceId,
  }) async {
    final uri =
        Uri.parse('${ApiConfig.baseUrl}/conversations/$conversationId').replace(
      queryParameters: {'device_id': deviceId},
    );
    final response =
        await _client.delete(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw ApiException('Could not delete conversation (${response.statusCode})');
    }
  }

  Future<void> submitFeedback({
    required String messageId,
    String? deviceId,
    required String rating,
    String? conversationId,
    String language = 'urdu_script',
    String channel = 'chat',
  }) async {
    final resolvedDeviceId = await _resolvedDeviceId(deviceId);
    final body = <String, dynamic>{
      'message_id': messageId,
      'device_id': resolvedDeviceId,
      'rating': rating,
      'language': language,
      'channel': channel,
    };
    if (conversationId != null && conversationId.isNotEmpty) {
      body['conversation_id'] = conversationId;
    }

    final response = await _client
        .post(
          Uri.parse(ApiConfig.feedbackUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 204 && response.statusCode != 200) {
      String detail = 'Feedback failed (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          detail = decoded['detail']?.toString() ?? detail;
        }
      } catch (_) {}
      throw ApiException(detail, statusCode: response.statusCode);
    }
  }

  void dispose() => _client.close();
}
