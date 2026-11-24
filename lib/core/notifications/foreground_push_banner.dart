import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

OverlayEntry? _activeBannerEntry;
Timer? _activeBannerTimer;

void showForegroundPushBanner({
  required GlobalKey<NavigatorState> navigatorKey,
  required RemoteMessage message,
  required VoidCallback onTap,
}) {
  final title = _extractTitle(message);
  final body = _extractBody(message);
  if (title.isEmpty && body.isEmpty) {
    return;
  }

  final overlay = navigatorKey.currentState?.overlay;
  if (overlay == null) {
    return;
  }

  _dismissActiveBanner();

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _ForegroundPushBanner(
      title: title.isEmpty ? 'Nova notificação' : title,
      body: body,
      onTap: () {
        _dismissActiveBanner();
        onTap();
      },
      onDismiss: _dismissActiveBanner,
    ),
  );

  _activeBannerEntry = entry;
  overlay.insert(entry);
  _activeBannerTimer = Timer(const Duration(seconds: 5), _dismissActiveBanner);
}

void _dismissActiveBanner() {
  _activeBannerTimer?.cancel();
  _activeBannerTimer = null;
  _activeBannerEntry?.remove();
  _activeBannerEntry = null;
}

String _extractTitle(RemoteMessage message) {
  final fromNotification = message.notification?.title?.trim();
  if (fromNotification != null && fromNotification.isNotEmpty) {
    return fromNotification;
  }
  return message.data['titulo']?.toString().trim() ?? '';
}

String _extractBody(RemoteMessage message) {
  final fromNotification = message.notification?.body?.trim();
  if (fromNotification != null && fromNotification.isNotEmpty) {
    return fromNotification;
  }
  final corpo = message.data['corpo']?.toString().trim();
  if (corpo != null && corpo.isNotEmpty) {
    return corpo;
  }
  return message.data['resumo']?.toString().trim() ?? '';
}

class _ForegroundPushBanner extends StatefulWidget {
  const _ForegroundPushBanner({
    required this.title,
    required this.body,
    required this.onTap,
    required this.onDismiss,
  });

  final String title;
  final String body;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  State<_ForegroundPushBanner> createState() => _ForegroundPushBannerState();
}

class _ForegroundPushBannerState extends State<_ForegroundPushBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: SlideTransition(
            position: _offsetAnimation,
            child: Dismissible(
              key: const ValueKey('foreground-push-banner'),
              direction: DismissDirection.up,
              onDismissed: (_) => widget.onDismiss(),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2421),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFD62828).withValues(alpha: 0.45),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD62828),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (widget.body.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFD6DBD8),
                                    fontSize: 12,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: widget.onDismiss,
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF9EA6A2),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

