# Plano de Implementação: Padronização dos Botões de Composição (`004-padronizacao-botoes-compor-mensagens`)

**Branch**: `feat/ajuste-botoes-compor-mensagens` | **Data**: 2026-11-19 | **Spec**: [spec.md](file:///home/rafaelhugo/projetosMPPB/app_mppb_flutter/specs/004-padronizacao-botoes-compor-mensagens/spec.md)

## Arquivos Afetados

- `lib/features/mensagens/ui/widgets/audio_recorder_bar.dart`:
  - Expõe `AudioRecorderBarState.iniciarGravacao()` (e opção `ocultarBotaoInicial: true`) para que, no estado ocioso, o acionamento venha do card uniforme **Áudio** na grade 2x2, exibindo o gravador e o preview inline ao gravar.
- `lib/features/mensagens/ui/pages/compor_mensagem_page.dart`:
  - Seção **"Mídias e Anexos"** com grade 2x2 uniforme (`_MidiaActionTile` para Áudio, Foto, Vídeo e Documento).
  - Seção **"Agendamento e Validade"** em card único agrupado com duas linhas (`Agendar envio` e `Expiração do aviso`).
- `test/features/mensagens/painel_remetente_test.dart`:
  - Adiciona teste de widget para `ComporMensagemPage` validando os 4 tiles uniformes e as opções agrupadas de agendamento/expiração.
