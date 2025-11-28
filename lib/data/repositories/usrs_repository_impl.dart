import '../../domain/entities/user.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasources/remote/users_api.dart';
import '../models/user_model.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersApi _api;

  UsersRepositoryImpl({UsersApi? api}) : _api = api ?? UsersApi();

  @override
  Future<User> updateMe({
    String? firstName,
    String? lastName,
    String? profilePicture,
    String? email,
  }) async {
    final me = await _api.getMe();
    final id = (me['id'] ?? me['user']?['id']).toString();

    final updated = await _api.updateUser(
      id: id,
      firstName: firstName,
      lastName: lastName,
      profilePicture: profilePicture,
      email: email,
    );
    return UserModel.fromJson(updated);
  }

  @override
  Future<void> changeMyPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
