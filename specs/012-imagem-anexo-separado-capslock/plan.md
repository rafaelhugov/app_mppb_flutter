# Plan: 012 - Carregamento de Imagens via Dio, Remoção de CAPSLOCK e Bolhas Separadas

- `mensagens_repository.dart`: adicionar `baixarThumbnailBytes(mensagemId, anexoId)`.
- `anexo_preview_widget.dart`: carregar imagem/thumbnail via `Dio`/`MensagemMidiaCache` com `StatefulWidget` (`_ImagemPreviewCard`).
- `midia_viewer_page.dart`: carregar `CategoriaAnexo.imagem` via `MensagemMidiaCache.obterOuBaixar` e renderizar `Image.file`.
- `mensagem_aviso_model.dart`, `mensagem_detalhe_page.dart`, `mensagem_bolha_card.dart`, `painel_remetente_page.dart`: remover CAPSLOCK das labels.
- `mensagem_bolha_card.dart` & `mensagem_detalhe_page.dart`: separar anexos em bolhas próprias estilo WhatsApp quando houver texto + anexo(s).
