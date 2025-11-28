import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_api.dart';
import '../datasources/remote/api_client.dart';
import '../models/auth/login_request.dart';
import '../models/auth/register_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _authApi;
  User? _currentUser;
  final String _userKey = 'current_user';

  AuthRepositoryImpl({AuthApi? authApi})
      : _authApi = authApi ?? AuthApi(ApiClient());

  @override
  Future<User> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authApi.login(request);

      _currentUser = response.user;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, response.user.toJson().toString());

      return response.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<User> register(String firstName, String lastName, String email, String password) async {
    try {
      final request = RegisterRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );

      final response = await _authApi.register(request);

      _currentUser = response.user;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, response.user.toJson().toString());

      return response.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _authApi.logout();
      _currentUser = null;

      // Clear from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);

      return true;
    } catch (e) {
      // Even if API call fails, we still clear local data
      _currentUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      return true;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    // Check if we have a token
    final apiClient = ApiClient();
    final hasToken = await apiClient.hasToken();

    if (hasToken) {
      try {
        // Try to get current user from API
        final userData = await _authApi.getUserProfile();
        _currentUser = User.fromJson(userData);
        return _currentUser;
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  Future<String?> getAuthToken() async {
    final apiClient = ApiClient();
    return apiClient.getToken();
  }
}