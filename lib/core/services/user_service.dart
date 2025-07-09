import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quickcard/shared/models/user_info.dart';

class UserService {
  static const String _userKey = 'user';

  static Future<void> saveUser(UserInfo user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  static Future<UserInfo?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);

    if (userString != null) {
      final jsonMap = json.decode(userString);
      return UserInfo.fromSavedJson(jsonMap);
    }

    return null;
  }

  static Future<bool> hasUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userKey);
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
