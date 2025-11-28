import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucoheart_flutter/data/repositories/usrs_repository_impl.dart';
import '../../domain/repositories/users_repository.dart';
import '../../domain/entities/user.dart';
import 'auth_provider.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepositoryImpl();
});

// ---------- Edit Profile ----------
class EditProfileState {
  final bool isSaving;
  final String? error;
  final bool success;

  const EditProfileState({this.isSaving = false, this.error, this.success = false});

  EditProfileState copyWith({bool? isSaving, String? error, bool? success}) {
    return EditProfileState(
      isSaving: isSaving ?? this.isSaving,
      error: error,
      success: success ?? this.success,
    );
  }
}

final editProfileProvider =
StateNotifierProvider<EditProfileNotifier, EditProfileState>((ref) {
  return EditProfileNotifier(ref);
});

class EditProfileNotifier extends StateNotifier<EditProfileState> {
  final Ref _ref;
  EditProfileNotifier(this._ref) : super(const EditProfileState());

  Future<User?> save({
    String? firstName,
    String? lastName,
    String? profilePicture,
    String? email,
  }) async {
    state = state.copyWith(isSaving: true, error: null, success: false);
    try {
      final repo = _ref.read(usersRepositoryProvider);
      final updated = await repo.updateMe(
        firstName: firstName,
        lastName: lastName,
        profilePicture: profilePicture,
        email: email,
      );

      _ref.read(authProvider.notifier).setUser(updated);
      state = state.copyWith(isSaving: false, success: true);
      return updated;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString(), success: false);
      return null;
    }
  }
}

// ---------- Change Password ----------
class ChangePasswordState {
  final bool isSubmitting;
  final String? error;
  final bool success;

  const ChangePasswordState({this.isSubmitting = false, this.error, this.success = false});

  ChangePasswordState copyWith({bool? isSubmitting, String? error, bool? success}) {
    return ChangePasswordState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      success: success ?? this.success,
    );
  }
}

final changePasswordProvider =
StateNotifierProvider<ChangePasswordNotifier, ChangePasswordState>((ref) {
  return ChangePasswordNotifier(ref);
});

class ChangePasswordNotifier extends StateNotifier<ChangePasswordState> {
  final Ref _ref;
  ChangePasswordNotifier(this._ref) : super(const ChangePasswordState());

  Future<bool> submit({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null, success: false);
    try {
      final repo = _ref.read(usersRepositoryProvider);
      await repo.changeMyPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(isSubmitting: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString(), success: false);
      return false;
    }
  }
}
