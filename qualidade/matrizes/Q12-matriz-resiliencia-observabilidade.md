# Matriz de Resiliência, Observabilidade e Recuperação — App MPPB (Q12)

**Data de Execução:** 01/10/2026  
**Fase:** Q12 — Resiliência, Observabilidade e Recuperação  
**Reconciliação:** Q12-R02 — Correção Documental Residual e Consolidação Definitiva  
**Ambiente:** Flutter (App Mobile) + Spring Boot (`restapi-common` e `mobile-service`)  
**Aparelho Físico:** Samsung Galaxy A52 (SM-A525M, Android 14 / One UI 6.1, API 34)

---

## 1. Legenda de Status

- **PASSOU:** Comportamento validado, controlado e com recuperação comprovada no escopo testado.
- **PARCIAL:** Comportamento controlado e recuperável, porém com observabilidade incompleta, ausência de interceptor global de produção, validação lógica via mock ou dependência de defaults sem aferição física de rede.
- **FALHOU:** Ocorrência de crash não tratado, estado quebrado persistente ou perda irrecuperável de dados.
- **BLOQUEADO:** Dependência externa ausente impediu execução técnica no ambiente.
- **N/A:** Não aplicável ao cenário/componente.

---

## 2. Matriz Consolidada de Execução

| ID | Cenário | Camada | Falha Injetada | Detecção | Recuperação | Status |
|---|---|---|---|---|---|---|
| `Q12-T01` | Fallback padrão de exceção de renderização Flutter | Flutter | Exceção síncrona na árvore de widgets | `FlutterError.onError` default do framework | `ErrorWidget` exibido na viewport; isolate e resto da UI não sofrem crash ou loop | **PASSOU** |
| `Q12-T02` | Erro assíncrono em zone de teste | Flutter | Exceção assíncrona não tratada em `Future` | `runZonedGuarded` em harness de teste | Falha isolada deterministicamente em Zone de teste, porém aplicação não possui interceptor global registrado em produção | **PARCIAL** |
| `Q12-T03A` | Recuperação de Notícias após falha | Flutter | HTTP 500 na busca de notícias | `try-catch` em `fetchNoticias()` | `isLoading = false`, mensagem amigável; retry subsequente restaura lista de notícias | **PASSOU** |
| `Q12-T03B` | Recuperação de Pagamentos após timeout | Flutter | `DioExceptionType.connectionTimeout` | `try-catch` em `fetchPagamentos()` | `isLoading = false`, `errorMessage` contextualizado; retry carrega demonstrativo | **PASSOU** |
| `Q12-T03C` | Recuperação de Contracheque após 503 | Flutter | HTTP 503 temporário no backend | `try-catch` em `carregarCompetencias()` | `isLoading = false`, retry manual carrega competências e contracheque do mês | **PASSOU** |
| `Q12-T04` | Retry manual de tela e limpeza de erro | Flutter | Falha na 1ª requisição e sucesso na 2ª | Captura da exceção no notifier | Notifier limpa `errorMessage`, entra em loading e recupera conteúdo na tela | **PASSOU** |
| `Q12-T05` | Sessão expirada (HTTP 401 vs 403) | Flutter | Resposta HTTP 401 em chamada autenticada | Interceptor Dio detecta 401 | Executa logout atômico, limpa credenciais e dispara `sessionResetProvider`; 403 mantém sessão | **PASSOU** |
| `Q12-T06A` | Storage corrompido (Perfil) | Flutter | JSON corrompido injetado no cache seguro | `FormatException` capturado em `jsonDecode()` | Descarta cache malformado, limpa loading e exibe erro amigável sem crash de isolate | **PASSOU** |
| `Q12-T06B` | Storage corrompido (Carteira) | Flutter | String corrompida no cache de carteira | `FormatException` no `jsonDecode()` | Despreza cache inválido, limpa loading e exibe mensagem amigável sem crash | **PASSOU** |
| `Q12-T07` | Ciclo de vida Android (Galaxy A52) | Runtime Android | Background (`KEYCODE_HOME`), foreground e alternância (`KEYCODE_APP_SWITCH`) | Notificações do ciclo de vida da engine | Foco retomado imediatamente, sem crashes, sem ANRs, sem recarregamento destrutivo | **PASSOU** |
| `Q12-T08` | Morte do processo (Galaxy A52) | Runtime Android | `am force-stop br.mp.mppbapp.app.homolog` | SO finaliza o processo | App relançado do zero via `main()`, sem necessidade de reinstall; KeyStore operacional (valores específicos não aferidos) | **PASSOU** |
| `Q12-T09` | Processo morto em background (Galaxy A52) | Runtime Android | App em background eliminado via `am kill` | SO encerra processo em segundo plano | Novo processo criado limpo ao reabrir, KeyStore operacional (valores específicos não aferidos) | **PASSOU** |
| `Q12-T10` | Backend Exception Handling | Backend | `BusinessRuleException`, `NotFoundException`, `RetryableException` | `@RestControllerAdvice` (`ApiExceptionHandler`) | Retorna ProblemDetail padronizado com HTTP 422, 404, 503 | **PASSOU** |
| `Q12-T11` | Erro inesperado backend | Backend | `RuntimeException` não prevista no controller | `@ExceptionHandler(Exception.class)` | Retorna HTTP 500 padronizado; mascaramento em produção previne vazamento de stacktrace e SQL | **PASSOU** |
| `Q12-T12` | Feign Downstream Timeouts | Backend | Auditoria de connect/read timeout nas integrações | Defaults esperados OpenFeign na ausência de override (10s connect, 60s read) | Requisição não trava indefinidamente; sem governança explícita por bean (`RISCO-Q12-002`) | **PARCIAL** |
| `Q12-T13` | Downstream indisponível | Backend | Falha de microsserviço downstream (Auth/MPVirtual) | Captura de `RetryableException` / `ClientApiException` | Falha downstream foi isolada no fluxo testado e convertida em resposta HTTP 503/502 controlada, sem exceção não tratada propagada pelo serviço | **PASSOU** |
| `Q12-T14` | Mapeamento de timeout downstream simulado | Backend | Exceção simulada de timeout em dependência (`RetryableException` / `FeignErrorDecoder`) | Mapeamento de timeout materializado via mock | Traduzido em resposta HTTP 503/502 padronizada; encerramento de conexão física não aferido no teste | **PARCIAL** |
| `Q12-T15` | Recuperação lógica downstream | Backend | Downstream falha e em seguida reestabelece via mock | Resposta de sucesso na requisição subsequente | Camada de serviço recupera atendimento sem reiniciar processo; pool HTTP físico não instrumentado | **PASSOU** |
| `Q12-T16` | Auditoria de logs seguros backend | Backend | Auditoria dos fluxos de erro e autenticação | Validação estática e dinâmica de logs SLF4J | Fluxos e padrões auditados livres de senhas, Bearer tokens completos e CPFs completos | **PASSOU** |
| `Q12-T17` | Correlação e Rastreabilidade | Backend | Pesquisa por `X-Request-ID`, `MDC`, `traceId` | Auditoria de código em `restapi-common` e `mobile-service` | Inexistência de tracing distribuído ou CorrelationFilter (`RISCO-Q12-001`) | **PARCIAL** |
| `Q12-T18` | Health & Readiness | Backend | Auditoria de endpoints de saúde e prontidão | Inexistência do módulo Spring Boot Actuator | Infraestrutura precisaria recorrer a probe TCP ou endpoint de negócio (`RISCO-Q12-003`) | **PARCIAL** |
| `Q12-T19` | Gestão de recursos e threads JVM | Backend | Sequência de chamadas com erro em harness de teste | Inspeção de encerramento de escopo na JVM | Processo JVM permaneceu responsivo após sequência de erros; pool HTTP real não instrumentado | **PARCIAL** |
| `Q12-T20` | FCM / Notificações em Background | Flutter | Provedor de push lança erro ou permissão negada | `try-catch` em `registrarSeAutenticado()` | Diagnóstico gravado em `DeviceRegistrationDiagnosticsState`; app inicializa normalmente | **PASSOU** |
| `Q12-T21` | Fallback de PDF e Imagem | Flutter | URL de imagem inexistente ou PDF inválido | `errorBuilder` / `onError` callbacks | Fallback visual amigável exibido sem quebrar a tela | **PASSOU** |
| `Q12-T22` | Recuperação pós-crash controlado | Flutter / Android | Término abrupto de processo (`force-stop` / `kill`) | Reinicialização completa a partir do `main()` | Recuperação após término abrupto validada; crash fatal real e integridade de valores lógicos não aferidas | **PARCIAL** |

---

## 3. Resumo Quantitativo da Matriz Reconciliada

- **PASSOU:** 18 cenários (72.0%)
- **PARCIAL:** 7 cenários (28.0% — `Q12-T02`, `Q12-T12`, `Q12-T14`, `Q12-T17`, `Q12-T18`, `Q12-T19`, `Q12-T22`)
- **FALHOU:** 0 cenários (0.0%)
- **BLOQUEADO:** 0 cenários (0.0%)
- **N/A:** 0 cenários (0.0%)
- **Total:** **25 cenários avaliados**.
