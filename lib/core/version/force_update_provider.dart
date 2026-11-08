import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import 'app_version_info.dart';
import 'force_update_state.dart';

class ForceUpdateNotifier extends Notifier<ForceUpdateState> {
  @override
  ForceUpdateState build() {
    return const ForceUpdateState();
  }

  void triggerForceUpdate({
    required int minBuild,
    required int currentBuild,
    String? storeUrl,
    String? message,
  }) {
    final effectiveStoreUrl = (storeUrl != null && storeUrl.isNotEmpty)
        ? storeUrl
        : AppVersionInfo.defaultStoreUrl;

    final effectiveMessage = (message != null && message.isNotEmpty)
        ? message
        : 'Uma nova versão do MPPB+ está disponível com importantes melhorias e correções. Atualize para continuar utilizando o aplicativo.';

    state = ForceUpdateState(
      isForceUpdateRequired: true,
      minBuild: minBuild,
      currentBuild: currentBuild,
      storeUrl: effectiveStoreUrl,
      message: effectiveMessage,
    );
  }

  Future<void> checkAppVersion() async {
    try {
      final dio = ref.read(dioProvider);
      final currentBuild = AppVersionInfo.appBuildNumber;
      final platform = AppVersionInfo.platformName;

      final response = await dio.get(
        '/api/public/app-versao',
        queryParameters: {
          'build': currentBuild,
          'platform': platform,
        },
        options: Options(
          extra: {'skipAuthLogout': true},
        ),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final forceUpdate = data['forceUpdate'] == true;
        if (forceUpdate) {
          triggerForceUpdate(
            minBuild: data['minBuild'] is int
                ? data['minBuild'] as int
                : int.tryParse('${data['minBuild']}') ?? 0,
            currentBuild: currentBuild,
            storeUrl: data['storeUrl']?.toString(),
            message: data['message']?.toString(),
          );
        }
      }
    } catch (e) {
      debugPrint('Verificação de versão do app ignorada ou falhou: $e');
    }
  }
}

final forceUpdateProvider =
    NotifierProvider<ForceUpdateNotifier, ForceUpdateState>(() {
  return ForceUpdateNotifier();
});
