# Q2 - Cobertura de componentes

Data: 2026-09-28
Branch: `qualidade/q2-testes-componentes`

## Resumo

| Area | Status Q2 | Evidencia |
| --- | --- | --- |
| Auth | Coberto parcialmente | `auth_provider_test.dart` cobre sessao inicial, login, erros, token ausente e logout/cache. |
| Carteira | Coberto parcialmente | `carteira_provider_test.dart` cobre API, cache offline e descarte por usuario. |
| Contracheque | Coberto parcialmente | `contracheque_model_test.dart` cobre parsing de competencia/lancamentos/ausencias. |
| Concessoes/afastamentos | Coberto parcialmente | Regressao Q2-T01 corrigida e suite de widget/repository existente verde. |
| Perfil | Coberto parcialmente | `perfil_provider_test.dart` cobre API, cache e descarte por usuario. |
| Pagamentos | Coberto parcialmente | `pagamentos_provider_test.dart` cobre exercicios, dados e 404 como vazio. |
| Diario Oficial | Coberto parcialmente | `diario_oficial_provider_test.dart` cobre recentes, paginacao, vazio e erro. |
| Certidao extrajudicial | Coberto parcialmente | `certidao_extrajudicial_provider_test.dart` cobre consulta, erro textual e PDF. |
| Ouvidoria | Coberto parcialmente | `ouvidoria_formatters_test.dart` cobre CPF, CNPJ e telefone. |
| Backend mobile-service | Sem alteracao funcional Q2 | Suite backend existente reexecutada: `mvn -q -pl restapi-common,mobile-service test`. |
| Runtime Android | Parcial | App abriu Home publica; Pixel_8 caiu depois; Pixel_9 ficou disponivel para ADB/logcat. |

## Rastreabilidade por RF

| RF | Q2 entregue | Arquivos de teste |
| --- | --- | --- |
| RF-002 Noticias | Nao ampliado nesta fase | Cobertura existente de push/notificacoes mantida; lacuna de provider/UI especifico permanece para Q3/Q5. |
| RF-003 Diario Oficial | Sim | `test/features/diario_oficial/diario_oficial_provider_test.dart` |
| RF-006/RF-007 Certidao extrajudicial | Sim | `test/features/certidao_extrajudicial/certidao_extrajudicial_provider_test.dart` |
| RF-008 Ouvidoria | Sim, formatadores | `test/features/ouvidoria/ouvidoria_formatters_test.dart` |
| RF-010 Auth | Sim | `test/features/auth/auth_provider_test.dart` |
| RF-011 Perfil | Sim | `test/features/perfil/perfil_provider_test.dart` |
| RF-012 Carteira | Sim | `test/features/carteira/carteira_provider_test.dart` |
| RF-013 Contracheque | Sim | `test/features/contra_cheque/contracheque_model_test.dart` |
| RF-014 Pagamentos | Sim | `test/features/pagamentos/pagamentos_provider_test.dart` |
| RF-016/RF-017 Concessoes | Sim | `test/features/concessao_afastamento/concessao_afastamento_card_test.dart` |

## Gate final

| Comando | Resultado |
| --- | --- |
| `flutter analyze` | Passou, sem issues. |
| `flutter test` | Passou, 143/143. |
| `flutter test --coverage` | Passou, 143/143; `coverage/lcov.info` gerado. |
| Cobertura LCOV | 3516/10781 linhas, 32,61%. |
| `bash scripts/security/secret_scan.sh` | Passou, sem saida. |
| `bash scripts/security/security_regression.sh` | Passou, sem saida. |
| `flutter build apk --debug --flavor homolog -t lib/main.dart` | Passou; APK em `build/app/outputs/flutter-apk/app-homolog-debug.apk`. |
| `bash restapi/mobile-service/scripts/security/secret_scan.sh` | Passou, sem saida. |
| `bash restapi/mobile-service/scripts/security/security_regression.sh` | Passou, sem saida. |
| `mvn -q -pl restapi-common,mobile-service test` | Passou. |
| `mvn -q -pl restapi-common,mobile-service -DskipTests package` | Passou. |

