import 'package:dio/dio.dart';
import '../../models/auth/login_request.dart';
import '../../models/auth/register_request.dart';
import '../../models/auth/auth_response.dart';
import 'api_client.dart';

class AuthApi {
  final ApiClient _apiClient;

  AuthApi(this._apiClient);

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post('/auth/login', data: request.toJson());
      await _apiClient.saveToken(response.data['access_token']);
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('Email atau password salah');
        } else if (e.response?.data != null) {
          throw Exception(e.response?.data['message'] ?? 'Login gagal');
        }
      }
      throw Exception('Gagal terhubung ke server');
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.post('/auth/register', data: request.toJson());

      // Backend might directly return token or might require login after register
      if (response.data['access_token'] != null) {
        await _apiClient.saveToken(response.data['access_token']);
        return AuthResponse.fromJson(response.data);
      } else {
        // If backend doesn't return token after register, login with the same credentials
        return login(LoginRequest(
          email: request.email,
          password: request.password,
        ));
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 409) {
          throw Exception('Email sudah terdaftar');
        } else if (e.response?.data != null) {
          throw Exception(e.response?.data['message'] ?? 'Registrasi gagal');
        }
      }
      throw Exception('Gagal terhubung ke server');
    }
  }

  Future<bool> logout() async {
    try {
      await _apiClient.post('/auth/logout');
      await _apiClient.clearToken();
      return true;
    } catch (e) {
      // Even if backend call fails, we still clear the token
      await _apiClient.clearToken();
      return true;
    }
  }

  Future<dynamic> getUserProfile() async {
    try {
      final response = await _apiClient.get('/auth/me');
      return response.data;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        await _apiClient.clearToken();
        throw Exception('Sesi Anda telah berakhir, silakan login kembali');
      }
      throw Exception('Gagal memuat profil pengguna');
    }
  }
}