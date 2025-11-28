import 'package:dio/dio.dart';
import 'api_client.dart';

class ExaminationApi {
  final ApiClient _client;
  ExaminationApi(this._client);

  Future<int> _myId() async {
    final res = await _client.get('/auth/me');
    final data = res.data;
    if (data is Map && data['id'] != null) return (data['id'] as num).toInt();
    throw Exception('Gagal mengambil profil user.');
  }

  Future<List<Map<String, dynamic>>> listMine() async {
    final uid = await _myId();
    // Sesuaikan endpoint dengan controller NestJS kamu:
    // gunakan salah satu yang tersedia di backend (pilih yang cocok):
    // a) /health-metrics/user/:id        ⟵ sering dipakai
    // b) /health-metrics?userId=:id
    final res = await _client.get('/health-metrics/user/$uid');
    final d = res.data;
    if (d is List) return List<Map<String, dynamic>>.from(d);
    if (d is Map && d['items'] is List) return List<Map<String, dynamic>>.from(d['items']);
    return <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final res = await _client.get('/health-metrics/$id');
    if (res.data is Map) return Map<String, dynamic>.from(res.data);
    throw Exception('Data tidak ditemukan');
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    final res = await _client.post('/health-metrics', data: payload);
    if (res.data is Map) return Map<String, dynamic>.from(res.data);
    throw Exception('Respon tidak valid saat create');
  }

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> payload) async {
    final res = await _client.patch('/health-metrics/$id', data: payload);
    if (res.data is Map) return Map<String, dynamic>.from(res.data);
    return {'id': id, 'ok': true, ...payload};
  }

  Future<void> delete(String id) async {
    await _client.delete('/health-metrics/$id');
  }
}
