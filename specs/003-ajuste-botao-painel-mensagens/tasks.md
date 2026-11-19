# Tasks: Reposicionamento do Botão Painel (`003-ajuste-botao-painel-mensagens`)

- [x] T001 Atualizar `.specify/feature.json` e gerar `spec.md` e `plan.md` em `specs/003-ajuste-botao-painel-mensagens/`.
- [x] T002 Refatorar `lib/features/mensagens/ui/pages/caixa_mensagens_page.dart` removendo o botão `Painel` do `HeroHeaderPublico` e adicionando o card institucional `_PainelAdminBanner` abaixo da barra de filtros.
- [x] T003 Refatorar `lib/features/mensagens/ui/pages/grupos_personalizados_page.dart` movendo o botão `Novo Grupo` para fora do `HeroHeaderPublico`.
- [x] T004 Atualizar `test/features/mensagens/caixa_mensagens_test.dart` e validar com `flutter analyze` + `flutter test test/features/mensagens`.
- [x] T005 Gerar e instalar o novo APK de homologação no emulador Android (`emulator-5554`) para validação visual.
