# Q1 - Rastreabilidade funcional

| RF | Codigo Flutter | Endpoint | Codigo Backend | Teste atual | Lacuna | Fase responsavel |
| --- | --- | --- | --- | --- | --- | --- |
| RF-001 | `main.dart`, `app_router.dart`, `public_dashboard_page.dart`, `connectivity_provider.dart` | `GET /api/public/health` | `PublicHealthController` | `widget_test.dart`, `responsive_layout_test.dart`, `ValidadorConfiguracaoSeguraTest` | Sem E2E/mobile, offline/timeout e matriz de dispositivos | Q2/Q5/Q7/Q9 |
| RF-002 | `noticia_provider.dart`, `noticias_page.dart`, `news_carousel.dart` | `GET /api/public/noticias` | `NoticiaController`, `NoticiaService` | Backend notificacao noticias; push/central | Sem teste Flutter provider/UI especifico e contrato | Q2/Q3/Q4/Q5 |
| RF-003 | `diario_oficial_provider.dart`, `diario_oficial_page.dart` | `GET /api/public/diarios-oficiais/recentes` | `PublicoDiarioOficialController`, `DiarioOficialService` | Nenhum especifico encontrado | Sem testes unit/widget/service/contrato | Q2/Q3/Q4/Q5 |
| RF-004 | `processos_provider.dart`, `consulta_processos_page.dart` | `GET /api/public/v1/processos/filtros`, `POST /api/public/v1/processos/consulta` | `ProcessoConsultaPublicaController`, `ProcessoConsultaService` | `processo_date_formatter_test.dart`, `ProcessoConsultaServiceTest`, `ProtocoloConsultaRepositoryTest` | UI states, contrato e integracao com massa | Q2/Q3/Q4/Q5/Q7 |
| RF-005 | `processos_provider.dart`, `processo_detalhes_page.dart` | `GET /api/public/v1/captcha`, `GET /api/public/v1/processos/{id}/detalhes` | `CaptchaController`, `ProcessoDetalhesController`, `CaptchaValidationService` | `ProcessoDetalhesRepositoryTest` | Flutter captcha/detalhe, negativos 400/403/timeout | Q2/Q3/Q4/Q5/Q7 |
| RF-006 | `certidao_extrajudicial_provider.dart`, `certidao_extrajudicial_page.dart` | `POST /api/public/certidoes-extrajudiciais/pdf` | `CertidaoExtrajudicialController`, `CertidaoExtrajudicialService` | Nenhum especifico encontrado | Contrato PDF, validacoes, dependencia externa | Q2/Q3/Q4/Q5/Q12 |
| RF-007 | mesmos de RF-006 | `GET /api/public/certidoes-extrajudiciais/codigo/{codigo}`, `GET /codigo/{codigo}/pdf` | mesmos de RF-006 | Nenhum especifico encontrado | Consulta inexistente/valida, PDF e erros | Q2/Q3/Q4/Q5 |
| RF-008 | `ouvidoria_provider.dart`, `ouvidoria_page.dart`, `upload_service.dart`, `captcha_service.dart` | Endpoints externos de ouvidoria/upload/captcha | Nao identificado no `mobile-service` | Nenhum especifico encontrado | Contrato externo, anexos, captcha, estados UI | Q2/Q3/Q4/Q5/Q12 |
| RF-009 | `dados_institucionais.dart`, `servico_links_externos.dart`, `contatos_page.dart` | N/A | N/A | `contatos_test.dart`, `contatos_ui_test.dart` | Acessibilidade, dispositivos e E2E navegacao | Q2/Q5/Q9/Q11 |
| RF-010 | `auth_provider.dart`, `login_page.dart`, `secure_storage.dart` | `POST https://auth-api.mppb.mp.br/acesso/autoriza` | `AuthServiceClient`, filtros common | filtros common, biometria/storage | Sem teste login Flutter e sem smoke autenticado | Q2/Q3/Q4/Q5/Q7/Q12 |
| RF-011 | `perfil_provider.dart`, `perfil_repository.dart`, `perfil_page.dart` | `GET /api/perfil/dados` | `PerfilUsuarioController`, `PerfilUsuarioService` | Nenhum especifico encontrado | Unit/provider/service/contrato/cache | Q2/Q3/Q4/Q5 |
| RF-012 | `carteira_provider.dart`, `carteira_page.dart`, `usuario_carteira.dart` | `/carteiras-funcionais/*` | `CarteiraFuncionalController`, `CarteiraService`, `JcrService` | `usuario_carteira_test.dart`, `CarteiraServiceTest` | Widget/PDF/cache offline/contrato e massa real | Q2/Q3/Q4/Q5/Q7/Q9/Q10 |
| RF-013 | `contra_cheque_provider.dart`, `contra_cheque_page.dart`, widgets | `/contracheques/*` | `ContrachequeController`, `ContrachequeService`, `ContrachequePdfService` | `contracheque_apresentacao_test.dart` | Backend service/repository/PDF, contrato e E2E | Q2/Q3/Q4/Q5/Q7/Q8 |
| RF-014 | `pagamentos_provider.dart`, `pagamentos_page.dart`, `pagamento_model.dart` | `/pagamentos/exercicios`, `/pagamentos/{exercicio}` | `PagamentosController`, `PagamentosService` | Nenhum especifico encontrado | Unit/provider/backend/contrato | Q2/Q3/Q4/Q5 |
| RF-015 | `designacoes_provider.dart`, `designacoes_repository.dart`, `designacoes_page.dart` | `GET /api/designacoes/ativas` | `DesignacaoController`, services/repos/scheduler | Flutter model/widget; controller/mapper/services backend | Contrato, E2E autenticado, estados vazios/timeout | Q2/Q3/Q4/Q5/Q7 |
| RF-016 | `concessao_afastamento_provider.dart`, `concessao_afastamento_repository.dart`, page/widgets | `GET /api/recursos-humanos/*` | `ConcessaoFolgaController`, `ConcessaoFolgaService` | model/repository/widget Flutter; controller/repository backend | 3 falhas atuais, integracao MPVirtual, runtime autenticado | Q2/Q3/Q4/Q5/Q7 |
| RF-017 | mesmos de RF-016 | `POST /api/recursos-humanos/*` operacoes | mesmos de RF-016 | mesmos de RF-016 | Idempotencia/duplo clique/concorrencia, contratos negativos | Q2/Q3/Q4/Q5/Q6/Q7/Q12 |
| RF-018 | notificacoes core Flutter | `/api/notificacoes/dispositivos*` | `DispositivoNotificacaoController`, FCM services/schedulers | ampla base Flutter/backend | Sem teste device/FCM real, resiliencia externa | Q2/Q3/Q4/Q5/Q7/Q12 |
| RF-019 | `main_layout.dart`, `services_bottom_sheet.dart`, rotas | N/A | N/A | layout, contatos, push navigation | E2E navegacao, acessibilidade e matriz de resolucoes | Q2/Q5/Q9/Q11 |

