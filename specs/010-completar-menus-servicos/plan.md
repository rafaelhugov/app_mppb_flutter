# Plan 010 — Completar Menus Públicos e Logados

1. Refatorar `ServicesBottomSheet` (`lib/core/ui/widgets/services_bottom_sheet.dart`) para usar uma lista tipada `_ServiceShortcut` separando claramente os atalhos públicos e os atalhos autenticados.
2. Incluir `Notícias`, `Diário`, `Processos` e `Contatos` no modo público, e `Mensagens` e `Contatos` no modo logado.
3. Adicionar testes de widget em `test/core/ui/services_bottom_sheet_test.dart` validando ambos os modos.
4. Validar com `flutter analyze` e `flutter test`.
