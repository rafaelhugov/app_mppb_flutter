import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/privacy_provider.dart';

class PrivacyToggleButton extends ConsumerWidget {
  const PrivacyToggleButton({super.key, this.size = 50});

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacyEnabled = ref.watch(privacyProvider);

    return Semantics(
      button: true,
      label: isPrivacyEnabled ? 'Exibir valores' : 'Ocultar valores',
      child: InkWell(
        onTap: () => ref.read(privacyProvider.notifier).toggle(),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE5B84C), Color(0xFFA96A1D)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x70FFDE8E)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4C24120C),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            isPrivacyEnabled
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: const Color(0xFF211713),
            size: size * 0.50,
          ),
        ),
      ),
    );
  }
}
