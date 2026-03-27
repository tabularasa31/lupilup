import 'package:flutter_test/flutter_test.dart';
import 'package:lupilup_flutter/features/auth/logic/auth_state.dart';

void main() {
  test('resolveBootstrapTarget sends signed-out users to login', () {
    expect(
      resolveBootstrapTarget(hasSession: false, hasSettings: false),
      AppBootstrapTarget.login,
    );
  });

  test('resolveBootstrapTarget sends first-time users to onboarding', () {
    expect(
      resolveBootstrapTarget(hasSession: true, hasSettings: false),
      AppBootstrapTarget.onboarding,
    );
  });

  test('resolveBootstrapTarget sends returning users to stash', () {
    expect(
      resolveBootstrapTarget(hasSession: true, hasSettings: true),
      AppBootstrapTarget.stash,
    );
  });
}
