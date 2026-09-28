# Q4 - Regressao

Data: 2026-09-28

| Verificacao | Flutter | Backend | Resultado |
| --- | --- | --- | --- |
| Analise estatica | `flutter analyze` | N/A | Verde, sem issues |
| Testes | `flutter test --coverage`: 157/157 | `mvn -q -pl restapi-common,mobile-service test`: 136/136 | Verde |
| Cobertura | 10783 linhas, 3732 cobertas, 34.61% | Nao consolidada por JaCoCo nesta fase | Registrada |
| Security gate 1 | `bash scripts/security/secret_scan.sh` | `bash restapi/mobile-service/scripts/security/secret_scan.sh` | Verde |
| Security gate 2 | `bash scripts/security/security_regression.sh` | `bash restapi/mobile-service/scripts/security/security_regression.sh` | Verde |
| Build/package | `flutter build apk --debug --flavor homolog -t lib/main.dart` | `mvn -q -pl restapi-common,mobile-service -DskipTests package` | Verde |

## Artefatos

- APK homolog debug: `build/app/outputs/flutter-apk/app-homolog-debug.apk`
- Tamanho do APK: 263756291 bytes
- Cobertura Flutter: `coverage/lcov.info`
- Relatorios Surefire backend: `restapi-common/target/surefire-reports` e `mobile-service/target/surefire-reports`

## Observacoes

- O primeiro `flutter analyze` em sandbox restrito falhou ao tentar escrever no cache global do SDK. O comando foi repetido com permissao ampliada e passou.
- O `pubspec.yaml` permaneceu como alteracao local preexistente somente na versao `4.0.0+69` para `4.0.0+72`.
