# Especificação de Funcionalidade: Listas com Marcadores Reais e Lista Ordenada no Editor (`app_mppb_flutter`)

**Branch da Feature**: `feat/listas-editor-mensagens`  
**Criado em**: 2026-11-19  
**Status**: Aprovado para Implementação  
**Subprojeto**: `app_mppb_flutter`  
**Feature Base**: `007-editor-formatacao-tempo-real`

## Cenários de Usuário e Testes *(obrigatório)*

### História de Usuário 1 - Lista com Marcadores Visuais Reais (`•`) e Lista Ordenada (`1.`, `2.`, ...) (Priority: P1)

Como remetente no compositor de avisos (`ComporMensagemPage`), quero:
1. Que o botão **Lista** aplique um marcador visual real de tópico (**`• `** em vez de hífen `-`) diretamente no campo de texto, destacando o marcador em `MensagensColors.green`, e convertendo `• ` para `- ` automaticamente no Markdown enviado/pré-visualizado.
2. Ter um novo botão **Lista Ordenada** (`Icons.format_list_numbered_rounded`) na barra de formatação que aplica **`1. `**, **`2. `**, **`3. `** (incrementando automaticamente quando a linha anterior já for numerada).
3. Que ao pressionar **Enter** em uma linha de lista (`• ` ou `1. `), o editor continue automaticamente o próximo tópico (`• ` ou `2. `), e se a linha estiver vazia, encerre a lista.

## Requisitos *(obrigatório)*

- **FR-001**: Atualizar `RichMarkdownEditingController` (`lib/features/mensagens/ui/widgets/rich_markdown_controller.dart`) com `alternarListaLinha()` usando `• `, novo método `alternarListaOrdenadaLinha()` (`1. `, `2. `, ...), estilização visual de `• ` e `^\d+\. `, auto-continuação no Enter (`tratarNovaLinha()`) e conversão `normalizarParaMarkdown(String)` (`^• ` → `- `).
- **FR-002**: Atualizar `ComporMensagemPage` adicionando o botão **Lista ordenada** na barra de formatação, destacando os botões ativos quando o cursor estiver em uma lista e enviando o texto normalizado para Markdown.
- **FR-003**: Atualizar `test/features/mensagens/painel_remetente_test.dart` cobrindo lista com marcador `•`, lista ordenada (`1.`, `2.`) e normalização para Markdown.