## Atualizacao Q2 - 2026-09-28

| RF | Status Q2 | Evidencia |
| --- | --- | --- |
| RF-003 | Cobertura de provider adicionada | `test/features/diario_oficial/diario_oficial_provider_test.dart` |
| RF-006/RF-007 | Cobertura de provider adicionada | `test/features/certidao_extrajudicial/certidao_extrajudicial_provider_test.dart` |
| RF-008 | Cobertura de formatadores adicionada | `test/features/ouvidoria/ouvidoria_formatters_test.dart` |
| RF-010 | Cobertura de auth provider adicionada | `test/features/auth/auth_provider_test.dart` |
| RF-011 | Cobertura de perfil provider adicionada | `test/features/perfil/perfil_provider_test.dart` |
| RF-012 | Cobertura de carteira provider/cache adicionada | `test/features/carteira/carteira_provider_test.dart` |
| RF-013 | Cobertura de modelo de contracheque adicionada | `test/features/contra_cheque/contracheque_model_test.dart` |
| RF-014 | Cobertura de pagamentos provider adicionada | `test/features/pagamentos/pagamentos_provider_test.dart` |
| RF-016/RF-017 | Regressao Q2-T01 corrigida | `test/features/concessao_afastamento/concessao_afastamento_card_test.dart` |

Gate Q2 final:
- `flutter analyze`: passou.
- `flutter test`: passou, 143/143.
- `flutter test --coverage`: passou, 143/143, LCOV 32,61%.
- Backend `mobile-service`: scans, testes Maven e package passaram.
