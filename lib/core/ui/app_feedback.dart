import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

enum AppFeedbackType { success, error, warning, info, loading }

class AppFeedbackHandle {
  AppFeedbackHandle._(this._entry);

  final OverlayEntry _entry;
  bool _dismissed = false;

  void dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _entry.remove();
  }
}

class AppFeedback {
  AppFeedback._();

  static AppFeedbackHandle? _current;

  static AppFeedbackHandle show(
    BuildContext context, {
    required String title,
    String? message,
    AppFeedbackType type = AppFeedbackType.info,
    Duration duration = const Duration(milliseconds: 2200),
  }) {
    return _show(
      context,
      title: title,
      message: message,
      type: type,
      duration: duration,
      dismissible: true,
    );
  }

  static AppFeedbackHandle showSuccess(
    BuildContext context,
    String message, {
    String title = 'Tudo certo',
  }) {
    return show(
      context,
      title: title,
      message: message,
      type: AppFeedbackType.success,
    );
  }

  static AppFeedbackHandle showError(
    BuildContext context,
    String message, {
    String title = 'Não foi possível concluir',
  }) {
    return show(
      context,
      title: title,
      message: message,
      type: AppFeedbackType.error,
      duration: const Duration(milliseconds: 3200),
    );
  }

  static AppFeedbackHandle showWarning(
    BuildContext context,
    String message, {
    String title = 'Atenção',
  }) {
    return show(
      context,
      title: title,
      message: message,
      type: AppFeedbackType.warning,
      duration: const Duration(milliseconds: 2800),
    );
  }

  static AppFeedbackHandle showLoading(
    BuildContext context, {
    String title = 'Processando',
    String? message,
  }) {
    return _show(
      context,
      title: title,
      message: message,
      type: AppFeedbackType.loading,
      dismissible: false,
      blocksInteraction: true,
    );
  }

  static AppFeedbackHandle _show(
    BuildContext context, {
    required String title,
    String? message,
    required AppFeedbackType type,
    Duration? duration,
    required bool dismissible,
    bool blocksInteraction = false,
  }) {
    _current?.dismiss();

    late final AppFeedbackHandle handle;
    final overlay = Overlay.of(context, rootOverlay: true);
    final entry = OverlayEntry(
      builder: (_) => _AppFeedbackOverlay(
        title: title,
        message: message,
        type: type,
        blocksInteraction: blocksInteraction,
        onDismiss: dismissible ? () => handle.dismiss() : null,
      ),
    );
    handle = AppFeedbackHandle._(entry);
    _current = handle;
    overlay.insert(entry);

    if (duration != null) {
      Timer(duration, handle.dismiss);
    }

    return handle;
  }
}

class _AppFeedbackOverlay extends StatefulWidget {
  const _AppFeedbackOverlay({
    required this.title,
    required this.type,
    required this.blocksInteraction,
    this.message,
    this.onDismiss,
  });

  final String title;
  final String? message;
  final AppFeedbackType type;
  final bool blocksInteraction;
  final VoidCallback? onDismiss;

  @override
  State<_AppFeedbackOverlay> createState() => _AppFeedbackOverlayState();
}

class _AppFeedbackOverlayState extends State<_AppFeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.86, end: 1).animate(curve);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _feedbackConfig(widget.type);
    final message = widget.message?.trim();
    final content = SafeArea(
      child: Center(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: ScaleTransition(
              scale: _scale,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 360),
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAF7),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE0E5E3)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33101828),
                        blurRadius: 34,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _FeedbackIcon(config: config, type: widget.type),
                      const SizedBox(height: 20),
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF202322),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      if (message != null && message.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF697370),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ],
                      if (widget.onDismiss != null) ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: widget.onDismiss,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF202322),
                              foregroundColor: const Color(0xFFF7F8F6),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('OK'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final overlay = Stack(
      fit: StackFit.expand,
      children: [
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.5, sigmaY: 5.5),
            child: Container(color: const Color(0x52000000)),
          ),
        ),
        content,
      ],
    );

    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: widget.blocksInteraction
            ? AbsorbPointer(child: overlay)
            : IgnorePointer(ignoring: widget.onDismiss == null, child: overlay),
      ),
    );
  }
}

class _FeedbackIcon extends StatefulWidget {
  const _FeedbackIcon({required this.config, required this.type});

  final _FeedbackConfig config;
  final AppFeedbackType type;

  @override
  State<_FeedbackIcon> createState() => _FeedbackIconState();
}

class _FeedbackIconState extends State<_FeedbackIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.96,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.config.color;
    return ScaleTransition(
      scale: _pulse,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: color.withAlpha(24),
          shape: BoxShape.circle,
          border: Border.all(color: color.withAlpha(70)),
        ),
        child: Center(
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(80),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: widget.type == AppFeedbackType.loading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(widget.config.icon, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}

class _FeedbackConfig {
  const _FeedbackConfig({required this.color, required this.icon});

  final Color color;
  final IconData icon;
}

_FeedbackConfig _feedbackConfig(AppFeedbackType type) {
  switch (type) {
    case AppFeedbackType.success:
      return const _FeedbackConfig(
        color: Color(0xFF00A76F),
        icon: Icons.check_rounded,
      );
    case AppFeedbackType.error:
      return const _FeedbackConfig(
        color: Color(0xFFD62828),
        icon: Icons.close_rounded,
      );
    case AppFeedbackType.warning:
      return const _FeedbackConfig(
        color: Color(0xFFFF8A00),
        icon: Icons.priority_high_rounded,
      );
    case AppFeedbackType.info:
      return const _FeedbackConfig(
        color: Color(0xFF2563EB),
        icon: Icons.info_rounded,
      );
    case AppFeedbackType.loading:
      return const _FeedbackConfig(
        color: Color(0xFF202322),
        icon: Icons.hourglass_top_rounded,
      );
  }
}
