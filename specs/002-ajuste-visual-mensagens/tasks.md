# Tasks: Ajuste Visual e Padronização com o Design System MPPB+ (`002-ajuste-visual-mensagens`)

**Input**: Documentos de design em `/specs/002-ajuste-visual-mensagens/` (`spec.md`, `plan.md`)

## Phase 1: Tokens Visuais e Componentes Base (`MensagensTheme`)

- [x] T001 Criar `lib/features/mensagens/ui/widgets/mensagens_theme.dart` com a paleta oficial do MPPB+ (`background #F7F8F6`, `surface #FFFFFF`, `border #E9EDF0`, `ink #202322`, `headerInk #241D19`, `muted #697370`, `green #00A86B`, `red #D62828`, `orange #F97316`, `blue #2563EB`) e widgets reutilizáveis de pílula segmentada, estado de erro/offline, estado vazio e botão de ação no cabeçalho.

## Phase 2: Refatoração dos Widgets de Mensagem e Mídia

- [x] T002 [P] Atualizar `lib/features/mensagens/ui/widgets/mensagem_bolha_card.dart` para o padrão de card institucional MPPB+ (superfície branca, borda `#E9EDF0` ou cor da prioridade quando não lida, barra lateral/badge de prioridade, botão `Confirmar Ciência` em `#00A86B` e metadados em `#697370`).
- [x] T003 [P] Atualizar `lib/features/mensagens/ui/widgets/audio_player_card.dart`, `lib/features/mensagens/ui/widgets/audio_recorder_bar.dart`, `lib/features/mensagens/ui/widgets/anexo_preview_widget.dart` e `lib/features/mensagens/ui/widgets/seletor_destinatarios_sheet.dart` com a paleta `MensagensTheme`.

## Phase 3: Refatoração das Páginas no `ShellRoute` (`HeroHeaderPublico` + `MainLayout`)

- [x] T004 Atualizar `lib/features/mensagens/ui/pages/caixa_mensagens_page.dart` substituindo o `AppBar` azul-escuro por `HeroHeaderPublico`, o filtro de `ChoiceChip` pela barra segmentada em pílula `#202322`, o fundo por `#F7F8F6` e aplicando `MainLayout.horizontalPadding` e `MainLayout.contentBottomPadding`.
- [x] T005 [P] Atualizar `lib/features/mensagens/ui/pages/mensagem_detalhe_page.dart` e `lib/features/mensagens/ui/pages/painel_remetente_page.dart` com `HeroHeaderPublico`, ações integradas sem colisão com a bottom bar flutuante e cards estilizados com `MensagensTheme`.
- [x] T006 [P] Atualizar `lib/features/mensagens/ui/pages/compor_mensagem_page.dart`, `lib/features/mensagens/ui/pages/acompanhamento_mensagem_page.dart` e `lib/features/mensagens/ui/pages/grupos_personalizados_page.dart` com `HeroHeaderPublico`, cards de formulário brancos e `MainLayout.contentBottomPadding`.

## Phase 4: Verificação, Testes e Atualização no Emulador Android

- [x] T007 Executar `flutter analyze` e `flutter test test/features/mensagens` garantindo 0 warnings/erros e 100% dos testes passando.
- [x] T008 Compilar e instalar o APK de homologação no emulador Android (`emulator-5554`) para validar visualmente a nova interface no padrão MPPB+.

