import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../widgets/pdf_pinch_viewer.dart';

class PdfViewerPage extends StatefulWidget {
  final String title;
  final String fileName;
  final Uint8List? bytes;
  final Future<Uint8List>? bytesFuture;
  final Color primaryColor;
  final VoidCallback? onOpenExternal;
  final String? externalUrlLabel;

  const PdfViewerPage({
    super.key,
    required this.title,
    required this.fileName,
    this.bytes,
    this.bytesFuture,
    this.primaryColor = const Color(0xFFD62828),
    this.onOpenExternal,
    this.externalUrlLabel,
  }) : assert(
          bytes != null || bytesFuture != null,
          'É necessário fornecer bytes ou bytesFuture.',
        );

  static Future<void> open(
    BuildContext context, {
    required String title,
    required String fileName,
    Uint8List? bytes,
    Future<Uint8List>? bytesFuture,
    Color primaryColor = const Color(0xFFD62828),
    VoidCallback? onOpenExternal,
    String? externalUrlLabel,
  }) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => PdfViewerPage(
          title: title,
          fileName: fileName,
          bytes: bytes,
          bytesFuture: bytesFuture,
          primaryColor: primaryColor,
          onOpenExternal: onOpenExternal,
          externalUrlLabel: externalUrlLabel,
        ),
      ),
    );
  }

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  Uint8List? _loadedBytes;
  bool _isLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    if (widget.bytes != null) {
      _loadedBytes = widget.bytes;
      _isLoading = false;
    } else if (widget.bytesFuture != null) {
      _carregarBytes();
    }
  }

  Future<void> _carregarBytes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await widget.bytesFuture!;
      if (!mounted) return;
      if (data.isEmpty) {
        throw Exception('Arquivo PDF vazio.');
      }
      setState(() {
        _loadedBytes = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  Future<void> _compartilhar() async {
    if (_loadedBytes == null) return;
    await Printing.sharePdf(
      bytes: _loadedBytes!,
      filename: widget.fileName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF202322),
          ),
          tooltip: 'Voltar',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF202322),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (_loadedBytes != null) ...[
            IconButton(
              icon: const Icon(Icons.ios_share_rounded, size: 20),
              color: const Color(0xFF202322),
              tooltip: 'Compartilhar',
              onPressed: _compartilhar,
            ),
          ],
          if (widget.onOpenExternal != null)
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded, size: 20),
              color: const Color(0xFF202322),
              tooltip: widget.externalUrlLabel ?? 'Abrir no navegador',
              onPressed: widget.onOpenExternal,
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _buildBody(),
      ),
      bottomNavigationBar: _loadedBytes != null ? _buildBottomActions() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: widget.primaryColor,
        ),
      );
    }

    if (_error != null || _loadedBytes == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.picture_as_pdf_outlined,
                color: widget.primaryColor,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Não foi possível carregar o documento.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF697370),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (widget.bytesFuture != null)
                    FilledButton.icon(
                      onPressed: _carregarBytes,
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Tentar novamente'),
                    ),
                  if (widget.onOpenExternal != null)
                    OutlinedButton.icon(
                      onPressed: widget.onOpenExternal,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.primaryColor,
                        side: BorderSide(
                          color: widget.primaryColor.withValues(alpha: 0.5),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: Text(
                        widget.externalUrlLabel ?? 'Abrir no navegador',
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return PdfPreview.builder(
      build: (_) async => _loadedBytes!,
      canChangeOrientation: false,
      canChangePageFormat: false,
      canDebug: false,
      allowPrinting: false,
      allowSharing: false,
      useActions: false,
      pdfFileName: widget.fileName,
      pagesBuilder: (context, pages) {
        return PdfPinchViewer(
          pages: pages,
          documentLabel: widget.title,
        );
      },
      loadingWidget: Center(
        child: CircularProgressIndicator(
          color: widget.primaryColor,
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E9E7)),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        MediaQuery.paddingOf(context).bottom + 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 42,
              child: FilledButton.icon(
                onPressed: _compartilhar,
                style: FilledButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text(
                  'Baixar / Salvar',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 42,
              child: OutlinedButton.icon(
                onPressed: _compartilhar,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF202322),
                  side: const BorderSide(color: Color(0xFFD2D8D5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text(
                  'Compartilhar',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
