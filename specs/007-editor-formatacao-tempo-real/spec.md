# Especificação de Funcionalidade: Editor com Formatação Visual Imediata (WYSIWYG) (`app_mppb_flutter`)

**Branch da Feature**: `feat/editor-formatacao-tempo-real`  
**Criado em**: 2026-11-19  
**Status**: Aprovado para Implementação  
**Subprojeto**: `app_mppb_flutter`  
**Feature Base**: `006-expiracao-e-pagina-grupos`

## Cenários de Usuário e Testes *(obrigatório)*

### História de Usuário 1 - Formatação Imediata no Próprio Campo de Texto (Priority: P1)

Como remetente compondo um comunicado no **Painel de Avisos**, ao aplicar **Negrito**, **Itálico**, **Tachado**, **Lista** ou **Link** na barra de formatação, quero ver o texto já formatado **imediatamente dentro do próprio campo de digitação** (sem exibir asteriscos `**`, `*` ou `~~` crus na tela e sem depender do botão Prévia), mantendo o cursor e a seleção com as cores oficiais do **MPPB+**.

**Critérios de Aceitação**:
1. **Dado** o campo de mensagem em `ComporMensagemPage`, **Quando** o usuário seleciona um trecho e toca em **B**, **I** ou **S** (ou digita usando a formatação), **Então** o `RichMarkdownEditingController` aplica imediatamente `FontWeight.bold`, `FontStyle.italic` ou `TextDecoration.lineThrough` no próprio `TextField`, ocultando visualmente os marcadores (`**`, `*`, `~~`) sem quebrar o índice do cursor.
2. **Dado** o cursor posicionado em uma linha, **Quando** o usuário toca em **Lista**, **Então** a linha recebe marcador visual de tópico (`• ` estilizado) imediatamente.
3. **Dado** a barra de formatação, **Quando** o cursor está dentro de um trecho formatado, **Então** o botão correspondente (**B**, **I**, **S**) fica visualmente destacado e tocar novamente alterna/remove a formatação.
4. **Dado** o `TextField` em foco/seleção, **Quando** o usuário move o cursor, **Então** a alça de seleção e o cursor utilizam as cores **MPPB+** (`MensagensColors.brandDark` / `MensagensColors.green`) em vez do tom amarronzado padrão.

## Requisitos *(obrigatório)*

- **FR-001**: Criar `RichMarkdownEditingController` (`lib/features/mensagens/ui/widgets/rich_markdown_controller.dart`) estendendo `TextEditingController` com `buildTextSpan` para renderização visual imediata de negrito, itálico, tachado, links e listas preservando 1:1 o tamanho da string para estabilidade do cursor/IME.
- **FR-002**: Atualizar `ComporMensagemPage` para usar `RichMarkdownEditingController`, destaque de botões ativos na barra de formatação e `TextSelectionThemeData` com a paleta **MPPB+**.
- **FR-003**: Adicionar testes unitários e de widget cobrindo a estilização de `RichMarkdownEditingController` e a interação na `ComporMensagemPage`.
