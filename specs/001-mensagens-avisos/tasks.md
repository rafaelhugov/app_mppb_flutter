---
description: "Lista de tarefas para implementação de Mensagens e Avisos Institucionais no app_mppb_flutter"
---

# Tarefas: Mensagens e Avisos Institucionais (`app_mppb_flutter`)

**Entrada**: Documentos de design em `specs/001-mensagens-avisos/` (`spec.md`, `plan.md`)  
**Constituição**: `.specify/memory/constitution.md`

## Formato: `[ID] [P?] [Story] Descrição`
- **[P]**: Pode executar em paralelo (arquivos distintos, sem dependência bloqueante)
- **[Story]**: História de usuário correspondente (`US1`, `US2`, `US3`, `US4`)

---

## Fase 1: Setup e Dependências

- [x] T001 Adicionar dependências justificadas no `pubspec.yaml` (`record`, `just_audio`, `video_player`, `image_picker`, `flutter_markdown`) e configurar permissões de microfone/câmera/mídia no Android (`AndroidManifest.xml`) e iOS (`Info.plist`)
- [x] T002 Criar estrutura de diretórios da feature em `lib/features/mensagens/` (`data/`, `models/`, `providers/`, `ui/pages/`, `ui/widgets/`) e `test/features/mensagens/`

---

## Fase 2: Fundação (Modelos, Repositório e Segurança de Sessão)

- [x] T003 [P] Criar modelos Dart (`MensagemAvisoModel`, `MensagemAnexoModel`, `AcompanhamentoMensagemModel`, `DestinatarioStatusModel`, `GrupoMensagemModel`) em `lib/features/mensagens/models/`
- [x] T004 [P] Implementar `MensagensRepository` (comunicação Dio autenticada para caixa de entrada, entrega/leitura/ciência, envio/upload multipart, acompanhamento, grupos e download/URL autenticada de mídias) em `lib/features/mensagens/data/mensagens_repository.dart`
- [x] T005 [P] Implementar `MensagemMidiaCache` para download seguro e compartilhamento de documentos via `share_plus` em `lib/features/mensagens/data/mensagem_midia_cache.dart`
- [x] T006 Garantir exposição da authority `androidmppb.mensagens.admin` da sessão no módulo `auth` (para liberar o painel do remetente ao perfil `Administrador` sem afetar `tipoCargo` Membro/Servidor) e desativação do token FCM no fluxo de logout para impedir notificações de avisos após sair da conta

---

## Fase 3: História de Usuário 1 — Conversa Unilateral estilo WhatsApp e Mídias Inline (P1)

**Objetivo**: Caixa de entrada/conversa unilateral do destinatário com bolhas estilo WhatsApp, execução inline de áudio, vídeo, fotos (zoom) e documentos, confirmação automática de entrega/leitura e botão "Confirmar Ciência".

- [x] T007 [US1] Implementar `caixa_entrada_provider.dart` (paginação, filtros `TODAS` / `NAO_LIDAS` / `ARQUIVADAS`, badge de não lidas, confirmação em lote `ENTREGUE`, `LIDO`, `CIENCIA` e arquivamento) em `lib/features/mensagens/providers/caixa_entrada_provider.dart`
- [x] T008 [P] [US1] Implementar `audio_player_card.dart` com streaming autenticado (`just_audio`), play/pause, barra de progresso, duração e seletor de velocidade (`1x`, `1.5x`, `2x`) em `lib/features/mensagens/ui/widgets/audio_player_card.dart`
- [x] T009 [P] [US1] Implementar `anexo_preview_widget.dart` (miniaturas de foto/vídeo com botão play e cartões de documento com extensão/tamanho) e `midia_viewer_page.dart` (foto com zoom, player de vídeo `video_player` e viewer inline de PDF/Markdown/TXT) em `lib/features/mensagens/ui/`
- [x] T010 [US1] Implementar `mensagem_bolha_card.dart` (bolha unilateral estilo canal WhatsApp com selo de prioridade, texto opcional, mídias inline e botão **"Confirmar Ciência"**) em `lib/features/mensagens/ui/widgets/mensagem_bolha_card.dart`
- [x] T011 [US1] Implementar `caixa_mensagens_page.dart` e `mensagem_detalhe_page.dart` em `lib/features/mensagens/ui/pages/`
- [x] T012 [US1] Registrar rotas autenticadas (`/mensagens`, `/mensagens/:id`) em `lib/core/router/app_router.dart` e integrar deep link FCM (`MENSAGEM_AVISO`) nos 3 estados do app (exigindo login se sessão expirada)
- [x] T013 [US1] Criar testes de provider e widget da caixa de entrada, bolha unilateral e confirmação de leitura/ciência em `test/features/mensagens/caixa_mensagens_test.dart`

