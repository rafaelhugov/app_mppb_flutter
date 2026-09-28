# Q3 - Rastreabilidade de contratos

| Area | Evidencia Flutter | Evidencia Backend | Resultado |
| --- | --- | --- | --- |
| Auth | `test/features/contratos/q3_flutter_backend_contract_test.dart` | `AuthServiceClient` mapeado | COMPATIVEL |
| Perfil | mesmo teste Q3 | `PerfilUsuarioController` | COMPATIVEL |
| Carteira | mesmo teste Q3 + Q2 provider | `CarteiraServiceTest` existente | PARCIAL para foto binaria |
| Contracheque | mesmo teste Q3 + model tests | `ContrachequeController` mapeado | COMPATIVEL |
| Concessoes | mesmo teste Q3 + repository/widget tests | `ConcessaoFolgaControllerTest` | COMPATIVEL/PARCIAL |
| Pagamentos | mesmo teste Q3 | `PagamentosController` mapeado | COMPATIVEL |
| Designacoes | mesmo teste Q3 | `DesignacaoControllerTest` | COMPATIVEL |
| FCM | mesmo teste Q3 + provider tests | `DispositivoNotificacaoControllerTest` | COMPATIVEL |
| Processos/Captcha | mesmo teste Q3 | repository/service tests existentes | COMPATIVEL |
| Noticias/Diario | mesmo teste Q3 | controllers/services mapeados | COMPATIVEL |
| Certidao | mesmo teste Q3 | `CertidaoExtrajudicialControllerContractTest` | COMPATIVEL |
| Ouvidoria | formatadores Q2/modelo | backend local N/A | PARCIAL/NAO TESTADO |

## Q2 x Q3

| Fluxo | Q2 | Q3 | Resultado |
| --- | --- | --- | --- |
| Auth | OK | OK contrato | OK |
| Perfil | OK | OK contrato | OK |
| Carteira | OK | OK contrato parcial foto | OK |
| Contracheque | OK | OK contrato | OK |
| Concessoes | OK | OK contrato | OK |
| Pagamentos | OK | OK contrato | OK |
| Diario Oficial | OK | OK contrato | OK |
| Certidao | OK | OK contrato | OK |
| Ouvidoria | OK formatadores | Parcial externo | OK |
| Runtime Android Home | OK parcial | OK Home, queda posterior do emulador | FALHA AMBIENTAL |
| Fluxo autenticado runtime | NAO EXECUTADO | NAO EXECUTADO | BLOQUEADO sem credenciais |

