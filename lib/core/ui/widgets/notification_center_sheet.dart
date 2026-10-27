import 'package:flutter/material.dart';

import '../../notifications/device_registration_diagnostics_provider.dart';
import '../../notifications/notification_center_provider.dart';
import '../responsive_layout.dart';

class NotificationCenterSheet {
  static void show(
    BuildContext context, {
    required List<NotificationCenterItem> items,
    required ValueChanged<NotificationCenterItem> onOpenItem,
    VoidCallback? onMarkAllAsRead,
    DeviceRegistrationDiagnosticsState? deviceDiagnostics,
    VoidCallback? onRetryDeviceRegistration,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return NotificationCenterContent(
          items: items,
          onClose: () => Navigator.pop(ctx),
          onOpenItem: (item) {
            Navigator.pop(ctx);
            onOpenItem(item);
          },
          onMarkAllAsRead: onMarkAllAsRead,
          deviceDiagnostics: deviceDiagnostics,
          onRetryDeviceRegistration: onRetryDeviceRegistration,
        );
      },
    );
  }
}

class NotificationCenterContent extends StatefulWidget {
  final List<NotificationCenterItem> items;
  final VoidCallback onClose;
  final ValueChanged<NotificationCenterItem> onOpenItem;
  final VoidCallback? onMarkAllAsRead;
  final DeviceRegistrationDiagnosticsState? deviceDiagnostics;
  final VoidCallback? onRetryDeviceRegistration;

  const NotificationCenterContent({
    super.key,
    required this.items,
    required this.onClose,
    required this.onOpenItem,
    this.onMarkAllAsRead,
    this.deviceDiagnostics,
    this.onRetryDeviceRegistration,
  });

  @override
  State<NotificationCenterContent> createState() =>
      _NotificationCenterContentState();
}

class _NotificationCenterContentState extends State<NotificationCenterContent> {
  static const int _previewLimit = 4;

  bool _showAllNews = false;
  bool _showAllDesignations = false;
  bool _showAllPayslips = false;
  bool _showAllPayments = false;
  bool _showAllLeaves = false;

