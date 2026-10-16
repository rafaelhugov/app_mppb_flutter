import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_client.dart';
import '../storage/secure_storage.dart';
import 'device_registration_diagnostics_provider.dart';
import 'device_registration_repository.dart';
import 'push_notification_service.dart';

const _installationIdStorageKey = 'push_installation_id';

abstract class PushTokenProvider {
  Stream<String> get tokenRefreshes;

  Future<String> requestPermission();

  Future<String?> getToken();
}

class FirebasePushTokenProvider implements PushTokenProvider {
  final PushNotificationService service;

  const FirebasePushTokenProvider(this.service);

  @override
  Stream<String> get tokenRefreshes => service.tokenRefreshes;

  @override
  Future<String> requestPermission() async {
    final settings = await service.requestPermission();
    return settings.authorizationStatus.name;
  }

  @override
  Future<String?> getToken() {
    return service.getToken();
  }
}

class DeviceRegistrationStore {
  final FlutterSecureStorage secureStorage;

  const DeviceRegistrationStore(this.secureStorage);

  Future<String?> readInstallationId() {
    return secureStorage.read(key: _installationIdStorageKey);
  }

  Future<String> getOrCreateInstallationId() async {
    final existing = await readInstallationId();
    if (existing != null && existing.trim().isNotEmpty) {
      return existing.trim();
    }

    final generated = _newUuidV4();
    await secureStorage.write(key: _installationIdStorageKey, value: generated);
    return generated;
  }

  static String _newUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    String twoHex(int value) => value.toRadixString(16).padLeft(2, '0');
    final hex = bytes.map(twoHex).join();
    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}

class DevicePlatformResolver {
  const DevicePlatformResolver();

  String? currentPlatform() {
    if (kIsWeb) {
      return null;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ANDROID';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'IOS';
    }
    return null;
  }
}

class DeviceRegistrationManager {
  final DeviceRegistrationRepository repository;
  final DeviceRegistrationStore store;
  final DevicePlatformResolver platformResolver;
  final DeviceRegistrationDiagnosticsNotifier? diagnostics;
  final bool requireFirebaseReady;
  final PushTokenProvider Function() _pushTokenProviderFactory;

  StreamSubscription<String>? _tokenRefreshSubscription;
  PushTokenProvider? _pushTokenProvider;

  DeviceRegistrationManager({
    required this.repository,
    required this.store,
    required this.platformResolver,
    this.diagnostics,
    this.requireFirebaseReady = false,
    PushTokenProvider? pushTokenProvider,
    PushTokenProvider Function()? pushTokenProviderFactory,
  }) : assert(pushTokenProvider != null || pushTokenProviderFactory != null),
       _pushTokenProvider = pushTokenProvider,
       _pushTokenProviderFactory =
           pushTokenProviderFactory ?? (() => pushTokenProvider!);

  PushTokenProvider get _tokens {
    return _pushTokenProvider ??= _pushTokenProviderFactory();
  }

  void startTokenRefreshListener(String? Function() authTokenProvider) {
    if (platformResolver.currentPlatform() == null ||
        !PushNotificationService.isSupportedPlatform ||
        (requireFirebaseReady && !PushNotificationService.isFirebaseReady)) {
      return;
    }

    _tokenRefreshSubscription ??= _tokens.tokenRefreshes.listen((token) {
      final authToken = authTokenProvider();
      if (_isBlank(authToken) || _isBlank(token)) {
        return;
      }
      unawaited(_registrarComToken(token.trim()));
    });
  }

