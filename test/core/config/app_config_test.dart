import 'package:flutter_test/flutter_test.dart';
import 'package:notifications_challenge/core/config/app_config.dart';

void main() {
  test('fails clearly when API_BEARER_TOKEN is not configured', () {
    if (AppConfig.apiBearerToken.isNotEmpty) {
      return;
    }

    expect(
      AppConfig.validate,
      throwsA(
        isA<StateError>().having(
          (StateError error) => error.message,
          'message',
          contains('API_BEARER_TOKEN is not configured'),
        ),
      ),
    );
  });
}
