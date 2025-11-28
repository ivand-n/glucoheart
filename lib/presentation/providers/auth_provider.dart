import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../data/repositories/auth_repository_impl.dart';

// Repository provider
final authRepositoryProvider = Provider((ref) => AuthRepositoryImpl());

// Auth state
enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isLoading;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepositoryImpl _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState()) {
    checkAuthStatus();
  }

  void setUser(User newUser) {
    state = state.copyWith(user: newUser, status: AuthStatus.authenticated);
  }

  Future<void> checkAuthStatus() async {
    try {
      state = state.copyWith(isLoading: true);
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final user = await _authRepository.login(email, password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> register(String firstName, String lastName, String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final user = await _authRepository.register(firstName, lastName, email, password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true);
      await _authRepository.logout();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});