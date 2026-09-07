class AppConfig {
  static const String apiBearerToken = String.fromEnvironment(
    'API_BEARER_TOKEN',
  );

  static void validate() {
    if (apiBearerToken.isEmpty) {
      throw StateError(
        'API_BEARER_TOKEN is not configured. '
        'Run Flutter with --dart-define-from-file=secrets.json.',
      );
    }
  }
}
