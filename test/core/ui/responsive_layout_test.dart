import 'package:app_mppb_flutter/core/ui/responsive_layout.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MppbResponsive', () {
    test('classifica larguras por breakpoint', () {
      expect(MppbResponsive.classifyWidth(359), MppbWindowClass.compact);
      expect(MppbResponsive.classifyWidth(600), MppbWindowClass.medium);
      expect(MppbResponsive.classifyWidth(840), MppbWindowClass.expanded);
      expect(MppbResponsive.classifyWidth(1200), MppbWindowClass.large);
    });

    test('mantem layout compacto para celular', () {
      final metrics = MppbResponsive.fromSize(const Size(390, 844));

      expect(metrics.windowClass, MppbWindowClass.compact);
      expect(metrics.isTablet, isFalse);
      expect(metrics.usesWideLayout, isFalse);
      expect(metrics.horizontalPadding, 20);
      expect(metrics.gridColumns, 2);
      expect(metrics.cardGridColumns, 1);
    });

    test('amplia grid em tablet paisagem', () {
      final metrics = MppbResponsive.fromSize(const Size(1024, 768));

      expect(metrics.windowClass, MppbWindowClass.expanded);
      expect(metrics.isTablet, isTrue);
      expect(metrics.usesWideLayout, isTrue);
      expect(metrics.isLandscape, isTrue);
      expect(metrics.horizontalPadding, 40);
      expect(metrics.contentMaxWidth, 1080);
      expect(metrics.gridColumns, 3);
      expect(metrics.cardGridColumns, 2);
    });

    test('usa mais colunas em tablet grande', () {
      final metrics = MppbResponsive.fromSize(const Size(1366, 912));

      expect(metrics.windowClass, MppbWindowClass.large);
      expect(metrics.horizontalPadding, 56);
      expect(metrics.contentMaxWidth, 1240);
      expect(metrics.gridColumns, 4);
      expect(metrics.cardGridColumns, 3);
    });
  });
}
