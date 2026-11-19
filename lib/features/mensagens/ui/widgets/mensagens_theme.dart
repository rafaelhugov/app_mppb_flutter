import 'package:flutter/material.dart';

class MensagensColors {
  static const background = Color(0xFFF7F8F6);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF3F5F2);
  static const border = Color(0xFFE9EDF0);
  static const ink = Color(0xFF202322);
  static const headerInk = Color(0xFF241D19);
  static const muted = Color(0xFF697370);
  static const brandDark = Color(0xFF202322);
  static const pillUnselectedText = Color(0xFFDDE4DF);

  static const green = Color(0xFF00A86B);
  static const red = Color(0xFFD62828);
  static const orange = Color(0xFFF97316);
  static const blue = Color(0xFF2563EB);
}

class MensagensSegmentItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const MensagensSegmentItem({
    required this.value,
    required this.label,
    this.icon,
  });
}

class MensagensSegmentedPillBar<T> extends StatelessWidget {
  final List<MensagensSegmentItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final double maxWidth;

  const MensagensSegmentedPillBar({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    this.maxWidth = 360,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: MensagensColors.brandDark,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0x66FFFFFF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2A101828),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: items.map((item) {
              final selected = item.value == selectedValue;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelected(item.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: selected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (item.icon != null) ...[
                          Icon(
                            item.icon,
                            size: 15,
                            color: selected
                                ? MensagensColors.ink
                                : MensagensColors.pillUnselectedText,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected
                                  ? MensagensColors.ink
                                  : MensagensColors.pillUnselectedText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class MensagensHeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? backgroundColor;

  const MensagensHeaderIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      color: iconColor ?? const Color(0xFF5C5146),
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor ?? const Color(0x0A101828),
        fixedSize: const Size(32, 32),
        minimumSize: const Size(32, 32),
        padding: EdgeInsets.zero,
        shape: const CircleBorder(),
      ),
      visualDensity: VisualDensity.compact,
      tooltip: tooltip,
    );
  }
}

class MensagensErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final IconData icon;

  const MensagensErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon = Icons.wifi_off,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 42,
              color: MensagensColors.brandDark,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: MensagensColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: MensagensColors.brandDark,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text(
                'Tentar novamente',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MensagensEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const MensagensEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.mark_chat_read_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 42,
              color: MensagensColors.muted,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: MensagensColors.muted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

