import 'package:flutter/material.dart';

class FeatureHeader extends StatelessWidget {
  final String category;
  final String title;
  final String description;
  final IconData icon;

  const FeatureHeader({
    super.key,
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color.fromRGBO(214, 169, 47, 0.24)),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(255, 221, 132, 0.14),
            offset: Offset(0, -1),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF241D19),
            Color(0xFF3A241D),
            Color(0xFF8F2A1D),
          ],
          stops: [0.0, 0.46, 1.0],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE5B84C), Color(0xFFA96A1D)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color.fromRGBO(255, 222, 142, 0.44)),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(36, 18, 12, 0.30),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF211713), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFE3C474),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFFFF8EA),
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    shadows: [
                      Shadow(
                        color: Color.fromRGBO(0, 0, 0, 0.22),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFFD8C5AA),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