  Future<void> registrarSeAutenticado(String? authToken) async {
    if (_isBlank(authToken)) {
      _diagnostic(
        const DeviceRegistrationDiagnosticsState(
          step: DeviceRegistrationStep.skipped,
          message: 'Registro ignorado: usuario sem token de autenticacao',
        ),
      );
      return;
    }

    final plataforma = platformResolver.currentPlatform();
    if (plataforma == null ||
        !PushNotificationService.isSupportedPlatform ||
        (requireFirebaseReady && !PushNotificationService.isFirebaseReady)) {
      _diagnostic(
        const DeviceRegistrationDiagnosticsState(
          step: DeviceRegistrationStep.skipped,
          message: 'Registro ignorado: plataforma sem suporte FCM',
        ),
      );
      return;
    }

    String? permissionStatus;
    String? tokenFcm;

    try {
      _diagnostic(
        const DeviceRegistrationDiagnosticsState(
          step: DeviceRegistrationStep.requestingPermission,
          message: 'Solicitando permissao de notificacao',
        ),
      );
      permissionStatus = await _tokens.requestPermission();
      _diagnostic(
        DeviceRegistrationDiagnosticsState(
          step: DeviceRegistrationStep.permissionResolved,
          message: 'Permissao de notificacao consultada',
          permissionStatus: permissionStatus,
        ),
      );
      _diagnostic(
        DeviceRegistrationDiagnosticsState(
          step: DeviceRegistrationStep.requestingToken,
          message: 'Solicitando token FCM',
          permissionStatus: permissionStatus,
        ),
      );
      tokenFcm = await _tokens.getToken();
      if (_isBlank(tokenFcm)) {
        _diagnostic(
          DeviceRegistrationDiagnosticsState(
            step: DeviceRegistrationStep.tokenMissing,
            message: 'Firebase nao retornou token FCM',
            permissionStatus: permissionStatus,
            hasToken: false,
          ),
        );
        return;
      }
      final tokenFcmNormalizado = tokenFcm!.trim();
      _diagnostic(
        DeviceRegistrationDiagnosticsState(
          step: DeviceRegistrationStep.registering,
          message: 'Enviando dispositivo ao backend',
          permissionStatus: permissionStatus,
          hasToken: true,
          tokenLength: tokenFcmNormalizado.length,
        ),
      );
      await _registrarComToken(tokenFcmNormalizado);
      _diagnostic(
        DeviceRegistrationDiagnosticsState(
          step: DeviceRegistrationStep.registered,
          message: 'Dispositivo registrado no backend',
          permissionStatus: permissionStatus,
          hasToken: true,
          tokenLength: tokenFcmNormalizado.length,
          backendStatus: 200,
        ),
      );
    } catch (e) {
      _diagnostic(
        DeviceRegistrationDiagnosticsState(
          step: DeviceRegistrationStep.failed,
          message: 'Falha ao registrar dispositivo',
          permissionStatus: permissionStatus,
          hasToken: !_isBlank(tokenFcm),
          tokenLength: _isBlank(tokenFcm) ? null : tokenFcm!.trim().length,
          lastError: _safeError(e),
          backendStatus: _statusCode(e),
        ),
      );
      return;
    }
  }

  Future<void> desativarAntesLogout(String? authToken) async {
    if (_isBlank(authToken)) {
      return;
    }

    try {
      final identificador = await store.readInstallationId();
      if (_isBlank(identificador)) {
        return;
      }
      await repository.desativar(identificador: identificador!.trim());
    } catch (_) {
      return;
    }
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }

  Future<void> _registrarComToken(String tokenFcm) async {
    final plataforma = platformResolver.currentPlatform();
    if (plataforma == null) {
      return;
    }

    final identificador = await store.getOrCreateInstallationId();
    await repository.registrar(
      identificador: identificador,
      tokenFcm: tokenFcm,
      plataforma: plataforma,
    );
  }

  void _diagnostic(DeviceRegistrationDiagnosticsState state) {
    diagnostics?.update(state);
    unawaited(_sendDiagnostic(state));
  }

  Future<void> _sendDiagnostic(DeviceRegistrationDiagnosticsState state) async {
    try {
      await repository.diagnosticar(state);
    } catch (_) {
      return;
    }
  }

  static int? _statusCode(Object error) {
    if (error is DioException) {
      return error.response?.statusCode;
    }
    return null;
  }

  static String _safeError(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final type = error.type.name;
      return status == null ? 'DioException/$type' : 'HTTP $status/$type';
    }
    return error.runtimeType.toString();
  }

  static bool _isBlank(String? value) {
    return value == null || value.trim().isEmpty;
  }
}

final pushTokenProvider = Provider<PushTokenProvider>((ref) {
  return FirebasePushTokenProvider(PushNotificationService.instance);
});

final deviceRegistrationStoreProvider = Provider<DeviceRegistrationStore>((
  ref,
) {
  return DeviceRegistrationStore(ref.read(secureStorageProvider));
});

final deviceRegistrationRepositoryProvider =
    Provider<DeviceRegistrationRepository>((ref) {
      return DeviceRegistrationRepository(ref.read(dioProvider));
    });

final devicePlatformResolverProvider = Provider<DevicePlatformResolver>((ref) {
  return const DevicePlatformResolver();
});

final deviceRegistrationManagerProvider = Provider<DeviceRegistrationManager>((
  ref,
) {
  final manager = DeviceRegistrationManager(
    repository: ref.read(deviceRegistrationRepositoryProvider),
    store: ref.read(deviceRegistrationStoreProvider),
    platformResolver: ref.read(devicePlatformResolverProvider),
    diagnostics: ref.read(deviceRegistrationDiagnosticsProvider.notifier),
    requireFirebaseReady: true,
    pushTokenProviderFactory: () => ref.read(pushTokenProvider),
  );
  ref.onDispose(() {
    unawaited(manager.dispose());
  });
  return manager;
});
