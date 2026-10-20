import 'dart:convert';

import 'package:app_mppb_flutter/core/ui/widgets/pdf_pinch_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:printing/printing.dart';

void main() {
  testWidgets('visualizador do diario permite zoom de pinca ate cinco vezes', (
    tester,
  ) async {
    final page = PdfPreviewPageData(
      image: MemoryImage(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
        ),
      ),
      width: 1,
      height: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 700,
            child: PdfPinchViewer(pages: [page]),
          ),
        ),
      ),
    );

    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(viewer.minScale, 1);
    expect(viewer.maxScale, 5);
    expect(find.text('Use dois dedos para ampliar'), findsOneWidget);

    final center = tester.getCenter(find.byType(InteractiveViewer));
    final firstFinger = await tester.startGesture(
      center - const Offset(20, 0),
      pointer: 1,
    );
    final secondFinger = await tester.startGesture(
      center + const Offset(20, 0),
      pointer: 2,
    );
    await firstFinger.moveTo(center - const Offset(90, 0));
    await secondFinger.moveTo(center + const Offset(90, 0));
    await tester.pump();
    await firstFinger.up();
    await secondFinger.up();
    await tester.pump();

    expect(find.byTooltip('Restaurar zoom'), findsOneWidget);

    await tester.tap(find.byTooltip('Restaurar zoom'));
    await tester.pump();

    expect(find.byTooltip('Restaurar zoom'), findsNothing);
  });
}
