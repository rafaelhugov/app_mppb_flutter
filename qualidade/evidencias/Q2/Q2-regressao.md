# Q2 - Regressao de componentes

Data: 2026-09-28
Branch: `qualidade/q2-testes-componentes`

## Q2-T01 - ConcessaoAfastamentoCard

Falha reproduzida: testes de widget de `ConcessaoAfastamentoCard` quebravam quando o `showDatePicker` recebia `initialDate` que nao satisfazia o `selectableDayPredicate`.

Correcao aplicada:
- `ConcessaoAfastamentoCard._selecionarData()` passou a calcular `firstDate`, `lastDate`, `selectableDayPredicate` e `initialDate` de forma consistente.
- Novo helper `_initialSelectableDate(...)` escolhe uma data inicial dentro do intervalo e permitida pelo predicado, tentando primeiro avancar e depois retroceder.
- Fixture de afastamento eleitoral ajustada para cobrir periodo com fim de semana sem bater antes na regra de maximo de dias.

Evidencia:
- `flutter test test/features/concessao_afastamento/concessao_afastamento_card_test.dart`: 11/11 passando.
- `flutter test`: 143/143 passando no gate final.

## Testes adicionados na Q2

Total liquido adicionado: 29 testes Flutter.

Arquivos:
- `test/features/auth/auth_provider_test.dart`: 7 testes.
- `test/features/carteira/carteira_provider_test.dart`: 3 testes.
- `test/features/pagamentos/pagamentos_provider_test.dart`: 3 testes.
- `test/features/diario_oficial/diario_oficial_provider_test.dart`: 3 testes.
- `test/features/certidao_extrajudicial/certidao_extrajudicial_provider_test.dart`: 4 testes.
- `test/features/ouvidoria/ouvidoria_formatters_test.dart`: 3 testes.
- `test/features/contra_cheque/contracheque_model_test.dart`: 3 testes.
- `test/features/perfil/perfil_provider_test.dart`: 3 testes.
- `test/helpers/fake_dio.dart`: adaptador fake compartilhado para testes de providers/repositories.

