# Implementation Plan: 016 - Voltar em Detalhes de Mensagem e Cores do Modal Urgente

1. Atualizar `MensagemDetalhePage` (`lib/features/mensagens/ui/pages/mensagem_detalhe_page.dart`) com `_voltarParaLista()` usando `Navigator.canPop` / `GoRouter.maybeOf(context)?.go('/mensagens')`.
2. Atualizar `mostrarModalAvisoUrgente` (`lib/features/mensagens/ui/widgets/aviso_urgente_global_banner.dart`) para usar `MensagensColors`.
3. Validar com `flutter analyze` e `flutter test test/features/mensagens`.
