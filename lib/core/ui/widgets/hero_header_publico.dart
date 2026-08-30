import 'package:flutter/material.dart';
import '../mppb_app_bar.dart';

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
    final topPadding =
        MediaQuery.paddingOf(context).top + MppbAppBar.altura + 8;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22, topPadding, 22, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x3DD6A92F), width: 1)),
        gradient: LinearGradient(
          colors: [Color(0xFF241D19), Color(0xFF3A241D), Color(0xFF8F2A1D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.46, 1.0],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE5B84C), Color(0xFFA96A1D)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color.fromRGBO(255, 222, 142, 0.44),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(36, 18, 12, 0.30),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF211713), size: 25),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // COMPACT HEIGHT
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFE3C474),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                    height: 1.05,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    height: 1.03,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withAlpha(217),
                    fontSize: 14,
                    height: 1.18,
                  ),
                ),
              ],
            ),
          ),
          if (rightWidget != null) ...[
            const SizedBox(width: 8),
            Align(alignment: Alignment.centerRight, child: rightWidget!),
          ],
        ],
      ),
    );
  }
}
