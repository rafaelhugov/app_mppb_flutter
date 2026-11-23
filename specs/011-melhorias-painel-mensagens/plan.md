# Plan 011 — Melhorias no Painel, Anexos e Acompanhamento

1. Atualizar `EnvioMensagemNotifier` (`envio_mensagem_provider.dart`) com validação de tamanho máximo por categoria de anexo e propagação clara da mensagem de erro, e exibir `AppFeedback.showError` em `ComporMensagemPage` quando `uploadAnexo` falhar ou exceder o limite.
2. Envolver a barra de formatação de `ComporMensagemPage` em `SingleChildScrollView(scrollDirection: Axis.horizontal)` para eliminar qualquer overflow horizontal.
3. Adicionar `Timer.periodic(Duration(seconds: 5), ...)` em `AcompanhamentoMensagemPage` e `PainelRemetentePage` (com reload silencioso sem spinner bloqueante) cancelado no `dispose()`.
4. Limpar `_buscaCtrl` e resultados ao selecionar um usuário em `seletor_destinatarios_sheet.dart` e `grupo_editor_page.dart`.
5. Adicionar filtro `Ativos` / `Arquivados` (`MensagensSegmentedPillBar`) e botão de arquivar/desarquivar no card de `PainelRemetentePage`.
6. Atualizar/adicionar testes e validar com `flutter analyze` e `flutter test test/features/mensagens`.
