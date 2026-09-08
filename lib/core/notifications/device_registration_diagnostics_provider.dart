import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DeviceRegistrationStep {
  idle,
  skipped,
  requestingPermission,
  permissionResolved,
  requestingToken,
  tokenMissing,
  registering,
  registered,
  failed,
}

class DeviceRegistrationDiagnosticsState {
  final DeviceRegistrationStep step;
  final String message;
  final String? permissionStatus;
  final bool hasToken;
  final int? tokenLength;
  final int? backendStatus;
  final String? lastError;
  final DateTime? updatedAt;

  const DeviceRegistrationDiagnosticsState({
    this.step = DeviceRegistrationStep.idle,
    this.message = 'Aguardando login',
    this.permissionStatus,
    this.hasToken = false,
    this.tokenLength,
    this.backendStatus,
    this.lastError,
    this.updatedAt,
  });

  DeviceRegistrationDiagnosticsState copyWith({
    DeviceRegistrationStep? step,
    String? message,
    String? permissionStatus,
    bool? hasToken,
    int? tokenLength,
    int? backendStatus,
    String? lastError,
    DateTime? updatedAt,
    bool clearBackendStatus = false,
    bool clearLastError = false,
    bool clearTokenLength = false,
  }) {
    return DeviceRegistrationDiagnosticsState(
      step: step ?? this.step,
      message: message ?? this.message,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      hasToken: hasToken ?? this.hasToken,
      tokenLength: clearTokenLength ? null : tokenLength ?? this.tokenLength,
      backendStatus: clearBackendStatus
          ? null
          : backendStatus ?? this.backendStatus,
      lastError: clearLastError ? null : lastError ?? this.lastError,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isSuccessful => step == DeviceRegistrationStep.registered;
}

class DeviceRegistrationDiagnosticsNotifier
    extends Notifier<DeviceRegistrationDiagnosticsState> {
  @override
  DeviceRegistrationDiagnosticsState build() {
    return const DeviceRegistrationDiagnosticsState();
  }

  void update(DeviceRegistrationDiagnosticsState next) {
    state = next.copyWith(updatedAt: DateTime.now());
  }

  void reset() {
    update(const DeviceRegistrationDiagnosticsState());
  }
}

final deviceRegistrationDiagnosticsProvider =
    NotifierProvider<
      DeviceRegistrationDiagnosticsNotifier,
      DeviceRegistrationDiagnosticsState
    >(DeviceRegistrationDiagnosticsNotifier.new);
