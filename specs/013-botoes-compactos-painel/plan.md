# Plan: 013 - Botões Compactos à Direita no Painel de Avisos

- Em `painel_remetente_page.dart`, substituir `Expanded` por `Row(mainAxisAlignment: MainAxisAlignment.end)` com botões compactos (`height: 34`, `fontSize: 12`, `shrinkWrap`).
- Validar com `flutter analyze` e `flutter test test/features/mensagens`.
