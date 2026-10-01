# Inventário de Resiliência, Observabilidade e Recuperação — App MPPB (Q12)

**Data de Execução:** 01/10/2026  
**Fase:** Q12 — Resiliência, Observabilidade e Recuperação  
**Reconciliação:** Q12-R02 — Correção Documental Residual e Consolidação Definitiva  
**Ambiente:** Flutter (Front-end) + Spring Boot (Back-end mobile-service e restapi-common)  
**Dispositivo Físico:** Samsung Galaxy A52 (SM-A525M, Android 14 / One UI 6.1, API 34)

---

## 1. Visão Geral e Critérios Metodológicos Reconciliados

Este inventário cataloga sistematicamente os mecanismos de detecção, isolamento, registro e recuperação de falhas em ambas as camadas da arquitetura. Conforme diretrizes canônicas da fase Q12 e calibrações da Q12-R02:
- **Observabilidade Estruturada / Padronizada:** Mecanismo centralizado e padronizado na arquitetura da aplicação (e.g. `@RestControllerAdvice`, SLF4J/Logback com nível/timestamp/thread/contexto, máquina de estados FCM). Não implica serialização JSON, a menos que especificado.
- **Observabilidade Parcial:** Logs operacionais locais informativos, mapeamento pontual em `state.errorMessage`, fallbacks locais ou configurações padrão herdadas de framework sem instrumentação distribuída.
- **Somente Desenvolvimento:** Uso exclusivo de `print()`, `debugPrint()`, ou fallbacks nativos visíveis apenas em console/terminal.
- **Ausente:** Inexistência comprovada de mecanismo ativo no código de produção.
- **N/A:** Não aplicável ao componente.

---

## 2. Inventário de Mecanismos — Flutter