---

## Fase 4: História de Usuário 2 — Painel Próprio do Remetente e Gravação de Áudio (P1)

**Objetivo**: Página própria do remetente autorizado no app para envio (`Broadcast`, `Multicast`, `Unicast`) com áudio estilo WhatsApp, anexos, prévia de alcance e agendamento.

- [x] T014 [US2] Implementar `envio_mensagem_provider.dart` (composição texto e/ou mídia, prévia de alcance, upload multipart com progresso, agendamento e envio) em `lib/features/mensagens/providers/envio_mensagem_provider.dart`
- [x] T015 [P] [US2] Implementar `audio_recorder_bar.dart` (gravador estilo WhatsApp com timer, cancelamento e preview antes de enviar via `record`) em `lib/features/mensagens/ui/widgets/audio_recorder_bar.dart`
- [x] T016 [P] [US2] Implementar `seletor_destinatarios_sheet.dart` (modalidades Broadcast/Multicast/Unicast, grupos RH, grupos personalizados e busca de servidores/membros) em `lib/features/mensagens/ui/widgets/seletor_destinatarios_sheet.dart`
- [x] T017 [US2] Implementar `painel_remetente_page.dart` e `compor_mensagem_page.dart` em `lib/features/mensagens/ui/pages/` e registrar rotas protegidas por permissão (`/mensagens/painel`, `/mensagens/painel/nova`) em `lib/core/router/app_router.dart`
- [x] T018 [US2] Criar testes de controle de visibilidade por permissão e composição (somente mídia / somente texto) em `test/features/mensagens/painel_remetente_test.dart`

---

## Fase 5: História de Usuário 3 — Acompanhamento de Entrega, Leitura e Ciência (P2)

- [x] T019 [US3] Implementar `acompanhamento_provider.dart` e `acompanhamento_mensagem_page.dart` (contadores consolidados e lista paginada filtrável por `PENDENTE` / `ENTREGUE` / `LIDO` / `CIENTE` com timestamps) e rota `/mensagens/painel/:id/acompanhamento`
- [x] T020 [US3] Criar testes de widget/provider para `acompanhamento_mensagem_page.dart` em `test/features/mensagens/acompanhamento_mensagem_test.dart`

---

## Fase 6: História de Usuário 4 — Gestão de Grupos Personalizados no App (P2)

- [x] T021 [US4] Implementar `grupos_mensagem_provider.dart` e `grupos_personalizados_page.dart` (listar, criar, editar, adicionar/remover membros pela busca RH e inativar grupos) e rota `/mensagens/painel/grupos`
- [x] T022 [US4] Criar testes de CRUD de grupos personalizados em `test/features/mensagens/grupos_mensagem_test.dart`

---

## Fase 7: Polimento e Verificação Final

- [x] T023 Adicionar atalho na tela inicial/menu autenticado para **Mensagens e Avisos** (com badge de não lidas) e atalho do **Painel de Envio** visível apenas para quem possui permissão
- [x] T024 Executar `flutter analyze` e `flutter test` em `app_mppb_flutter/` e validar zero erros/regressões