  @override
  Widget build(BuildContext context) {
    final responsive = MppbResponsive.of(context);
    final maxWidth = responsive.usesWideLayout
        ? 860.0
        : responsive.isTablet
        ? 760.0
        : double.infinity;
    final heightFactor = responsive.isTablet ? 0.88 : 0.92;
    final newsItems = widget.items
        .where((item) => item.type == NotificationCenterItemType.noticia)
        .toList();
    final designationItems = widget.items
        .where((item) => item.type == NotificationCenterItemType.designacao)
        .toList();
    final payslipItems = widget.items
        .where((item) => item.type == NotificationCenterItemType.contracheque)
        .toList();
    final paymentItems = widget.items
        .where((item) => item.type == NotificationCenterItemType.pagamento)
        .toList();
    final leaveItems = widget.items
        .where((item) => item.type == NotificationCenterItemType.afastamento)
        .toList();

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: FractionallySizedBox(
          widthFactor: 1,
          heightFactor: heightFactor,
          child: Container(
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
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      responsive.isTablet ? 24 : 20,
                      responsive.isTablet ? 22 : 20,
                      responsive.isTablet ? 24 : 20,
                      14,
                    ),
                    child: Row(
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
                        if (widget.items.any((item) => !item.isRead) &&
                            widget.onMarkAllAsRead != null) ...[
                          TextButton.icon(
                            onPressed: widget.onMarkAllAsRead,
                            icon: const Icon(Icons.done_all_rounded, size: 16),
                            label: const Text('Marcar lidas'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF047857),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
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
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.only(
                        left: responsive.isTablet ? 24 : 20,
                        right: responsive.isTablet ? 24 : 20,
                        bottom: 28,
                      ),
                      children: [
                        if (widget.items.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0x26343A40),
                              ),
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
                                  () => _showAllDesignations =
                                      !_showAllDesignations,
                                );
                              },
                              onOpenItem: widget.onOpenItem,
                            ),
                          if (payslipItems.isNotEmpty)
                            _NotificationGroup(
                              title: 'Contracheques',
                              count: payslipItems.length,
                              icon: Icons.receipt_long_rounded,
                              accentColor: const Color(0xFF7C3AED),
                              items: payslipItems,
                              previewLimit: _previewLimit,
                              showAll: _showAllPayslips,
                              onToggleShowAll: () {
                                setState(
                                  () => _showAllPayslips = !_showAllPayslips,
                                );
                              },
                              onOpenItem: widget.onOpenItem,
                            ),
                          if (paymentItems.isNotEmpty)
                            _NotificationGroup(
                              title: 'Pagamentos',
                              count: paymentItems.length,
                              icon: Icons.payments_rounded,
                              accentColor: const Color(0xFF047857),
                              items: paymentItems,
                              previewLimit: _previewLimit,
                              showAll: _showAllPayments,
                              onToggleShowAll: () {
                                setState(
                                  () => _showAllPayments = !_showAllPayments,
                                );
                              },
                              onOpenItem: widget.onOpenItem,
                            ),
                          if (leaveItems.isNotEmpty)
                            _NotificationGroup(
                              title: 'Afastamentos',
                              count: leaveItems.length,
                              icon: Icons.event_busy_rounded,
                              accentColor: const Color(0xFFB45309),
                              items: leaveItems,
                              previewLimit: _previewLimit,
                              showAll: _showAllLeaves,
                              onToggleShowAll: () {
                                setState(
                                  () => _showAllLeaves = !_showAllLeaves,
                                );
                              },
                              onOpenItem: widget.onOpenItem,
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
    final responsive = MppbResponsive.of(context);
    final visibleItems = showAll ? items : items.take(previewLimit).toList();
    final hiddenCount = items.length - visibleItems.length;
    final useGrid = responsive.usesWideLayout && visibleItems.length > 1;
    final gridItemHeight = responsive.isTablet ? 104.0 : 92.0;

    final unreadCount = items.where((item) => !item.isRead).length;

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
                _CountBadge(
                  count: unreadCount > 0 ? unreadCount : count,
                  color: accentColor,
                  isUnread: unreadCount > 0,
                ),
              ],
            ),
          ),
          if (useGrid)
            GridView.builder(
              padding: EdgeInsets.zero,
              itemCount: visibleItems.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: gridItemHeight,
              ),
              itemBuilder: (context, index) {
                final item = visibleItems[index];
                return _NotificationShortcut(
                  icon: icon,
                  title: item.title,
                  subtitle: item.subtitle,
                  imageUrl: item.imageUrl,
                  isRead: item.isRead,
                  accentColor: accentColor,
                  onTap: () => onOpenItem(item),
                );
              },
            )
          else
            ...visibleItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _NotificationShortcut(
                  icon: icon,
                  title: item.title,
                  subtitle: item.subtitle,
                  imageUrl: item.imageUrl,
                  isGridItem: true,
                  isRead: item.isRead,
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
  final bool isUnread;

  const _CountBadge({
    required this.count,
    required this.color,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 24, minHeight: 22),
      padding: const EdgeInsets.symmetric(horizontal: 7),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isUnread ? color : color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(
          color: isUnread ? Colors.white : color,
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
  final bool isGridItem;
  final bool isRead;
  final Color accentColor;
  final VoidCallback onTap;

  const _NotificationShortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.isGridItem = false,
    this.isRead = false,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isRead ? const Color(0xFFF0F2F1) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: BoxConstraints(minHeight: isGridItem ? 92 : 72),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isRead
                  ? const Color(0x1F343A40)
                  : accentColor.withValues(alpha: 0.35),
              width: isRead ? 1.0 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Opacity(
                opacity: isRead ? 0.72 : 1.0,
                child: _NotificationLeading(
                  icon: icon,
                  imageUrl: imageUrl,
                  accentColor: accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (!isRead) ...[
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                        Expanded(
                          child: Text(
                            title,
                            maxLines: isGridItem ? 3 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isRead
                                  ? const Color(0xFF555E5B)
                                  : const Color(0xFF202322),
                              fontSize: 14,
                              fontWeight: isRead
                                  ? FontWeight.w600
                                  : FontWeight.w900,
                              height: 1.18,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: isGridItem ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isRead
                            ? const Color(0xFF828E8A)
                            : const Color(0xFF697370),
                        fontSize: 12,
                        fontWeight: isRead
                            ? FontWeight.w500
                            : FontWeight.w600,
                        height: 1.2,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isRead
                    ? const Color(0xFFAAB3B0)
                    : const Color(0xFF8A9490),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
