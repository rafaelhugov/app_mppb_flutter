import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HeroHeaderPublico extends StatelessWidget {
  final String label;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? rightWidget;

  const HeroHeaderPublico({
    super.key,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.rightWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            child: IconButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17),
              color: const Color(0xFF5C5146),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0x0A101828),
                fixedSize: const Size(32, 32),
                minimumSize: const Size(32, 32),
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
              ),
              visualDensity: VisualDensity.compact,
              tooltip: 'Voltar',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF241D19),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
          ),
          if (rightWidget != null)
            Positioned(
              right: 6,
              child: Align(
                alignment: Alignment.centerRight,
                child: rightWidget!,
              ),
            ),
        ],
      ),
    );
  }
}
