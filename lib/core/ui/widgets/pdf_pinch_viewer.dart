import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfPinchViewer extends StatefulWidget {
  const PdfPinchViewer({
    super.key,
    required this.pages,
    this.documentLabel = 'PDF',
  });

  final List<PdfPreviewPageData> pages;
  final String documentLabel;

  @override
  State<PdfPinchViewer> createState() => _PdfPinchViewerState();
}

class _PdfPinchViewerState extends State<PdfPinchViewer> {
  final TransformationController _transformationController =
      TransformationController();
  bool _isZoomed = false;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _updateZoomState() {
    final isZoomed = _transformationController.value.getMaxScaleOnAxis() > 1.01;
    if (isZoomed != _isZoomed) {
      setState(() => _isZoomed = isZoomed);
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    _updateZoomState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: Semantics(
                label:
                    'Visualizador de ${widget.documentLabel}. Use dois dedos para ampliar ou reduzir e arraste para navegar.',
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  constrained: false,
                  minScale: 1,
                  maxScale: 5,
                  alignment: Alignment.topCenter,
                  boundaryMargin: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 72,
                  ),
                  onInteractionUpdate: (_) => _updateZoomState(),
                  onInteractionEnd: (_) => _updateZoomState(),
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 48),
                        for (
                          var index = 0;
                          index < widget.pages.length;
                          index++
                        )
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x29000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: AspectRatio(
                                aspectRatio: widget.pages[index].aspectRatio,
                                child: Image(
                                  image: widget.pages[index].image,
                                  fit: BoxFit.contain,
                                  semanticLabel:
                                      'Página ${index + 1} de ${widget.pages.length}',
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 12,
              right: 12,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xE6202322),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pinch_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            'Use dois dedos para ampliar',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isZoomed)
              Positioned(
                right: 12,
                bottom: 12,
                child: FloatingActionButton.small(
                  heroTag: null,
                  onPressed: _resetZoom,
                  tooltip: 'Restaurar zoom',
                  backgroundColor: const Color(0xFF202322),
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.fit_screen_rounded),
                ),
              ),
          ],
        );
      },
    );
  }
}
