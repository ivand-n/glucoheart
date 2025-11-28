import 'package:dio/dio.dart';

class DiscussionApiService {
  final Dio _dio;
  DiscussionApiService(this._dio);

  Future<List<dynamic>> fetchMessages(int roomId) async {
    final res = await _dio.get('/discussion/rooms/$roomId/messages');
    if (res.statusCode == 200) {
      final data = res.data;
      if (data is List) return data;
    }
    return [];
  }

  Future<List<dynamic>> listRooms() async {
    final res = await _dio.get('/discussion/rooms');
    if (res.statusCode == 200) {
      final data = res.data;
      if (data is List) return data;
    }
    return [];
  }

  Future<dynamic> sendMessage(int roomId, String content) async {
    final res = await _dio.post('/discussion/rooms/$roomId/message', data: {
      'content': content,
    });
    return res.data;
  }
}
