import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('primeiro frame nao aguarda Firebase ou operacoes remotas do FCM', () {
    final mainSource = File('lib/main.dart').readAsStringSync();

    final runApp = mainSource.indexOf('runApp(');
    final firebaseInitialization = mainSource.indexOf(
      'Firebase.initializeApp(',
    );
    final firstFrameCallback = mainSource.indexOf('addPostFrameCallback');
    final pushInitialization = mainSource.indexOf(
      'PushNotificationService.instance.initialize()',
    );

    expect(runApp, greaterThanOrEqualTo(0));
    expect(firebaseInitialization, greaterThan(runApp));
    expect(firstFrameCallback, greaterThan(runApp));
    expect(pushInitialization, greaterThan(firstFrameCallback));
  });

  test('chamadas FCM suscetiveis a rede possuem timeout', () {
    final source = File(
      'lib/core/notifications/push_notification_service.dart',
    ).readAsStringSync();

    expect(source, contains('requestPermission().timeout('));
    expect(source, contains('subscribeToPublicNewsTopic().timeout('));
    expect(source, contains('_messaging.getInitialMessage().timeout('));
  });
}
