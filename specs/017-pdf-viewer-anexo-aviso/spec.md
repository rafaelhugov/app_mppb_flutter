# Feature Spec: 017 - Leitor de PDF Dedicado em Anexos de Avisos

## Problema
Ao tocar em um anexo `.pdf` em `AnexoPreviewWidget`, o app abria `MidiaViewerPage` em vez da página dedicada `PdfViewerPage` usada nos demais módulos do aplicativo (Contracheque, Diário Oficial, Certidão Extrajudicial).

## Requisito
Ao tocar em um anexo PDF em `AnexoPreviewWidget`, abrir `PdfViewerPage.open(...)` com suporte nativo a leitura com zoom, compartilhamento e download.
