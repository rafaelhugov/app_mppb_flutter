import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('manifest principal desabilita cleartext para release', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(manifest, contains('android:usesCleartextTraffic="false"'));
    expect(manifest, isNot(contains('android:usesCleartextTraffic="true"')));
  });

  test('cleartext fica isolado em debug e profile', () {
    for (final caminho in [
      'android/app/src/debug/AndroidManifest.xml',
      'android/app/src/profile/AndroidManifest.xml',
    ]) {
      final manifest = File(caminho).readAsStringSync();

      expect(manifest, contains('android:usesCleartextTraffic="true"'));
      expect(manifest, contains('tools:replace="android:usesCleartextTraffic"'));
    }
  });
}
