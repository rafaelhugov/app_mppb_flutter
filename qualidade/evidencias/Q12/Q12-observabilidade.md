# Evidência Q12 — Observabilidade, Logs e Rastreabilidade

**Data de Execução:** 01/10/2026  
**Fase:** Q12 — Resiliência, Observabilidade e Recuperação  
**Reconciliação:** Q12-R01 — Reconciliação Metodológica e Validação Definitiva  
**Ambiente:** Flutter (App Mobile) + Spring Boot (`restapi-common` e `mobile-service`)  

---

## 1. Auditoria e Taxonomia de Observabilidade Reconciliada

| Recurso / Ferramenta | Camada | Existe | Evidência | Limitação |
|---|---|---|---|---|
| **Tratamento e Logging de Exceções** | Backend | **ESTRUTURADO** | `@RestControllerAdvice` e SLF4J/Logback ativos em controllers/services | Formato de texto padrão (não JSON) |
| **Agregador Externo / APM de Erros** | Backend | **AUSENTE** | Não há Sentry, Elastic APM ou Datadog integrado | Falhas dependem de consulta a arquivos locais de log |
| **Crash Reporting em Produção** | Flutter | **AUSENTE** | Não consta Crashlytics ou Sentry no `pubspec.yaml` | Falhas não tratadas dependem de logcat local (`RISCO-Q12-004`) |
| **Logging Local na Aplicação** | Flutter | **PARCIAL** | Mapeamento no `state.errorMessage` dos Notifiers | Uso pontual de `print()` / stderr nativo |
| **Correlation / Trace ID Distribuído** | Backend | **AUSENTE** | Sem MDC ou cabeçalho `X-Request-ID` configurado | Rastreabilidade entre requisições concorrentes prejudicada (`RISCO-Q12-001`) |
| **Métricas (Prometheus / Micrometer)** | Backend | **AUSENTE** | Dependências não declaradas no `pom.xml` | Monitoramento restrito a métricas da JVM e SO |
| **Health / Liveness / Readiness** | Backend | **AUSENTE** | Spring Boot Actuator não incluído no build | Infraestrutura precisaria de probe TCP genérico (`RISCO-Q12-003`) |
| **Traces Distribuídos** | Ambas | **AUSENTE** | OpenTelemetry não integrado | Tracing distribuído não implementado |

> **Nota Metodológica sobre "Logs Estruturados" (Q12-R01):**  
> Na taxonomia interna da fase Q12, a classificação `ESTRUTURADO` indica a existência de um mecanismo central e padronizado na arquitetura (como o uso uniforme de SLF4J/Logback com nível, timestamp, thread e classe). Não significa que o Logback esteja gerando saída serializada em JSON ou pares chave-valor para ferramentas como Logstash/Loki.

---

## 2. Auditoria de Segurança dos Logs Backend (`Q12-T16`)

A inspeção dos fluxos de erro, autenticação e registro FCM (validada pelo teste automatizado `testRespostaErroNaoVazaTokenOuSenha` em `Q12ResilienciaObservabilidadeTest`):
- **Presença confirmada:**
  - Nível de log (`INFO`, `WARN`, `ERROR`);
  - Timestamp ISO/padrão;
  - Identificação de classe e thread;
  - Contexto da operação (e.g. `identificador=device-uuid-xxx`, `matricula=12345`).
- **Segurança nos cenários cobertos (Q12-R01):**
  - Os fluxos e padrões auditados não emitiram senha, Bearer token completo ou CPF completo nos cenários avaliados.
  - Para FCM, apenas o prefixo de hash do token é emitido para auditoria (`tokenHashPrefix=993db7544c2c`), sem expor o token FCM completo.
- **Status:** **PASSOU**

---

## 3. Análise de Correlação e Rastreabilidade (`Q12-T17`)

- A busca por termos `correlationId`, `traceId`, `requestId`, `X-Request-ID` e `MDC` no backend confirmou a inexistência de filtro servlet ou interceptor Feign responsável por injetar ou propagar identificadores únicos entre requisições.
- **Classificação:** **PARCIAL** (Identificado e auditado como lacuna arquitetural).
- **Risco Registrado:** **`RISCO-Q12-001`**.

---

## 4. Notificações FCM e Resiliência em Background (`Q12-T20`)

- O componente `DeviceRegistrationManager` implementa máquina de estados finita documentada em `DeviceRegistrationDiagnosticsState`:
  - `idle` → `requestingPermission` → `permissionResolved` → `requestingToken` → `registering` → `registered`.
  - Em caso de falha de permissão ou obtenção de token, transita para `failed` registrando o erro com segurança (`_safeError`), sem propagar exceção não tratada para a UI da aplicação.
- O teste automatizado no Flutter confirmou que diante de exceção simulada no provedor push, o app inicializa e segue utilizável.
- **Status:** **PASSOU**
