import 'package:flutter/material.dart';

class NotificationCenterSheet {
  static void show(
    BuildContext context, {
    required int newsCount,
    required int designationsCount,
    required VoidCallback onOpenNews,
    required VoidCallback onOpenDesignations,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return NotificationCenterContent(
          newsCount: newsCount,
          designationsCount: designationsCount,
          onClose: () => Navigator.pop(ctx),
          onOpenNews: () {
            Navigator.pop(ctx);
            onOpenNews();
          },
          onOpenDesignations: () {
            Navigator.pop(ctx);
            onOpenDesignations();
          },
        );
      },
    );
  }
}

class NotificationCenterContent extends StatelessWidget {
  final int newsCount;
  final int designationsCount;
  final VoidCallback onClose;
  final VoidCallback onOpenNews;
  final VoidCallback onOpenDesignations;

  const NotificationCenterContent({
    super.key,
    required this.newsCount,
    required this.designationsCount,
    required this.onClose,
    required this.onOpenNews,
    required this.onOpenDesignations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8F6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x14101828),
            blurRadius: 40,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.notifications_rounded,
                    color: Color(0xFFD62828),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Notificações',
                      style: TextStyle(
                        color: Color(0xFF202322),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onClose,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0x1A343A40),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Color(0xFF697370),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _NotificationShortcut(
                icon: Icons.newspaper_rounded,
                title: 'Notícias',
                subtitle: _countLabel(
                  newsCount,
                  singular: 'notícia carregada',
                  plural: 'notícias carregadas',
                ),
                accentColor: const Color(0xFFD62828),
                onTap: onOpenNews,
              ),
              const SizedBox(height: 10),
              _NotificationShortcut(
                icon: Icons.assignment_ind_rounded,
                title: 'Designações',
                subtitle: _countLabel(
                  designationsCount,
                  singular: 'designação ativa',
                  plural: 'designações ativas',
                ),
                accentColor: const Color(0xFF2563EB),
                onTap: onOpenDesignations,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _countLabel(
    int value, {
    required String singular,
    String? plural,
  }) {
    if (value == 1) {
      return '1 $singular';
    }
    return '$value ${plural ?? '${singular}s'}';
  }
}

class _NotificationShortcut extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _NotificationShortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x26343A40)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF202322),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF697370),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF8A9490),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
