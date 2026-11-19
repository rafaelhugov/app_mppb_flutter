# Plano de Implementação: Listas com Marcadores e Ordenada (`008-listas-editor-mensagens`)

- `lib/features/mensagens/ui/widgets/rich_markdown_controller.dart`:
  - `alternarListaLinha()` usa `• ` (bullet real) e remove `- ` / `N. ` se presente.
  - `alternarListaOrdenadaLinha()` aplica `N. ` (calculado a partir da linha anterior, padrão `1. `).
  - `buildTextSpan` estiliza `• ` e `^\d+\. ` em `MensagensColors.green` com peso `w800`/`w900`.
  - `normalizarParaMarkdown()` converte linhas `• ` para `- ` mantendo compatibilidade total com `MarkdownBody`.
- `lib/features/mensagens/ui/pages/compor_mensagem_page.dart`:
  - Adiciona botão `Lista ordenada` (`Icons.format_list_numbered_rounded`) na barra de formatação.
  - Conecta `onChanged` com auto-continuação de lista ao pressionar Enter e envia `controller.normalizarParaMarkdown()` ao provider e à prévia.
- `test/features/mensagens/painel_remetente_test.dart`:
  - Testa `alternarListaLinha`, `alternarListaOrdenadaLinha` e `normalizarParaMarkdown`.
