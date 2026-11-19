# Plano de Implementação: Editor com Formatação Visual Imediata (`007-editor-formatacao-tempo-real`)

- `lib/features/mensagens/ui/widgets/rich_markdown_controller.dart` (**NOVO**):
  - Implementa `RichMarkdownEditingController extends TextEditingController` parseando `**...**`, `*...*`, `~~...~~`, `[texto](url)` e linhas iniciadas por `- ` em `TextSpan` com estilo imediato e marcadores visualmente ocultos (`fontSize: 0.01, color: Colors.transparent`) preservando exatamente `text.length`.
  - Métodos utilitários `alternarEnvoltorio(String token)` e `alternarListaLinha()` + detecção `estaAtivo(String token)` para destacar os botões na barra.
- `lib/features/mensagens/ui/pages/compor_mensagem_page.dart`:
  - Substitui `TextEditingController` por `RichMarkdownEditingController`.
  - Aplica `TextSelectionThemeData` MPPB+ (`#202322` / `#00A86B`).
  - Destaca botões ativos na barra de formatação.
- `test/features/mensagens/painel_remetente_test.dart`:
  - Testa `RichMarkdownEditingController.buildTextSpan` (negrito, itálico, tachado, preservação do tamanho do texto e alternância).
