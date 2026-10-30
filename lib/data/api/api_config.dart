class ApiConfig {
  static String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dashboard.momnjo.my.id/dev/api_terapis_v4',
  );

  static void setBaseUrl(String url) {
    baseUrl = url;
  }

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Endpoints
  static const String healthCheck = '/';
  static const String login = '/login.php';
  static const String profile = '/me.php';
  static const String updateProfile = '/me.php';
  static const String gerai = '/gerai.php';
  static const String absensi = '/absensi.php';
  static const String jobs = '/jobs.php';
  static const String report = '/report.php';
}

