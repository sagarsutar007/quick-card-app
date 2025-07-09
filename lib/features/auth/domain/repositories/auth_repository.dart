import 'package:quickcard/shared/models/user_info.dart';

abstract class AuthRepository {
  Future<UserInfo> login(String emailOrPhone, String password);

  Future<bool> isLoggedIn();

  Future<UserInfo?> getProfile();

  Future<void> saveToken(String token);

  Future<String?> getToken();

  Future<void> logout();
}