| ID | Componente | Falha Possível | Detecção | Log / Telemetria | Recuperação | Evidência |
|---|---|---|---|---|---|---|
| `FLUTTER-ERR-01` | Root App (`lib/main.dart`) | Exceção síncrona na árvore de widgets | Engine Flutter (`ErrorWidget.builder` default) | SOMENTE DESENVOLVIMENTO (Console stderr via Flutter engine) | `ErrorWidget` padrão exibido na tela; árvore pai permanece viva | [Q12-flutter-erros-globais.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-flutter-erros-globais.md) |
| `FLUTTER-ERR-02` | Root App (`lib/main.dart`) | Exceção assíncrona não tratada no Isolate | Ausente no `main()` (`PlatformDispatcher.instance.onError` não configurado) | AUSENTE (Não há Crashlytics/Sentry ou handler global registrado) | Não há captura centralizada no isolate de produção; erro cai no default do Dart | [Q12-flutter-erros-globais.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-flutter-erros-globais.md) |
| `FLUTTER-ERR-03` | Notícia Provider (`NoticiaNotifier`) | Falha 5xx, timeout ou erro de rede | `try-catch` em `fetchNoticias()` | PARCIAL (Armazena mensagem no `state.errorMessage`) | `isLoading = false`, dados preservados ou tela de erro com retry | [Q12-providers-recuperacao.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-providers-recuperacao.md) |
| `FLUTTER-ERR-04` | Perfil Provider (`PerfilNotifier`) | Timeout de rede ou 5xx na API de perfil | `try-catch` em `carregar()` | PARCIAL (Grava `errorMessage`, log interno) | Fallback transparente para cache offline no Secure Storage | [Q12-providers-recuperacao.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-providers-recuperacao.md) |
| `FLUTTER-ERR-05` | Carteira Provider (`CarteiraNotifier`) | Falha de conexão ou 5xx no endpoint de dados | `try-catch` em `fetchCarteira()` | PARCIAL (Define flag `isOffline = true` e `errorMessage`) | Fallback automático para cache offline criptografado | [Q12-providers-recuperacao.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-providers-recuperacao.md) |
| `FLUTTER-ERR-06` | Consulta Processos (`ConsultaProcessosNotifier`) | Erro de busca ou protocolo inválido | `try-catch` em `pesquisar()` | PARCIAL (`state.errorMessage` amigável) | `isLoading = false`, permite nova consulta imediatamente | [Q12-providers-recuperacao.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-providers-recuperacao.md) |
| `FLUTTER-ERR-07` | Designações Provider (`DesignacoesNotifier`) | Timeout ou indisponibilidade downstream | `try-catch` no carregamento | PARCIAL (`errorMessage` mapeado) | Reset de loading, retry manual disponível | [Q12-providers-recuperacao.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-providers-recuperacao.md) |
| `FLUTTER-ERR-08` | Pagamentos Provider (`PagamentosNotifier`) | Falha na busca de anos ou demonstrativo | `try-catch` em `fetchPagamentos()` | PARCIAL (`errorMessage` contextualizado) | Estado consistente, permite selecionar outro ano ou retry | [Q12-providers-recuperacao.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-providers-recuperacao.md) |
| `FLUTTER-ERR-09` | Contracheque Provider (`ContraChequeNotifier`) | Falha 503 ou downstream fora do ar | `try-catch` em `carregarCompetencias()` | PARCIAL (`errorMessage` exibido na tela) | Loading liberado, retry manual restaura estado | [Q12-providers-recuperacao.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-providers-recuperacao.md) |
| `FLUTTER-ERR-10` | Rede / HTTP Client (`ApiClient`, `Dio`) | Timeout, queda de socket, certificado | Tipos de erro `DioExceptionType` | PARCIAL (Mapeamento de exceções no Dio) | Sem retry automático no interceptor; devolve exceção aos callers | [Q12-observabilidade.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-observabilidade.md) |
| `FLUTTER-ERR-11` | Sessão (`AuthNotifier`, `sessionResetProvider`) | Token expirado (HTTP 401) | Interceptor Dio detecta 401 | PARCIAL (Log informativo no logout) | Invalidação atômica de todos os providers autenticados | [Q12-providers-recuperacao.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-providers-recuperacao.md) |
| `FLUTTER-ERR-12` | Armazenamento Seguro (`FlutterSecureStorage`) | JSON malformado ou corrompido no cache | `try-catch` ao redor de `jsonDecode()` | SOMENTE DESENVOLVIMENTO (Catch genérico com fallback) | Descarta cache quebrado, limpa loading e exibe erro amigável | [Q12-storage-recuperacao.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-storage-recuperacao.md) |
| `FLUTTER-ERR-13` | Notificações FCM (`DeviceRegistrationManager`) | Falha ao obter token push ou permissão | `try-catch` em `registrarSeAutenticado()` | ESTRUTURADO (`DeviceRegistrationDiagnosticsState`) | Diagnóstico registrado, app inicializa sem travar UI | [Q12-observabilidade.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-observabilidade.md) |
| `FLUTTER-ERR-14` | Imagens Remotas (`CachedNetworkImage`) | 404, timeout ou imagem corrompida | `errorWidget` callback | PARCIAL (Callback de erro local) | Ícone de fallback visual sem quebrar o layout | [Q12-flutter-erros-globais.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-flutter-erros-globais.md) |
| `FLUTTER-ERR-15` | Visualizador PDF (`DiarioOficialPage`) | PDF inválido ou stream interrompido | `onError` callback do `PdfPreview` | PARCIAL (Mensagem de falha na página) | Exibe banner informativo e botão para abrir no browser | [Q12-flutter-erros-globais.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-flutter-erros-globais.md) |
| `FLUTTER-ERR-16` | Ciclo de Vida Android (`AppLifecycleState`) | Background/foreground, troca de app | Lifecycle callbacks da Flutter Engine | PARCIAL (Gerenciado pelo framework) | Estado volátil preservado na RAM; retomada imediata de foco | [Q12-lifecycle-android.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-lifecycle-android.md) |
| `FLUTTER-ERR-17` | Morte do Processo Android | `force-stop` via SO ou ADB | Inicialização do zero via `main()` | SOMENTE DESENVOLVIMENTO | Mecanismo de KeyStore permanece operacional, recarrega limpo sem reinstalação | [Q12-lifecycle-android.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-lifecycle-android.md) |

---

## 3. Inventário de Mecanismos — Backend (`mobile-service` & `restapi-common`)

