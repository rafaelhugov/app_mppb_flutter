# Plano de Implementação: UX Mensageiro + Formatação + Correções (`005-ux-mensageiro-compor-avisos`)

**Branch**: `feat/ux-mensageiro-compor-avisos` | **Data**: 2026-11-19 | **Spec**: [spec.md](file:///home/rafaelhugo/projetosMPPB/app_mppb_flutter/specs/005-ux-mensageiro-compor-avisos/spec.md)

## Arquivos Afetados

- `lib/features/mensagens/ui/widgets/audio_recorder_bar.dart`:
  - Adiciona `margin: EdgeInsets.only(bottom: 12)` nos estados de gravação e pré-visualização.
  - Usa `Expanded` nos botões `Descartar` e `Anexar áudio` para evitar overflow horizontal.
- `lib/features/mensagens/ui/pages/compor_mensagem_page.dart`:
  - Tema MPPB+ no `showDatePicker` e `showTimePicker`.
  - Barra de formatação Markdown (`B`, `I`, `S`, `Lista`, `Link`, `Prévia`) integrada ao editor de mensagem.
  - Bandeja compacta estilo mensageiro com 4 ações uniformes (`Áudio`, `Foto`, `Vídeo`, `Arquivo`).
  - Cartão único de configurações de envio (`Confirmar ciência`, `Agendar envio`, `Expiração do aviso`) com visual limpo e `Switch` em `#00A86B`.
- `lib/features/mensagens/ui/widgets/mensagem_bolha_card.dart`:
  - Renderiza `mensagem.conteudo` com `MarkdownBody` (`flutter_markdown`) + `url_launcher`, mantendo visual conversacional limpo no padrão MPPB+.
- `test/features/mensagens/painel_remetente_test.dart`:
  - Atualiza e amplia testes para validar barra de formatação (`B`, `I`, `S`), bandeja de 4 mídias e cartão de ciência/agendamento.
