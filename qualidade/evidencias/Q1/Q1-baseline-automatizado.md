# Q1 - Baseline automatizado

Data da execucao: 2026-09-25 16:30:17 -03

## Estado Git inicial

### Flutter

- Repositorio: `/home/rafaelhugo/projetosMPPB/app_mppb_flutter`
- Branch antes: `master`
- Branch Q1 criada: `qualidade/q1-rastreabilidade-funcional`
- `git status --short` antes: `M pubspec.yaml`
- Observacao: alteracao local pre-existente em `pubspec.yaml` foi preservada.
- Ultimos commits observados:
  - `383faee Merge branch 'seguranca/fechamento-tecnico-s1-s8' into 'master'`
  - `cd5c3f7 docs: fecha ciclo tecnico mobile s1 s8`
  - `385666a Merge branch 'seguranca/s8-relatorio-final-prontidao' into 'master'`

### Backend/restapi

- Repositorio: `/home/rafaelhugo/projetosMPPB/spring-boot/restapi`
- Branch antes: `master`
- Branch Q1 criada: `qualidade/q1-rastreabilidade-funcional`
- `git status --short` antes: limpo
- Ultimos commits observados:
  - `ba27c80 Atualiza versao mobile-service para 0.3.25`
  - `caab5bb Merge branch 'fix/mobile-jcr-opcional-startup' into 'master'`
  - `778eb22 fix: nao exigir jcr no startup do mobile`

## Flutter

| Comando | Resultado | Testes/falhas/warnings relevantes | Artefato |
| --- | --- | --- | --- |
| `flutter analyze` | PASSOU | `No issues found!`; aviso de versao nova do Flutter; 71 pacotes com versoes mais novas incompativeis com constraints | N/A |
| `flutter test` | FALHOU | 114 testes: 111 passaram, 3 falharam | N/A |
| `bash scripts/security/secret_scan.sh` | PASSOU | Sem saida; exit code 0 | N/A |
| `bash scripts/security/security_regression.sh` | PASSOU | Sem saida; exit code 0 | N/A |
| `flutter build apk --debug --flavor homolog -t lib/main.dart` | PASSOU | Warning de compatibilidade futura: plugins `firebase_core` e `share_plus` aplicam Kotlin Gradle Plugin | `build/app/outputs/flutter-apk/app-homolog-debug.apk` |

APK gerado:

- `build/app/outputs/flutter-apk/app-homolog-debug.apk`
- Tamanho observado: 184828361 bytes
- SHA1 companion gerado: `build/app/outputs/flutter-apk/app-homolog-debug.apk.sha1`

Falhas do `flutter test`:

| BUG | Teste | Observado | Impacto |
| --- | --- | --- | --- |
| BUG-Q1-001 | `ConcessaoAfastamentoCard afastamento eleitoral informa numero de dias sem buscar intervalos` | `showDatePicker` recebeu `initialDate 2026-09-26` que nao satisfaz `selectableDayPredicate`; apos isso ocorreu `Bad state: No element` no helper do teste | Suite Flutter nao esta verde no baseline |
| BUG-Q1-002 | `ConcessaoAfastamentoCard afastamento eleitoral bloqueia periodo com final de semana` | Mesma falha de `initialDate` nao selecionavel no date picker | Suite Flutter nao esta verde no baseline |
| BUG-Q1-003 | `ConcessaoAfastamentoCard erro da api ao marcar gozo aparece dentro do modal` | Mesma falha de `initialDate` nao selecionavel no date picker | Suite Flutter nao esta verde no baseline |

## Backend

| Comando | Resultado | Testes/falhas/warnings relevantes | Artefato |
| --- | --- | --- | --- |
| `bash restapi/mobile-service/scripts/security/secret_scan.sh` | PASSOU | Sem saida; exit code 0 | N/A |
| `bash restapi/mobile-service/scripts/security/security_regression.sh` | PASSOU | Sem saida; exit code 0 | N/A |
| `mvn -q -pl restapi-common,mobile-service test` | PASSOU | 23 classes Surefire, 126 testes, 0 falhas, 0 erros, 0 skipped; logs informativos/warnings esperados em testes de notificacao/autenticacao | Surefire reports em `target/surefire-reports` |
| `mvn -q -pl restapi-common,mobile-service -DskipTests package` | PASSOU | Sem saida; exit code 0 | Packages Maven gerados em `target/` |

## Regressao pre-existente

- Existe regressao automatizada Flutter antes da Q2: 3 testes falhando em `test/features/concessao_afastamento/concessao_afastamento_card_test.dart`.
- Nenhuma correcao foi aplicada nesta fase.

