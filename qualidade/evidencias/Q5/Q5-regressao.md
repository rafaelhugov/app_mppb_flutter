# Q5 - Regressao

Data: 2026-09-29

## Flutter

| Verificacao | Resultado |
| --- | --- |
| `flutter analyze` | VERDE - `No issues found!` |
| `flutter test` | VERDE - 157/157 |
| `flutter test --coverage` | VERDE - 157/157 |
| Cobertura | 34.61% linhas, 3733/10787 |
| `bash scripts/security/secret_scan.sh` | VERDE |
| `bash scripts/security/security_regression.sh` | VERDE |
| `flutter build apk --debug --flavor homolog -t lib/main.dart` | VERDE - `build/app/outputs/flutter-apk/app-homolog-debug.apk`, 184828323 bytes |

## Q5-R01 E2E Android

| Verificacao | Resultado |
| --- | --- |
| Smoke minimo Pixel_8 | VERDE - 3/3 |
| Smoke minimo Pixel_9 | VERDE - 1/1 |
| Jornada publica completa Pixel_8 | BLOQUEADA - `adb: device offline` |
| Jornada publica completa Pixel_9 | BLOQUEADA - `adb: device offline` |

## Backend

| Verificacao | Resultado |
| --- | --- |
| `bash restapi/mobile-service/scripts/security/secret_scan.sh` | VERDE |
| `bash restapi/mobile-service/scripts/security/security_regression.sh` | VERDE |
| `mvn -q -pl restapi-common,mobile-service test` | VERDE - 136 testes, 0 erros, 0 falhas, 0 skipped |
| `mvn -q -pl restapi-common,mobile-service -DskipTests package` | VERDE |

## Observacao Maven

Uma execucao concorrente de `mvn test` com `mvn package` retornou erro de fork ao criar `AuthApiTokenDtoTest`. A repeticao isolada do comando obrigatorio `mvn -q -pl restapi-common,mobile-service test` passou, e os reports finais do Surefire registram 136 testes sem erro/falha.
