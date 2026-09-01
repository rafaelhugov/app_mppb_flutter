import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ouvidoria_provider.dart';
import 'ouvidoria_form_style.dart';

class CaptchaWidget extends ConsumerWidget {
  const CaptchaWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ouvidoriaProvider);
    final notifier = ref.read(ouvidoriaProvider.notifier);

    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(color: OuvidoriaFormStyle.accent),
        ),
      );
    }

    if (state.captchaData == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OuvidoriaFormStyle.surface,
        border: Border.all(color: OuvidoriaFormStyle.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verificação de Segurança',
            style: TextStyle(
              color: OuvidoriaFormStyle.ink,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.memory(
                  state.captchaData!.imageBytes,
                  width: 250,
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: OuvidoriaFormStyle.accent,
                ),
                onPressed: () => notifier.loadCaptcha(),
                tooltip: 'Recarregar Captcha',
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: OuvidoriaFormStyle.inputDecoration(
              labelText: 'Digite o código da imagem acima',
            ),
            onChanged: (val) =>
                notifier.updateField((m) => m.userEnteredCaptchaCode = val),
          ),
        ],
      ),
    );
  }
}
