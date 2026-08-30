import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ouvidoria_provider.dart';

class CaptchaWidget extends ConsumerWidget {
  const CaptchaWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ouvidoriaProvider);
    final notifier = ref.read(ouvidoriaProvider.notifier);

    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF8F2A1D))),
      );
    }

    if (state.captchaData == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color.fromRGBO(214, 169, 47, 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Verificação de Segurança', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Image.memory(
                  state.captchaData!.imageBytes,
                  width: 250,
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF8F2A1D)),
                onPressed: () => notifier.loadCaptcha(),
                tooltip: 'Recarregar Captcha',
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Digite o código da imagem acima',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => notifier.updateField((m) => m.userEnteredCaptchaCode = val),
          ),
        ],
      ),
    );
  }
}
