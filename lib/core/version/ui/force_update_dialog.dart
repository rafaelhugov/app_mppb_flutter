import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_version_info.dart';
import '../force_update_state.dart';

class ForceUpdateDialog extends StatelessWidget {
  final ForceUpdateState state;

  const ForceUpdateDialog({
    super.key,
    required this.state,
  });

  Future<void> _abrirLoja(BuildContext context) async {
    final storeUrl = state.storeUrl.isNotEmpty
        ? state.storeUrl
        : AppVersionInfo.defaultStoreUrl;

    if (!kIsWeb && Platform.isAndroid) {
      final marketUri = Uri.parse('market://details?id=br.mp.mppbapp.app');
      try {
        if (await canLaunchUrl(marketUri)) {
          await launchUrl(marketUri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (e) {
        debugPrint('Erro ao abrir market URI: $e');
      }
    }

    final webUri = Uri.parse(storeUrl);
    try {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Erro ao abrir URL da loja: $e');
    }
  }

  String get _nomeLoja {
    if (!kIsWeb && Platform.isIOS) {
      return 'App Store';
    }
    return 'Google Play Store';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        color: Colors.black54,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 28,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE8E8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF8B4B4),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/images/brasao_mppb_sem_fundo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.system_update_rounded,
                        color: Color(0xFFC4171D),
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Atualização Necessária',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Rawline',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF202322),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ministério Público da Paraíba',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Rawline',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      state.message.isNotEmpty
                          ? state.message
                          : 'Uma nova versão do MPPB+ está disponível com importantes melhorias e correções de segurança. Atualize para continuar utilizando o aplicativo.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Rawline',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF374151),
                        height: 1.45,
                      ),
                    ),
                  ),
                  if (state.currentBuild > 0 && state.minBuild > 0) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Versão instalada: ${state.currentBuild} • Versão mínima: ${state.minBuild}',
                      style: TextStyle(
                        fontFamily: 'Rawline',
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _abrirLoja(context),
                      icon: const Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      label: Text(
                        'Atualizar na $_nomeLoja',
                        style: const TextStyle(
                          fontFamily: 'Rawline',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC4171D),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

