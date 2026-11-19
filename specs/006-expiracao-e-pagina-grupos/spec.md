# Especificação de Funcionalidade: Margem Mínima de Expiração e Página Dedicada para Grupos (`app_mppb_flutter`)

**Branch da Feature**: `feat/expiracao-e-pagina-grupos`  
**Criado em**: 2026-11-19  
**Status**: Aprovado para Implementação  
**Subprojeto**: `app_mppb_flutter`  
**Feature Base**: `005-ux-mensageiro-compor-avisos`

## Cenários de Usuário e Testes *(obrigatório)*

### História de Usuário 1 - Validação de Margem Mínima de Expiração (1 hora após o envio) (Priority: P1)

Como remetente no compositor de avisos (`ComporMensagemPage`), ao definir uma data/hora de expiração, o sistema **não** pode permitir que o aviso expire antes ou no mesmo instante do envio (seja envio imediato ou agendado), exigindo uma **margem mínima de 1 hora** após a data efetiva de envio (`dataAgendamento ?? agora`).

**Critérios de Aceitação**:
1. **Dado** um aviso com envio agendado para `20/11 16:38` (ou envio imediato), **Quando** o remetente seleciona uma expiração menor que `envio + 1 hora`, **Então** o app impede a seleção/envio e exibe mensagem clara: `"A expiração deve ter pelo menos 1 hora após o envio."`.
2. **Dado** que o remetente já definiu uma expiração válida e depois altera o agendamento tornando a margem menor que 1 hora, **Quando** tenta enviar ou confirma o novo agendamento, **Então** o `EnvioMensagemNotifier` também valida e bloqueia o envio inconsistente.

### História de Usuário 2 - Página Dedicada de Criação e Edição de Grupos Personalizados (Priority: P1)

Como administrador gerenciando **Grupos Personalizados**, ao tocar em **Novo Grupo** ou **Editar**, quero abrir uma **página dedicada em tela cheia** (`GrupoEditorPage`) em vez de um modal (`AlertDialog`), para ter espaço confortável de busca e visualização quando muitos membros/servidores forem adicionados ao grupo.

**Critérios de Aceitação**:
1. **Dado** a tela `GruposPersonalizadosPage`, **Quando** o usuário toca em **Novo Grupo** ou no botão de editar de um grupo existente, **Então** abre a página dedicada `GrupoEditorPage` com `HeroHeaderPublico` (sem `AlertDialog`).
2. **Dado** `GrupoEditorPage`, **Quando** o usuário preenche nome/descrição, busca e adiciona múltiplos membros, **Então** a lista de participantes selecionados possui espaço amplo com rolagem confortável, paleta **MPPB+** (`#F7F8F6`, `#FFFFFF`, `#202322`, `#00A86B`) e botão `"Salvar Grupo"` respeitando `MainLayout.contentBottomPadding`.

## Requisitos *(obrigatório)*

- **FR-001**: Validar em `ComporMensagemPage` e `EnvioMensagemNotifier` que `dataExpiracao >= (dataAgendamento ?? agora) + 1 hora`.
- **FR-002**: Substituir `_EditorGrupoDialog` em `GruposPersonalizadosPage` pela página dedicada `GrupoEditorPage` (`lib/features/mensagens/ui/pages/grupo_editor_page.dart`) e registrar rota `/mensagens/painel/grupos/editor` (ou navegação via `GoRouter`/`Navigator`).
- **FR-003**: Atualizar testes unitários/widget em `test/features/mensagens/` cobrindo a margem mínima de expiração e a página dedicada de grupos.
