import '../../domain/entities/user.dart';

abstract class UsersRepository {
  Future<User> updateMe({
    String? firstName,
    String? lastName,
    String? profilePicture,
    String? email,
  });

  Future<void> changeMyPassword({
    required String currentPassword,
    required String newPassword,
  });
}
