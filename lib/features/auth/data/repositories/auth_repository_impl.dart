import 'package:quickcard/core/network/api_client.dart';
import 'package:quickcard/core/services/locator.dart';
import 'package:quickcard/core/services/storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:quickcard/shared/models/user_info.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient client;

  AuthRepositoryImpl(this.client);

  @override
  Future<UserInfo> login(String emailOrPhone, String password) async {
    final response = await client.post('/login', {
      'emailOrPhone': emailOrPhone,
      'password': password,
    });

    final token = response.data['token'];
    final userJson = response.data['user'];

    final user = UserInfo.fromJson(userJson, token);

    await getIt<StorageService>().saveToken(token);
    await getIt<StorageService>().saveUser(user);

    return user;
  }

  @override
  Future<bool> isLoggedIn() async {
    return getIt<StorageService>().isLoggedIn;
  }

  @override
  Future<UserInfo?> getProfile() async {
    return null;
  }

  @override
  Future<void> saveToken(String token) async {
    await getIt<StorageService>().saveToken(token);
  }

  @override
  Future<String?> getToken() async {
    return getIt<StorageService>().token;
  }

  @override
  Future<void> logout() async {
    await getIt<StorageService>().clearToken();
  }
}
