import 'dart:async';

import 'package:app_mppb_flutter/core/notifications/device_registration_provider.dart';
import 'package:app_mppb_flutter/core/notifications/device_registration_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeviceRegistrationManager', () {
    late FakeDeviceRegistrationRepository repository;
    late FakePushTokenProvider pushTokenProvider;
    late FakeDeviceRegistrationStore store;
    late FakePlatformResolver platformResolver;
    late DeviceRegistrationManager manager;

    setUp(() {
      repository = FakeDeviceRegistrationRepository();
      pushTokenProvider = FakePushTokenProvider();
      store = FakeDeviceRegistrationStore();
      platformResolver = FakePlatformResolver('ANDROID');
      manager = DeviceRegistrationManager(
        repository: repository,
        pushTokenProvider: pushTokenProvider,
        store: store,
        platformResolver: platformResolver,
      );
    });

    tearDown(() async {
      await manager.dispose();
      await pushTokenProvider.dispose();
    });

    test('registra dispositivo apos autenticacao', () async {
      pushTokenProvider.token = 'fcm-token-1';

      await manager.registrarSeAutenticado('auth-token');

      expect(repository.registros, hasLength(1));
      expect(repository.registros.single.identificador, store.installationId);
      expect(repository.registros.single.tokenFcm, 'fcm-token-1');
      expect(repository.registros.single.plataforma, 'ANDROID');
    });

    test('nao registra sem usuario autenticado', () async {
      pushTokenProvider.token = 'fcm-token-1';

      await manager.registrarSeAutenticado(null);
      await manager.registrarSeAutenticado(' ');

      expect(repository.registros, isEmpty);
      expect(pushTokenProvider.permissionRequests, 0);
    });

    test('reutiliza identificador local da instalacao', () async {
      pushTokenProvider.token = 'fcm-token-1';

      await manager.registrarSeAutenticado('auth-token');
      pushTokenProvider.token = 'fcm-token-2';
      await manager.registrarSeAutenticado('auth-token');

      expect(repository.registros, hasLength(2));
      expect(
        repository.registros[0].identificador,
        repository.registros[1].identificador,
      );
      expect(store.createdCount, 1);
    });

    test('registra rotacao de token quando autenticado', () async {
      manager.startTokenRefreshListener(() => 'auth-token');

      pushTokenProvider.emitTokenRefresh('fcm-token-rotacionado');
      await Future<void>.delayed(Duration.zero);

      expect(repository.registros, hasLength(1));
      expect(repository.registros.single.tokenFcm, 'fcm-token-rotacionado');
      expect(repository.registros.single.identificador, store.installationId);
    });

    test('ignora rotacao de token sem autenticacao', () async {
      manager.startTokenRefreshListener(() => null);

      pushTokenProvider.emitTokenRefresh('fcm-token-rotacionado');
      await Future<void>.delayed(Duration.zero);

      expect(repository.registros, isEmpty);
    });

    test('desativa dispositivo no logout', () async {
      await store.getOrCreateInstallationId();

      await manager.desativarAntesLogout('auth-token');

      expect(repository.desativacoes, hasLength(1));
      expect(
        repository.desativacoes.single.identificador,
        store.installationId,
      );
    });

    test('falha de rede no logout nao bloqueia saida', () async {
      await store.getOrCreateInstallationId();
      repository.falharDesativacao = true;

      await manager.desativarAntesLogout('auth-token');

      expect(repository.desativacoes, hasLength(1));
    });

    test('nao registra quando token FCM esta ausente', () async {
      pushTokenProvider.token = null;

      await manager.registrarSeAutenticado('auth-token');

      expect(repository.registros, isEmpty);
    });

    test('nao imprime token FCM em logs', () async {
      final originalDebugPrint = debugPrint;
      final logs = <String>[];
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) {
          logs.add(message);
        }
      };

      try {
        pushTokenProvider.token = 'fcm-token-secreto';
        await runZoned(
          () => manager.registrarSeAutenticado('auth-token'),
          zoneSpecification: ZoneSpecification(
            print: (self, parent, zone, line) => logs.add(line),
          ),
        );
      } finally {
        debugPrint = originalDebugPrint;
      }

      expect(logs.join('\n'), isNot(contains('fcm-token-secreto')));
    });
  });
}

class FakePushTokenProvider implements PushTokenProvider {
  final StreamController<String> _tokenRefreshController =
      StreamController<String>.broadcast();
  String? token;
  int permissionRequests = 0;

  @override
  Stream<String> get tokenRefreshes => _tokenRefreshController.stream;

  @override
  Future<String?> getToken() async => token;

  @override
  Future<void> requestPermission() async {
    permissionRequests += 1;
  }

  void emitTokenRefresh(String token) {
    _tokenRefreshController.add(token);
  }

  Future<void> dispose() {
    return _tokenRefreshController.close();
  }
}

class FakeDeviceRegistrationStore extends DeviceRegistrationStore {
  String? installationId;
  int createdCount = 0;

  FakeDeviceRegistrationStore() : super(const FlutterSecureStorage());

  @override
  Future<String?> readInstallationId() async => installationId;

  @override
  Future<String> getOrCreateInstallationId() async {
    if (installationId != null) {
      return installationId!;
    }
    createdCount += 1;
    installationId = 'installation-uuid';
    return installationId!;
  }
}

class FakePlatformResolver extends DevicePlatformResolver {
  final String? plataforma;

  const FakePlatformResolver(this.plataforma);

  @override
  String? currentPlatform() => plataforma;
}

class FakeDeviceRegistrationRepository extends DeviceRegistrationRepository {
  final List<RegistroCapturado> registros = [];
  final List<DesativacaoCapturada> desativacoes = [];
  bool falharDesativacao = false;

  FakeDeviceRegistrationRepository() : super(Dio());

  @override
  Future<DeviceRegistrationResponse> registrar({
    required String identificador,
    required String tokenFcm,
    required String plataforma,
  }) async {
    registros.add(
      RegistroCapturado(
        identificador: identificador,
        tokenFcm: tokenFcm,
        plataforma: plataforma,
      ),
    );
    return DeviceRegistrationResponse(
      identificador: identificador,
      plataforma: plataforma,
      ativo: true,
    );
  }

  @override
  Future<void> desativar({required String identificador}) async {
    desativacoes.add(DesativacaoCapturada(identificador: identificador));
    if (falharDesativacao) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/notificacoes/dispositivos'),
        type: DioExceptionType.connectionError,
      );
    }
  }
}

class RegistroCapturado {
  final String identificador;
  final String tokenFcm;
  final String plataforma;

  const RegistroCapturado({
    required this.identificador,
    required this.tokenFcm,
    required this.plataforma,
  });
}

class DesativacaoCapturada {
  final String identificador;

  const DesativacaoCapturada({required this.identificador});
}
