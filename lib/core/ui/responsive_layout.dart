import 'dart:math' as math;

import 'package:flutter/widgets.dart';

enum MppbWindowClass {
  compact,
  medium,
  expanded,
  large;

  bool get isTablet => this == medium || this == expanded || this == large;

  bool get usesWideLayout => this == expanded || this == large;
}

class MppbResponsiveMetrics {
  const MppbResponsiveMetrics({
    required this.windowClass,
    required this.size,
    required this.orientation,
    required this.horizontalPadding,
    required this.contentMaxWidth,
    required this.gridColumns,
    required this.cardGridColumns,
    required this.isLandscape,
  });

  final MppbWindowClass windowClass;
  final Size size;
  final Orientation orientation;
  final double horizontalPadding;
  final double contentMaxWidth;
  final int gridColumns;
  final int cardGridColumns;
  final bool isLandscape;

  bool get isTablet => windowClass.isTablet;

  bool get usesWideLayout => windowClass.usesWideLayout;

  double constrainedWidth({double? maxWidth}) {
    return math.min(size.width, maxWidth ?? contentMaxWidth);
  }
}

class MppbResponsive {
  static const double compactBreakpoint = 600;
  static const double mediumBreakpoint = 840;
  static const double expandedBreakpoint = 1200;

  static MppbWindowClass classifyWidth(double width) {
    if (width >= expandedBreakpoint) return MppbWindowClass.large;
    if (width >= mediumBreakpoint) return MppbWindowClass.expanded;
    if (width >= compactBreakpoint) return MppbWindowClass.medium;
    return MppbWindowClass.compact;
  }

  static MppbResponsiveMetrics of(BuildContext context) {
    final mediaQuery = MediaQuery.sizeOf(context);
    final orientation = MediaQuery.orientationOf(context);
    return fromSize(mediaQuery, orientation: orientation);
  }

  static MppbResponsiveMetrics fromSize(Size size, {Orientation? orientation}) {
    final windowClass = classifyWidth(size.width);
    final resolvedOrientation =
        orientation ??
        (size.width >= size.height
            ? Orientation.landscape
            : Orientation.portrait);
    final isLandscape = resolvedOrientation == Orientation.landscape;

    return MppbResponsiveMetrics(
      windowClass: windowClass,
      size: size,
      orientation: resolvedOrientation,
      horizontalPadding: _horizontalPadding(windowClass),
      contentMaxWidth: _contentMaxWidth(windowClass, isLandscape),
      gridColumns: _gridColumns(windowClass, isLandscape),
      cardGridColumns: _cardGridColumns(windowClass, isLandscape),
      isLandscape: isLandscape,
    );
  }

  static double _horizontalPadding(MppbWindowClass windowClass) {
    return switch (windowClass) {
      MppbWindowClass.compact => 20,
      MppbWindowClass.medium => 28,
      MppbWindowClass.expanded => 40,
      MppbWindowClass.large => 56,
    };
  }

  static double _contentMaxWidth(
    MppbWindowClass windowClass,
    bool isLandscape,
  ) {
    return switch (windowClass) {
      MppbWindowClass.compact => 760,
      MppbWindowClass.medium => isLandscape ? 900 : 760,
      MppbWindowClass.expanded => 1080,
      MppbWindowClass.large => 1240,
    };
  }

  static int _gridColumns(MppbWindowClass windowClass, bool isLandscape) {
    return switch (windowClass) {
      MppbWindowClass.compact => 2,
      MppbWindowClass.medium => isLandscape ? 3 : 2,
      MppbWindowClass.expanded => 3,
      MppbWindowClass.large => 4,
    };
  }

  static int _cardGridColumns(MppbWindowClass windowClass, bool isLandscape) {
    return switch (windowClass) {
      MppbWindowClass.compact => 1,
      MppbWindowClass.medium => isLandscape ? 2 : 1,
      MppbWindowClass.expanded => 2,
      MppbWindowClass.large => 3,
    };
  }
}

class MppbResponsiveCenter extends StatelessWidget {
  const MppbResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final metrics = MppbResponsive.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? metrics.contentMaxWidth,
        ),
        child: Padding(
          padding:
              padding ??
              EdgeInsets.symmetric(horizontal: metrics.horizontalPadding),
          child: child,
        ),
      ),
    );
  }
}
