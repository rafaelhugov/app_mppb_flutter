# Plano de Implementação: Ajuste Visual e Padronização com o Design System MPPB+ (`app_mppb_flutter`)

**Branch**: `feat/ajuste-visual-mensagens` | **Data**: 2026-11-19 | **Spec**: [spec.md](file:///home/rafaelhugo/projetosMPPB/app_mppb_flutter/specs/002-ajuste-visual-mensagens/spec.md)

## Contexto Técnico

- **Linguagem/Versão**: Dart 3.10+ / Flutter 3.x
- **Componentes de Referência do Design System MPPB+**:
  - `lib/core/ui/main_layout.dart` (`MainLayout.horizontalPadding`, `MainLayout.contentBottomPadding`)
  - `lib/core/ui/widgets/hero_header_publico.dart` (`HeroHeaderPublico`)
  - `lib/features/designacoes/ui/designacoes_page.dart` (`_ErrorState`, `_EmptyState`, cards com `Color(0xFFE9EDF0)`)
  - `lib/features/concessao_afastamento/ui/concessao_afastamento_page.dart` (pílula segmentada `Color(0xFF202322)`)
  - `lib/features/concessao_afastamento/ui/widgets/concessao_afastamento_theme.dart` (`ConcessaoAfastamentoColors`)

## Verificação da Constituição (`.specify/memory/constitution.md`)

- **I. Arquitetura Modular e Riverpod**: Mantida; apenas a camada `ui/` de `lib/features/mensagens/` é refatorada.
- **II. UX Mobile-First, Responsividade e Acessibilidade**: Alvos de toque ≥ 48dp, contraste elevado (`#202322` sobre `#FFFFFF`/`#F7F8F6`), sem colisão com a bottom navigation bar flutuante.
- **III. Segurança e Privacidade**: Inalterada.
- **IV. Qualidade e Testes**: `flutter analyze` (0 issues) + `flutter test test/features/mensagens` (100% green).

## Estrutura de Arquivos a Criar/Atualizar

```text
lib/features/mensagens/ui/
├── widgets/
│   ├── mensagens_theme.dart              # NOVO: Tokens visuais e componentes compartilhados do módulo
│   ├── mensagem_bolha_card.dart          # ATUALIZADO: Card institucional branco com borda #E9EDF0 e acentos MPPB+
│   ├── audio_player_card.dart            # ATUALIZADO: Player de voz harmonizado com #00A86B e #202322
│   ├── audio_recorder_bar.dart           # ATUALIZADO: Gravador de áudio com estilo MPPB+
│   ├── anexo_preview_widget.dart         # ATUALIZADO: Previews de imagem/vídeo/documento no padrão MPPB+
│   └── seletor_destinatarios_sheet.dart  # ATUALIZADO: Seletores Broadcast/Multicast/Unicast com tema MPPB+
└── pages/
    ├── caixa_mensagens_page.dart         # ATUALIZADO: HeroHeaderPublico + pílula segmentada #202322 + fundo #F7F8F6
    ├── mensagem_detalhe_page.dart        # ATUALIZADO: HeroHeaderPublico + padding MainLayout
    ├── painel_remetente_page.dart        # ATUALIZADO: HeroHeaderPublico + botão Novo Aviso/Grupos integrado + cards MPPB+
    ├── compor_mensagem_page.dart         # ATUALIZADO: HeroHeaderPublico + cards de seção brancos + CTA institucional
    ├── acompanhamento_mensagem_page.dart # ATUALIZADO: HeroHeaderPublico + resumo em card branco + filtros MPPB+
    └── grupos_personalizados_page.dart   # ATUALIZADO: HeroHeaderPublico + lista e modal no padrão MPPB+
```

