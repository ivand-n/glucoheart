import 'api_client.dart';

class UsersApi {
  final ApiClient _api;

  UsersApi([ApiClient? apiClient]) : _api = apiClient ?? ApiClient();

  /// GET /auth/me — ambil user saat ini untuk tahu id
  Future<Map<String, dynamic>> getMe() async {
    final res = await _api.get('/auth/me');
    return res.data as Map<String, dynamic>;
  }

  /// PUT /users/:id — update sebagian field
  Future<Map<String, dynamic>> updateUser({
    required String id,
    String? firstName,
    String? lastName,
    String? profilePicture,
    String? email,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;
    if (profilePicture != null) body['profilePicture'] = profilePicture;
    if (email != null) body['email'] = email;

    final res = await _api.patch('/users/$id', data: body);
    return res.data as Map<String, dynamic>;
  }

  /// POST /users/change-password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final body = {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
    await _api.post('/users/change-password', data: body);
  }
}
