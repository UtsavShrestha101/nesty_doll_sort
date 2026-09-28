import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/links/app_links.dart';

void main() {
  test('both links are empty until the owner supplies them (Q73): the '
      'Settings rows hide rather than open a blank link', () {
    expect(AppLinks.privacyPolicyUrl, isEmpty);
    expect(AppLinks.supportEmail, isEmpty);
  });
}
