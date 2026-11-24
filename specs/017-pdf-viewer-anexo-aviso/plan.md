# Implementation Plan: 017 - Leitor de PDF Dedicado em Anexos de Avisos

1. Atualizar `AnexoPreviewWidget` (`lib/features/mensagens/ui/widgets/anexo_preview_widget.dart`) para detectar anexos PDF (`nomeOriginal.toLowerCase().endsWith('.pdf') || mimeType.toLowerCase().contains('pdf')`) e abrir `PdfViewerPage.open(...)` com `bytesFuture`.
2. Validar com `flutter analyze` e `flutter test test/features/mensagens`.
