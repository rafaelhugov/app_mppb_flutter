# Q1 - Inventario de testes existentes

Data da auditoria: 2026-09-25 16:30:17 -03

## Resumo

| Repositorio | Arquivos/classes | Casos executados no baseline | Resultado |
| --- | ---: | ---: | --- |
| Flutter | 20 arquivos em `test/` | 114 | 111 passaram, 3 falharam |
| Backend | 23 classes Surefire | 126 | 126 passaram |

## Flutter

| Arquivo | Tipo | Funcionalidades vinculadas | Observacao |
| --- | --- | --- | --- |
| `test/widget_test.dart` | widget/smoke | RF-001 | Harness basico renderiza. |
| `test/core/ui/responsive_layout_test.dart` | widget/UI | RF-001, RF-019 | Layout responsivo. |
| `test/core/ui/notification_center_sheet_test.dart` | widget/UI | RF-018 | Central de notificacoes. |
| `test/core/notifications/device_registration_provider_test.dart` | provider/state/service | RF-018 | Registro/desativacao FCM, erros e logout. |
| `test/core/notifications/device_registration_repository_test.dart` | repository | RF-018 | Contrato dos endpoints de dispositivo. |
| `test/core/notifications/notification_center_provider_test.dart` | provider/state | RF-002, RF-015, RF-018 | Montagem e filtro de notificacoes. |
| `test/core/notifications/push_navigation_service_test.dart` | navigation/service | RF-002, RF-013, RF-014, RF-015, RF-018 | Rotas permitidas e duplicidade. |
| `test/core/notifications/push_notification_service_test.dart` | service/security regression | RF-018 | Payload tecnico permitido. |
| `test/security/android_cleartext_manifest_test.dart` | security regression/config | RF-001 | Manifest Android cleartext. |
| `test/security/biometric_password_storage_test.dart` | security regression | RF-010 | Nao gravar/reutilizar senha biometrica legada. |
| `test/features/carteira/usuario_carteira_test.dart` | unit/model | RF-012 | Parse/model de carteira. |
| `test/features/concessao_afastamento/concessao_afastamento_models_test.dart` | unit/model | RF-016, RF-017 | Modelos/tipos de concessao. |
| `test/features/concessao_afastamento/concessao_afastamento_repository_test.dart` | repository/contract parcial | RF-016, RF-017 | Caminhos de endpoint e payloads. |
| `test/features/concessao_afastamento/concessao_afastamento_card_test.dart` | widget/UI | RF-016, RF-017 | 3 falhas no baseline atual. |
| `test/features/contatos/contatos_test.dart` | unit | RF-009 | Dados/links institucionais. |
| `test/features/contatos/contatos_ui_test.dart` | widget/UI | RF-009, RF-019 | Card publico e rodape autenticado. |
| `test/features/contra_cheque/contracheque_apresentacao_test.dart` | widget/unit apresentacao | RF-013 | Grafico/lancamentos. |
| `test/features/designacoes/designacao_ativa_test.dart` | unit/model | RF-015 | Parse/periodo/ato tecnico. |
| `test/features/designacoes/designacao_card_test.dart` | widget/UI | RF-015 | Card de designacao. |
| `test/features/processos/processo_date_formatter_test.dart` | unit | RF-004, RF-005 | Formatacao de data. |

Classificacao atual Flutter:

| Tipo | Quantidade de arquivos |
| --- | ---: |
| unit/model/utils | 6 |
| widget/UI | 7 |
| provider/state | 3 |
| repository/contract parcial | 2 |
| service/navigation | 3 |
| security regression/config | 3 |
| integration/E2E | 0 |

Alguns arquivos exercem mais de um tipo; por isso a soma por tipo supera 20.

## Backend

| Classe | Tipo | Funcionalidades vinculadas | Casos |
| --- | --- | --- | ---: |
| `ValidadorConfiguracaoSeguraTest` | configuration/security | RF-001 | 6 |
| `CarteiraServiceTest` | service | RF-012 | 1 |
| `ConcessaoFolgaControllerTest` | controller | RF-016, RF-017 | 3 |
| `OperacaoSolicitacaoRequestDtoTest` | dto/unit | RF-017 | 1 |
| `ConcessaoFolgaRemoteRepositoryTest` | repository | RF-016, RF-017 | 4 |
| `DesignacaoControllerTest` | controller | RF-015 | 3 |
| `DesignacaoMapperTest` | unit/mapper | RF-015 | 7 |
| `DesignacaoNotificacaoSchedulerTest` | scheduler/service | RF-015, RF-018 | 8 |
| `DesignacaoNotificacaoServiceTest` | service | RF-015, RF-018 | 13 |
| `DesignacaoProcessamentoNotificacaoServiceTest` | service | RF-015, RF-018 | 17 |
| `NoticiaDeteccaoServiceTest` | service | RF-002, RF-018 | 3 |
| `NoticiaProcessamentoNotificacaoServiceTest` | service | RF-002, RF-018 | 3 |
| `FirebaseConfigTest` | configuration | RF-018 | 5 |
| `DispositivoNotificacaoControllerTest` | controller | RF-018 | 11 |
| `DispositivoFcmServiceTest` | service/repository | RF-018 | 10 |
| `FcmSenderServiceTest` | service | RF-018 | 15 |
| `ProtocoloConsultaRepositoryTest` | repository | RF-004 | 1 |
| `ProcessoConsultaServiceTest` | service | RF-004 | 3 |
| `ProcessoDetalhesRepositoryTest` | repository | RF-005 | 1 |
| `AuthApiTokenDtoTest` | dto/unit | RF-010 | 2 |
| `SecurityUtilsTest` | security/unit | RF-010 | 2 |
| `CustomBasicAuthenticationFilterTest` | security/filter | RF-010 | 5 |
| `CustomUsernamePasswordAuthenticationFilterTest` | security/filter | RF-010 | 2 |

Classificacao atual Backend:

| Tipo | Quantidade de classes |
| --- | ---: |
| unit/dto/mapper | 4 |
| controller | 3 |
| service/scheduler | 9 |
| repository | 4 |
| security/configuration/filter | 5 |
| Spring context/integration ampla | 0 |
| E2E | 0 |

