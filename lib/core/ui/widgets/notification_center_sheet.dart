import 'package:flutter/material.dart';

import '../../notifications/notification_center_provider.dart';

class NotificationCenterSheet {
  static void show(
    BuildContext context, {
    required List<NotificationCenterItem> items,
    required ValueChanged<NotificationCenterItem> onOpenItem,
    required VoidCallback onClearAll,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return NotificationCenterContent(
          items: items,
          onClose: () => Navigator.pop(ctx),
          onClearAll: () {
            onClearAll();
            Navigator.pop(ctx);
          },
          onOpenItem: (item) {
            Navigator.pop(ctx);
            onOpenItem(item);
          },
        );
      },
    );
  }
}

class NotificationCenterContent extends StatefulWidget {
  final List<NotificationCenterItem> items;
  final VoidCallback onClose;
  final VoidCallback onClearAll;
  final ValueChanged<NotificationCenterItem> onOpenItem;

  const NotificationCenterContent({
    super.key,
    required this.items,
    required this.onClose,
    required this.onClearAll,
    required this.onOpenItem,
  });

  @override
  State<NotificationCenterContent> createState() =>
      _NotificationCenterContentState();
}

class _NotificationCenterContentState extends State<NotificationCenterContent> {
  static const int _previewLimit = 4;

  bool _showAllNews = false;
  bool _showAllDesignations = false;

  @override
  Widget build(BuildContext context) {
    final newsItems = widget.items
        .where((item) => item.type == NotificationCenterItemType.noticia)
        .toList();
    final designationItems = widget.items
        .where((item) => item.type == NotificationCenterItemType.designacao)
        .toList();

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
                  if (widget.items.isNotEmpty)
                    TextButton(
                      onPressed: widget.onClearAll,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFD62828),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Limpar tudo'),
                    ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: widget.onClose,
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
              if (widget.items.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x26343A40)),
                  ),
                  child: const Text(
                    'Nenhuma notificação nova',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF697370),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                )
              else ...[
                if (newsItems.isNotEmpty)
                  _NotificationGroup(
                    title: 'Notícias',
                    count: newsItems.length,
                    icon: Icons.newspaper_rounded,
                    accentColor: const Color(0xFFD62828),
                    items: newsItems,
                    previewLimit: _previewLimit,
                    showAll: _showAllNews,
                    onToggleShowAll: () {
                      setState(() => _showAllNews = !_showAllNews);
                    },
                    onOpenItem: widget.onOpenItem,
                  ),
                if (designationItems.isNotEmpty)
                  _NotificationGroup(
                    title: 'Designações',
                    count: designationItems.length,
                    icon: Icons.assignment_ind_rounded,
                    accentColor: const Color(0xFF2563EB),
                    items: designationItems,
                    previewLimit: _previewLimit,
                    showAll: _showAllDesignations,
                    onToggleShowAll: () {
                      setState(
                        () => _showAllDesignations = !_showAllDesignations,
                      );
                    },
                    onOpenItem: widget.onOpenItem,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationGroup extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color accentColor;
  final List<NotificationCenterItem> items;
  final int previewLimit;
  final bool showAll;
  final VoidCallback onToggleShowAll;
  final ValueChanged<NotificationCenterItem> onOpenItem;

  const _NotificationGroup({
    required this.title,
    required this.count,
    required this.icon,
    required this.accentColor,
    required this.items,
    required this.previewLimit,
    required this.showAll,
    required this.onToggleShowAll,
    required this.onOpenItem,
  });

  @override
  Widget build(BuildContext context) {
    final visibleItems = showAll ? items : items.take(previewLimit).toList();
    final hiddenCount = items.length - visibleItems.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, right: 2, bottom: 8),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF202322),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                _CountBadge(count: count, color: accentColor),
              ],
            ),
          ),
          ...visibleItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _NotificationShortcut(
                icon: icon,
                title: item.title,
                subtitle: item.subtitle,
                imageUrl: item.imageUrl,
                accentColor: accentColor,
                onTap: () => onOpenItem(item),
              ),
            ),
          ),
          if (hiddenCount > 0 || showAll)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onToggleShowAll,
                icon: Icon(
                  showAll
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 18,
                ),
                label: Text(showAll ? 'Ver menos' : 'Ver todas ($hiddenCount)'),
                style: TextButton.styleFrom(
                  foregroundColor: accentColor,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final Color color;

  const _CountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 24, minHeight: 22),
      padding: const EdgeInsets.symmetric(horizontal: 7),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _NotificationLeading extends StatelessWidget {
  final IconData icon;
  final String? imageUrl;
  final Color accentColor;

  const _NotificationLeading({
    required this.icon,
    required this.imageUrl,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _IconFallback(icon: icon, accentColor: accentColor);
          },
        ),
      );
    }

    return _IconFallback(icon: icon, accentColor: accentColor);
  }
}

class _IconFallback extends StatelessWidget {
  final IconData icon;
  final Color accentColor;

  const _IconFallback({required this.icon, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: accentColor, size: 22),
    );
  }
}

class _NotificationShortcut extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final Color accentColor;
  final VoidCallback onTap;

  const _NotificationShortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.imageUrl,
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
              _NotificationLeading(
                icon: icon,
                imageUrl: imageUrl,
                accentColor: accentColor,
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
