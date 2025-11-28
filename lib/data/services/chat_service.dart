import 'package:dio/dio.dart';
import 'package:glucoheart_flutter/data/datasources/remote/api_client.dart';
import 'package:glucoheart_flutter/domain/entities/chat_session.dart';

class ChatService {
  final ApiClient _api = ApiClient();

  /// Ambil semua session user
  Future<List<ChatSession>> getSessions() async {
    final res = await _api.get('/chat/sessions');
    return (res.data as List).map((e) => ChatSession.fromJson(e)).toList();
  }

  /// Ambil messages dalam satu session
  Future<List<Map<String, dynamic>>> getMessages(int sessionId) async {
    final res = await _api.get('/chat/session/$sessionId/messages');
    return (res.data as List).cast<Map<String, dynamic>>();
  }

  /// Buat / ambil session 1-1 untuk user saat ini
  Future<int> getOrCreateSession() async {
    final sessions = await getSessions();

    // Cari session one_to_one
    final existing = sessions.where((s) => s.type == "one_to_one").toList();
    if (existing.isNotEmpty) {
      return existing.first.id;
    }

    // Kalau belum ada, create
    final res = await _api.post('/chat/sessions', data: {
      "type": "one_to_one",
    });

    return res.data["id"];
  }
}
