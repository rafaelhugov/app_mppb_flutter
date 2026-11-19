# Plano de Implementação: Margem de Expiração e Página Dedicada de Grupos (`006-expiracao-e-pagina-grupos`)

**Branch**: `feat/expiracao-e-pagina-grupos` | **Data**: 2026-11-19 | **Spec**: [spec.md](file:///home/rafaelhugo/projetosMPPB/app_mppb_flutter/specs/006-expiracao-e-pagina-grupos/spec.md)

## Arquivos Afetados

- `lib/features/mensagens/providers/envio_mensagem_provider.dart`:
  - Valida que `dataExpiracao` tenha pelo menos 1 hora após `(dataAgendamento ?? DateTime.now())`.
- `lib/features/mensagens/ui/pages/compor_mensagem_page.dart`:
  - Ajusta `firstDate` e `initialDate` do seletor de expiração para respeitar `dataAgendamento ?? agora`, exibindo `SnackBar` claro caso a hora escolhida fique abaixo de `+1h`.
- `lib/features/mensagens/ui/pages/grupo_editor_page.dart` (**NOVO**):
  - Página dedicada no padrão MPPB+ (`HeroHeaderPublico`, `MensagensColors`, busca de destinatários, lista de participantes adicionados sem limitação de modal e botão `Salvar Grupo`).
- `lib/features/mensagens/ui/pages/grupos_personalizados_page.dart`:
  - Navega para `GrupoEditorPage` ao criar ou editar um grupo, removendo `_EditorGrupoDialog`.
- `test/features/mensagens/painel_remetente_test.dart` e `test/features/mensagens/grupos_mensagem_test.dart`:
  - Cobrem validação da margem mínima de 1 hora e abertura/exibição da `GrupoEditorPage`.
