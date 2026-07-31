import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

import '../providers/privacy_provider.dart';

class PrivacyToggleButton extends ConsumerStatefulWidget {
  const PrivacyToggleButton({super.key, this.size = 50});

  final double size;

  @override
  ConsumerState<PrivacyToggleButton> createState() =>
      _PrivacyToggleButtonState();
}

class _PrivacyToggleButtonState extends ConsumerState<PrivacyToggleButton> {
  final _tooltipController = JustTheController();
  static bool _hasShownTooltip = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted || _hasShownTooltip || !ref.read(privacyProvider)) return;

      _hasShownTooltip = true;
      _tooltipController.showTooltip();
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted) _tooltipController.hideTooltip();
      });
    });
  }

  @override
  void dispose() {
    _tooltipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPrivacyEnabled = ref.watch(privacyProvider);
    final label = isPrivacyEnabled ? 'Exibir valores' : 'Ocultar valores';

    return Semantics(
      button: true,
      label: label,
      child: JustTheTooltip(
        controller: _tooltipController,
        isModal: false,
        barrierDismissible: false,
        triggerMode: TooltipTriggerMode.manual,
        showDuration: const Duration(seconds: 30),
        tailLength: 10,
        tailBaseWidth: 16,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF8F2A1D),
        content: InkWell(
          onTap: _tooltipController.hideTooltip,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'Os valores estão ocultos. Toque no olho para exibir.',
              style: TextStyle(
                color: Color(0xFFFFF8EA),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        child: InkWell(
          onTap: () {
            ref.read(privacyProvider.notifier).toggle();
            _tooltipController.hideTooltip();
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: widget.size,
            height: widget.size,
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
              size: widget.size * 0.50,
            ),
          ),
        ),
      ),
    );
  }
}
