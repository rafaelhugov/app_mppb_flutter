import 'dart:ui';

import 'package:flutter/material.dart';

class PrivacyBlurText extends StatelessWidget {
  final String text;
  final bool enabled;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;
  final TextAlign? textAlign;
  final double sigma;

  const PrivacyBlurText({
    super.key,
    required this.text,
    required this.enabled,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
    this.sigma = 4.5,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;
    final content = Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: effectiveStyle,
    );

    if (!enabled) {
      return content;
    }

    final foregroundColor = effectiveStyle.color ?? const Color(0xFF202322);
    final hazeColor = Color.lerp(foregroundColor, Colors.white, 0.22)!;
    final alignment = switch (textAlign) {
      TextAlign.center => Alignment.center,
      TextAlign.right || TextAlign.end => Alignment.centerRight,
      _ => Alignment.centerLeft,
    };

    return Stack(
      alignment: alignment,
      children: [
        Opacity(opacity: 0, child: content),
        Positioned.fill(
          child: Align(
            alignment: alignment,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: sigma + 5,
                sigmaY: sigma + 4,
              ),
              child: FractionallySizedBox(
                widthFactor: 0.96,
                heightFactor: 0.72,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: foregroundColor.withAlpha(118),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: alignment,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: sigma + 2,
                sigmaY: sigma + 2,
              ),
              child: FractionallySizedBox(
                widthFactor: 0.78,
                heightFactor: 0.52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        foregroundColor.withAlpha(96),
                        hazeColor.withAlpha(172),
                        foregroundColor.withAlpha(92),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: alignment,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: sigma + 8,
                sigmaY: sigma + 1,
              ),
              child: FractionallySizedBox(
                widthFactor: 0.58,
                heightFactor: 0.88,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: foregroundColor.withAlpha(58),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
