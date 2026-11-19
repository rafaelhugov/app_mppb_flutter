# Plano de Implementação: Mensagens e Avisos Institucionais (`app_mppb_flutter`)

**Branch**: `feat/mensagens-avisos` | **Data**: 2026-11-18 | **Spec**: [spec.md](./spec.md)  
**Constituição Aplicável**: `app_mppb_flutter/.specify/memory/constitution.md`

## Resumo

Implementar no `app_mppb_flutter` a feature completa de **Mensagens e Avisos Institucionais**, composta por:
1. **Área do Destinatário**: Caixa de entrada com filtro (*Todas*, *Não lidas*, *Arquivadas*), destaque de prioridade, abertura via deep link FCM, exibição inline de imagens, player de áudio (com velocidade 1x/1.5x/2x), player de vídeo, download/compartilhamento de documentos e confirmação automática de entrega/leitura + botão opcional **"Confirmar Ciência"**.
2. **Área do Remetente (Autoridade Designada)**: Página própria visível apenas quando a sessão autenticada possuir a permissão correspondente, permitindo compor e enviar/agendar avisos (`Broadcast`, `Multicast`, `Unicast`) com prévia de alcance, gravar mensagens de áudio no app, anexar mídias/arquivos, gerenciar grupos personalizados e acompanhar quem/quando recebeu, leu e deu ciência.

## Contexto Técnico

- **Linguagem/SDK**: Flutter / Dart (`sdk: ^3.12.2`), `flutter_riverpod`, `go_router`, `dio`, `firebase_messaging`, `file_picker`, `share_plus`, `connectivity_plus`.
- **Dependências Adicionais (a justificar conforme Princípio II da Constituição)**:
  - Gravação de áudio no app (remetente): `record` (captura AAC/M4A compatível com Android/iOS).
  - Reprodução de áudio inline (destinatário/preview): `just_audio` (suporta streaming HTTP autenticado com headers `Authorization` e controle de velocidade).
  - Reprodução de vídeo inline: `video_player` (suporta HTTP `Range` com headers de autenticação).
  - Seleção de foto/vídeo da câmera/galeria: `image_picker` (complementando `file_picker` para documentos).
  - Visualização inline de documentos: `flutter_markdown` (para `.md`) e `printing` (`PdfPreview` já presente no `pubspec.yaml`, ou `pdfx` para leitura paginada de `.pdf`).
- **Testes**: `flutter test` e `flutter analyze`.

## Verificação da Constituição (`app_mppb_flutter/.specify/memory/constitution.md`)

- **Princípio I & II**: Toda a feature isolada em `lib/features/mensagens/`, usando Riverpod, GoRouter e Dio. Novas dependências de mídia (`record`, `just_audio`, `video_player`, `image_picker`) justificadas pela exigência explícita de gravação/reprodução de áudio e vídeo estilo WhatsApp/Telegram.
- **Princípio III (Segurança)**:
  - Acesso exclusivo a usuários autenticados (rotas sob `/restrito` ou protegidas pelo guard do `app_router.dart`).
  - Logout desativa o token FCM no `mobile-service`.
  - Ações e rotas de remetente condicionadas à permissão retornada na sessão.
- **Princípio IV (Offline & Push)**: Tratamento de estado vazio, carregamento, erro de rede e deep link FCM nos 3 estados do app (foreground, background, terminated).
- **Princípio V & VI**: Textos em pt-BR; testes automatizados em `test/features/mensagens/`.

## Estrutura do Projeto

### Documentação (`app_mppb_flutter/specs/001-mensagens-avisos/`)
- `spec.md` — Requisitos e cenários de usuário
- `plan.md` — Este plano técnico
- `tasks.md` — A ser gerado pelo `speckit-tasks`

### Código-Fonte (`app_mppb_flutter/lib/features/mensagens/`)
```text
lib/features/mensagens/
├── data/
│   ├── mensagens_repository.dart            # Chamadas Dio para caixa de entrada, envio, grupos, upload/download
│   └── mensagem_midia_cache.dart            # Apoio a download/compartilhamento seguro de anexos
├── models/
│   ├── mensagem_aviso_model.dart
│   ├── mensagem_anexo_model.dart
│   ├── acompanhamento_mensagem_model.dart
│   └── grupo_mensagem_model.dart
├── providers/
│   ├── caixa_entrada_provider.dart          # Estado paginado, filtros, badge não lidas, confirmar entrega/leitura/ciência
│   ├── envio_mensagem_provider.dart         # Composição, prévia de alcance, gravação de áudio, upload e envio/agendamento
│   ├── acompanhamento_provider.dart         # Lista de enviadas e drill-down de destinatários
│   └── grupos_mensagem_provider.dart        # Grupos RH + CRUD grupos personalizados + busca de servidores/membros
└── ui/
    ├── pages/
    │   ├── caixa_mensagens_page.dart        # Feed/conversa unilateral estilo WhatsApp (com agrupamento por data e filtros)
    │   ├── mensagem_detalhe_page.dart       # Visualização completa / foco da mensagem, mídias inline, botão "Confirmar Ciência", arquivar
    │   ├── midia_viewer_page.dart           # Visualizador em tela cheia para foto (zoom), vídeo e documentos (PDF/MD/TXT)
    │   ├── painel_remetente_page.dart       # Abas/hub: Enviadas + Nova Mensagem + Grupos
    │   ├── compor_mensagem_page.dart        # Formulário Broadcast/Multicast/Unicast, gravação de áudio, anexos, prévia, agendamento
    │   ├── acompanhamento_mensagem_page.dart # Contadores + lista de quem recebeu/leu/deu ciência
    │   └── grupos_personalizados_page.dart  # CRUD de grupos personalizados
    └── widgets/
        ├── mensagem_bolha_card.dart         # Bolha/cartão de aviso estilo canal WhatsApp (prioridade, texto, mídias, ciência)
        ├── audio_recorder_bar.dart          # Gravador de voz estilo WhatsApp
        ├── audio_player_card.dart           # Player inline na bolha com barra de progresso, duração e velocidade 1x/1.5x/2x
        ├── anexo_preview_widget.dart        # Miniaturas de foto/vídeo com play e cartões de documento na conversa
        └── seletor_destinatarios_sheet.dart # Seleção de grupos RH, personalizados e busca Unicast
```

### Integração com `lib/core/`
- `lib/core/router/app_router.dart`: registrar rotas autenticadas:
  - `/mensagens` (Caixa de entrada)
  - `/mensagens/:id` (Detalhe da mensagem)
  - `/mensagens/painel` (Painel do remetente — protegido por permissão)
  - `/mensagens/painel/nova` (Compor mensagem)
  - `/mensagens/painel/:id/acompanhamento` (Relatório de entregas/leituras)
  - `/mensagens/painel/grupos` (Grupos personalizados)
- Serviço de Push FCM existente: ao receber push do tipo `MENSAGEM_AVISO`, atualizar o contador/caixa de entrada em foreground e navegar para `/mensagens/:id` ao tocar na notificação (somente se autenticado).

