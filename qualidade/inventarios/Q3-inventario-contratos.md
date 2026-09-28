# Q3 - Inventario de contratos Flutter x Backend

Data: 2026-09-28
Branch: `qualidade/q3-contratos`

Total de contratos mapeados: 39.

| Modulo | Total | Criticos |
| --- | ---: | ---: |
| Auth | 1 | 1 |
| Perfil | 1 | 1 |
| Carteira funcional | 2 | 2 |
| Contracheque | 3 | 3 |
| Concessoes/Afastamentos | 12 | 12 |
| Pagamentos | 2 | 2 |
| Designacoes | 1 | 1 |
| Notificacoes/FCM | 3 | 3 |
| Processos/Captcha | 4 | 4 |
| Noticias | 1 | 1 |
| Diario Oficial | 1 | 1 |
| Certidao Extrajudicial | 3 | 3 |
| Ouvidoria | 4 | 2 |
| Health/Publico | 1 | 0 |

OpenAPI/springdoc: existente em `restapi-common` e `mobile-service`; a Q3 nao introduziu nova especificacao.

## Contratos

| ID | Modulo | Flutter | Metodo/Endpoint | Backend | Critico |
| --- | --- | --- | --- | --- | --- |
| CT-Q3-001 | Auth | `auth_provider.dart` | `POST https://auth-api.mppb.mp.br/acesso/autoriza` | `AuthServiceClient.autoriza` externo | Sim |
| CT-Q3-002 | Perfil | `PerfilRepository.buscarPerfil` | `GET /api/perfil/dados` | `PerfilUsuarioController.dados` | Sim |
| CT-Q3-003 | Carteira | `CarteiraNotifier.fetchCarteira` | `GET /carteiras-funcionais/dados` | `CarteiraFuncionalController` | Sim |
| CT-Q3-004 | Carteira foto | URL montada pelo Flutter | `GET /carteiras-funcionais/foto` | `CarteiraFuncionalController` | Sim |
| CT-Q3-005 | Contracheque | `carregarCompetencias` | `GET /contracheques/competencias` | `ContrachequeController` | Sim |
| CT-Q3-006 | Contracheque | `buscarContracheque` | `GET /contracheques/{mes}/{ano}` | `ContrachequeController` | Sim |
| CT-Q3-007 | Contracheque PDF | URL montada pelo Flutter | `GET /contracheques/{mes}/{ano}/pdf` | `ContrachequeController` | Sim |
| CT-Q3-008 | Concessoes | `buscarConcessoesVigentes` | `GET /api/recursos-humanos/minhas-concessoes-folga` | `ConcessaoFolgaController` | Sim |
| CT-Q3-009 | Concessoes | `buscarAusenciasCalendario` | `GET /api/recursos-humanos/minhas-ausencias?mes&ano` | `ConcessaoFolgaController` | Sim |
| CT-Q3-010 | Concessoes | `buscarSugestoesDatasFinais` | `GET /api/recursos-humanos/concessoes/{id}/sugestoes-datas-finais` | `ConcessaoFolgaController` | Sim |
| CT-Q3-011 | Concessoes | `solicitarGozo` | `POST /api/recursos-humanos/concessoes/{id}/solicitacoes` | `ConcessaoFolgaController` | Sim |
| CT-Q3-012 | Concessoes | repository | `GET /api/recursos-humanos/solicitacoes/{id}` | `ConcessaoFolgaController` | Sim |
| CT-Q3-013 | Concessoes | `buscarOperacoesSolicitacao` | `GET /api/recursos-humanos/solicitacoes/{id}/operacoes` | `ConcessaoFolgaController` | Sim |
| CT-Q3-014 | Concessoes | `executarOperacaoSolicitacao` | `POST /cancelamentos` | `ConcessaoFolgaController` | Sim |
| CT-Q3-015 | Concessoes | `executarOperacaoSolicitacao` | `POST /adiamentos` | `ConcessaoFolgaController` | Sim |
| CT-Q3-016 | Concessoes | `executarOperacaoSolicitacao` | `POST /antecipacoes` | `ConcessaoFolgaController` | Sim |
| CT-Q3-017 | Concessoes | `executarOperacaoSolicitacao` | `POST /interrupcoes` | `ConcessaoFolgaController` | Sim |
| CT-Q3-018 | Concessoes | `executarOperacaoSolicitacao` | `POST /suspensoes-integrais` | `ConcessaoFolgaController` | Sim |
| CT-Q3-019 | Concessoes | `executarOperacaoSolicitacao` | `POST /suspensoes-parciais` | `ConcessaoFolgaController` | Sim |
| CT-Q3-020 | Pagamentos | `fetchAnosDisponiveis` | `GET /pagamentos/exercicios` | `PagamentosController` | Sim |
| CT-Q3-021 | Pagamentos | `fetchPagamentos` | `GET /pagamentos/{exercicio}` | `PagamentosController` | Sim |
| CT-Q3-022 | Designacoes | `DesignacoesRepository.buscarAtivas` | `GET /api/designacoes/ativas` | `DesignacaoController` | Sim |
| CT-Q3-023 | FCM | `registrar` | `POST /api/notificacoes/dispositivos` | `DispositivoNotificacaoController` | Sim |
| CT-Q3-024 | FCM | `diagnosticar` | `POST /api/notificacoes/dispositivos/diagnostico` | `DispositivoNotificacaoController` | Sim |
| CT-Q3-025 | FCM | `desativar` | `DELETE /api/notificacoes/dispositivos/{id}` | `DispositivoNotificacaoController` | Sim |
| CT-Q3-026 | Processos | `carregarFiltros` | `GET /api/public/v1/processos/filtros` | `ProcessoConsultaPublicaController` | Sim |
| CT-Q3-027 | Processos | `buscarProcessos` | `POST /api/public/v1/processos/consulta` | `ProcessoConsultaPublicaController` | Sim |
| CT-Q3-028 | Captcha | `captchaProvider` | `GET /api/public/v1/captcha` | `CaptchaController` | Sim |
| CT-Q3-029 | Processos | `processoDetalhesProvider` | `GET /api/public/v1/processos/{id}/detalhes` | `ProcessoDetalhesController` | Sim |
| CT-Q3-030 | Noticias | `NoticiaNotifier` | `GET /api/public/noticias` | `NoticiaController` | Sim |
| CT-Q3-031 | Diario | `DiarioOficialNotifier` | `GET /api/public/diarios-oficiais/recentes` | `PublicoDiarioOficialController` | Sim |
| CT-Q3-032 | Certidao | `emitirPdf` | `POST /api/public/certidoes-extrajudiciais/pdf` | `CertidaoExtrajudicialController` | Sim |
| CT-Q3-033 | Certidao | `consultarCodigo` | `GET /api/public/certidoes-extrajudiciais/codigo/{codigo}` | `CertidaoExtrajudicialController` | Sim |
| CT-Q3-034 | Certidao | `baixarPdfPorCodigo` | `GET /api/public/certidoes-extrajudiciais/codigo/{codigo}/pdf` | `CertidaoExtrajudicialController` | Sim |
| CT-Q3-035 | Ouvidoria | `fetchTipos` | externo `/tipos` | N/A no `mobile-service` | Nao |
| CT-Q3-036 | Ouvidoria | `fetchAssuntos` | externo `/assuntos/{id}` | N/A no `mobile-service` | Nao |
| CT-Q3-037 | Ouvidoria | `fetchMunicipios/fetchBairros` | externo `/municipios`, `/bairros?municipio` | N/A no `mobile-service` | Nao |
| CT-Q3-038 | Ouvidoria | `ManifestacaoRequestModel.toFormDataMap` | externo manifestacao multipart/form | N/A no `mobile-service` | Sim |
| CT-Q3-039 | Health | `connectivity_provider.dart` | `GET /api/public/health` | `PublicHealthController` | Nao |

