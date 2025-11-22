class AppConfig {
  static const bool isProd = false;
  static const String _localDomain = 'http://192.168.31.24:8000';
  static const String _prodDomain = 'https://thequickcard.com';
  static String get domain => isProd ? _prodDomain : _localDomain;
  static String get baseUrl => '$domain/api';
  static String get imageBaseUrl => '$domain/uploads/images';
}
