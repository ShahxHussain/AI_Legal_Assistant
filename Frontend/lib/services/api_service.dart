import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/ask_response.dart';

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

  Future<bool> checkHealth() async {
    final response = await _client
        .get(Uri.parse(ApiConfig.healthUrl))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) return false;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['index_loaded'] == true;
  }

  /// Streams NDJSON events from POST /ask/stream:
  /// {"type":"meta"|"delta"|"done"|"error", ...}
  Stream<Map<String, dynamic>> askStream(
    String question, {
    String language = 'auto',
  }) async* {
    final request = http.Request('POST', Uri.parse(ApiConfig.askStreamUrl))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({'question': question, 'language': language});

    final response =
        await _client.send(request).timeout(const Duration(seconds: 30));

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

  Future<AskResponse> ask(String question, {String language = 'auto'}) async {
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
    String language = 'auto',
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

  void dispose() => _client.close();
}