| ID | Componente | Falha Possível | Detecção | Log / Telemetria | Recuperação | Evidência |
|---|---|---|---|---|---|---|
| `BACKEND-ERR-01` | Exception Handler Global (`ApiExceptionHandler`) | Qualquer exceção não capturada | `@RestControllerAdvice` | ESTRUTURADO (SLF4J/Logback com nível e mensagem segura) | Resposta ProblemDetail RFC 7807 com status HTTP apropriado | [Q12-backend-excecoes.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-backend-excecoes.md) |
| `BACKEND-ERR-02` | Regra de Negócio (`BusinessRuleException`) | Validação de domínio ou regra violada | `@ExceptionHandler(BusinessRuleException.class)` | ESTRUTURADO (WARN com mensagem amigável) | Retorna HTTP 422 Unprocessable Entity sem stacktrace | [Q12-backend-excecoes.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-backend-excecoes.md) |
| `BACKEND-ERR-03` | Recurso Não Encontrado (`NotFoundException`) | Entidade inexistente no banco ou downstream | `@ExceptionHandler(NotFoundException.class)` | ESTRUTURADO (WARN com identificador seguro) | Retorna HTTP 404 Not Found com ProblemDetail padronizado | [Q12-backend-excecoes.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-backend-excecoes.md) |
| `BACKEND-ERR-04` | Falha Transitória Downstream (`RetryableException`) | Timeout ou indisponibilidade temporária | `@ExceptionHandler(RetryableException.class)` | ESTRUTURADO (ERROR com contexto de downstream) | Retorna HTTP 503 Service Unavailable | [Q12-backend-excecoes.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-backend-excecoes.md) |
| `BACKEND-ERR-05` | Falha de Integração Downstream (`ClientApiException`) | Erro 4xx/5xx retornado por microsserviço externo | `@ExceptionHandler(ClientApiException.class)` | ESTRUTURADO (ERROR com status e body do client) | Retorna HTTP 502 Bad Gateway isolando o cliente mobile | [Q12-backend-downstream.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-backend-downstream.md) |
| `BACKEND-ERR-06` | Erro Inesperado / RuntimeException | Falha não prevista no processamento | `@ExceptionHandler(Exception.class)` | ESTRUTURADO (ERROR logado no servidor) | Retorna HTTP 500; em produção mascara `trace` e não vaza SQL/segredos | [Q12-backend-excecoes.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-backend-excecoes.md) |
| `BACKEND-ERR-07` | Feign Downstream (`AuthClient`, `MpVirtualClient`) | Timeout de conexão ou leitura na integração | Feign `RetryableException` / `SocketTimeoutException` | PARCIAL (Log SLF4J, defaults esperados OpenFeign 10s/60s) | Exceções de timeout materializadas são traduzidas para erro controlado; timeout HTTP real e encerramento físico de socket não foram aferidos | [Q12-backend-downstream.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-backend-downstream.md) |
| `BACKEND-ERR-08` | Recuperação Pós-Downstream | Microsserviço externo volta a responder | Chamada subsequente do Feign Client | PARCIAL (Log de sucesso subsequente) | Próxima requisição funciona logicamente sem reiniciar serviço; pool HTTP físico não instrumentado | [Q12-backend-downstream.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-backend-downstream.md) |
| `BACKEND-ERR-09` | Auditoria de Logs Seguros | Vazamento de credenciais ou dados sensíveis | Validação de mascaramento de senha/tokens | ESTRUTURADO (Sem credenciais em logs auditados) | Fluxos e padrões auditados livres de senhas e Bearer tokens | [Q12-observabilidade.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-observabilidade.md) |
| `BACKEND-ERR-10` | Correlação de Requisições (`X-Request-ID`, MDC) | Dificuldade em correlacionar chamadas entre serviços | Inexistente (Não há MDC ou CorrelationFilter) | AUSENTE | Requisições rastreadas apenas por timestamp local e thread | [Q12-observabilidade.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-observabilidade.md) |
| `BACKEND-ERR-11` | Health & Readiness Endpoints | Queda do processo ou indisponibilidade de DB | Não há Spring Boot Actuator configurado no POM | AUSENTE | Infraestrutura precisaria recorrer a probe TCP ou endpoint de negócio | [Q12-health-recovery.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-health-recovery.md) |
| `BACKEND-ERR-12` | Gestão de Threads e Recursos | Esgotamento de threads sob rajada de erros | JVM GC e encerramento de escopo | PARCIAL (Inspeção de encerramento no teste) | Processo JVM permaneceu responsivo após sequência de exceções; pool HTTP/servlet real não instrumentado | [Q12-health-recovery.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-health-recovery.md) |

---

## 4. Totais do Inventário Reconciliado (Q12-R02)

- **Total de Mecanismos / Componentes Auditados:** 29 (17 no Flutter, 12 no Backend).
- **Classificação Observabilidade:**
  - **ESTRUTURADO:** 8 (FLUTTER-ERR-13, BACKEND-ERR-01, 02, 03, 04, 05, 06, 09)
  - **PARCIAL:** 15 (FLUTTER-ERR-03..11 [9], FLUTTER-ERR-14..16 [3], BACKEND-ERR-07, 08, 12 [3])
  - **SOMENTE DESENVOLVIMENTO:** 3 (FLUTTER-ERR-01, 12, 17)
  - **AUSENTE:** 3 (FLUTTER-ERR-02, BACKEND-ERR-10, 11)
  - **N/A:** 0
  - **TOTAL:** **29** (8 + 15 + 3 + 3 + 0 = 29)
