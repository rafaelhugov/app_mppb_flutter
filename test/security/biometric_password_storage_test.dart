import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('biometria nao grava senha no secure storage', () {
    final authProvider = File(
      'lib/features/auth/providers/auth_provider.dart',
    ).readAsStringSync();

    expect(authProvider, isNot(contains("write(key: 'saved_password'")));
    expect(authProvider, isNot(contains('write(key: "saved_password"')));
  });

  test('login biometrico legado nao reutiliza senha salva', () {
    final authProvider = File(
      'lib/features/auth/providers/auth_provider.dart',
    ).readAsStringSync();

    expect(authProvider, contains('Future<bool> loginWithSavedCredentials()'));
    expect(authProvider, isNot(contains('return login(savedUsername')));
    expect(authProvider, isNot(contains('return login(username')));
  });
}
