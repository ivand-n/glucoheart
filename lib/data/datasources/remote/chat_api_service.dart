import 'package:dio/dio.dart';
import 'package:glucoheart_flutter/data/datasources/remote/api_client.dart';

class ChatApiService {
  final ApiClient _client;
  ChatApiService(this._client);

  Future<Map<String, dynamic>> createOrGetSessionByRole({String role = 'ADMIN'}) async {
    final Response res = await _client.post('/chat/session', data: {'role': role});
    return Map<String, dynamic>.from(res.data);
  }

  Future<List<dynamic>> listSessions() async {
    final Response res = await _client.get('/chat/sessions');
    final data = res.data;
    if (data is List) return data;
    return [];
  }

  Future<List<dynamic>> fetchMessages(int sessionId) async {
    final Response res = await _client.get('/chat/session/$sessionId/messages');
    final data = res.data;
    if (data is List) return data;
    return [];
  }

  Future<Map<String, dynamic>> sendMessage(int sessionId, String content) async {
    final Response res = await _client.post('/chat/session/$sessionId/message', data: {'content': content});
    return Map<String, dynamic>.from(res.data);
  }
}
