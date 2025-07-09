import 'dart:convert';
import 'package:quickcard/shared/models/user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? get token => _prefs.getString('token');

  Future<void> saveToken(String token) async {
    await _prefs.setString('token', token);
  }

  Future<void> clearToken() async {
    await _prefs.remove('token');
  }

  bool get isLoggedIn => _prefs.containsKey('token');

  Future<void> saveUser(UserInfo user) async {
    final jsonString = jsonEncode(user.toJson());
    await _prefs.setString('user', jsonString);
  }

  Future<UserInfo?> getUser() async {
    final jsonString = _prefs.getString('user');
    if (jsonString == null) return null;

    final Map<String, dynamic> userMap = jsonDecode(jsonString);
    return UserInfo.fromJson(userMap, userMap['token'] ?? token ?? '');
  }

  Future<void> clearUser() async {
    await _prefs.remove('user');
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
