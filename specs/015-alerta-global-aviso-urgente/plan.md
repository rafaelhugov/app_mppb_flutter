# Implementation Plan: 015 - Alerta Global de Aviso Urgente

1. Atualizar `CaixaEntradaState` em `lib/features/mensagens/providers/caixa_entrada_provider.dart` com `urgentesNaoLidas` e `totalUrgentesNaoLidas`.
2. Criar widget `lib/features/mensagens/ui/widgets/aviso_urgente_global_banner.dart` com:
   - `AvisoUrgenteGlobalBanner`: faixa compacta no topo para todas as telas autenticadas (exceto `/mensagens*`), com ícone de alerta, contagem/título e botão `"Ler"`.
   - `mostrarModalAvisoUrgente(...)`: `AlertDialog` com título, resumo do(s) aviso(s) urgente(s), botão `"Depois"` e botão `"Ler agora"`.
3. Integrar no `MainLayout` (`lib/core/ui/main_layout.dart`):
   - `ref.listen<CaixaEntradaState>(caixaEntradaProvider, ...)` para disparar o modal quando novos IDs urgentes não lidos forem detectados na sessão (sem repetir após o usuário clicar em `"Depois"` para o mesmo conjunto de IDs).
   - Renderizar `AvisoUrgenteGlobalBanner` no topo do corpo autenticado quando `totalUrgentesNaoLidas > 0`.
4. Adicionar testes de widget em `test/features/mensagens/aviso_urgente_global_test.dart` e validar com `flutter analyze` e `flutter test test/features/mensagens`.

