import 'api_client.dart';

class ChatApi {
  final ApiClient _api;

  ChatApi({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  /// POST /chat/session  => session object (Map)
  /// body { role: 'ADMIN' | 'SUPPORT' }
  Future<Map<String, dynamic>> createOrGetSessionByRole(String role) async {
    final res = await _api.post('/chat/session', data: {'role': role});
    // Backend mengembalikan object session (id, type, ...).
    if (res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    // fallback (harusnya tidak kejadian)
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// GET /chat/sessions => List of sessions
  Future<List<dynamic>> listSessions() async {
    final res = await _api.get('/chat/sessions');
    if (res.data is List) return res.data as List;
    return [];
  }

  /// GET /chat/session/:sessionId/messages => List of messages
  Future<List<dynamic>> fetchMessages(int sessionId) async {
    final res = await _api.get('/chat/session/$sessionId/messages');
    if (res.data is List) return res.data as List;
    return [];
  }

  /// POST /chat/session/:sessionId/message => message object (Map)
  Future<Map<String, dynamic>> sendMessage(int sessionId, String content) async {
    final res =
    await _api.post('/chat/session/$sessionId/message', data: {'content': content});
    if (res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    return Map<String, dynamic>.from(res.data as Map);
  }
}
