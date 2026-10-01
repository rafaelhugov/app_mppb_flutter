# Relatório Final — Fase Q12: Resiliência, Observabilidade e Recuperação

**Data de Conclusão:** 01/10/2026  
**Ciclo:** Qualidade, Confiabilidade e Prontidão do App MPPB  
**Fase:** Q12 — Resiliência, Observabilidade e Recuperação  
**Reconciliação:** Q12-R02 — Correção Documental Residual e Consolidação Definitiva  
**Próxima Fase:** Q13 (NÃO INICIADA)  

---

## 1. Baseline Canônica e Branches

### 1.1 Flutter
- **Diretório:** `C:\Users\rafae\projetosMPPB\app_mppb_flutter`
- **Branch:** `qualidade/q12-resiliencia-observabilidade-recuperacao` (criada a partir de `master` no commit `0052504`).
- **Modificações Preservadas:** `pubspec.yaml` (`version: 4.0.0+69 → 4.0.0+72`) mantida fora de qualquer commit da Q12.
- **Estado dos Gates:**
  - `flutter analyze`: **0 issues found**
  - `flutter test`: **231/231 testes aprovados** (incremento de 11 novos testes automatizados em `test/features/resiliencia/q12_resiliencia_test.dart`)
  - `secret_scan.sh` e `security_regression.sh`: **Verdes (Exit code 0)**
  - APK Homolog Debug: Compilado com sucesso (`build\app\outputs\flutter-apk\app-homolog-debug.apk`).

### 1.2 Backend
- **Diretório:** `C:\Users\rafae\projetosMPPB\spring-boot\restapi`
- **Branch:** `qualidade/q12-resiliencia-observabilidade-recuperacao` (criada a partir de `master` no commit `508a1fc`).
- **Módulos Relevantes:** `restapi-common` e `mobile-service`.
- **Integridade da Q6:** `Q6ConcorrenciaIntegridadeTest.java` foi restaurado integralmente para a `master` limpa; nenhum arquivo de fase anterior foi alterado.
- **Estado dos Gates:**
  - Maven tests: **164/164 testes aprovados** (11 em `restapi-common`, 153 em `mobile-service`, incremento de 11 testes em `Q12ResilienciaObservabilidadeTest.java`).
  - Maven package: `mvn -q -pl restapi-common,mobile-service -DskipTests package` concluído com sucesso.

### 1.3 Git Policy
- **Consolidação:** Consolidação final executada na branch `qualidade/q12-resiliencia-observabilidade-recuperacao` com merge fast-forward para `master` local e tentativa de publicação remota via branch feature (sem push em `master`).

---

## 2. Resposta Objetiva à Pergunta Canônica Reconciliada

```text
Quando uma dependência, processo, estado local ou operação falha, o sistema:

1. detecta a falha?
   SIM. No Flutter, os providers envelopam requisições em blocos try-catch e tratam DioException, FormatException e falhas de runtime; no backend, o @RestControllerAdvice (ApiExceptionHandler) intercepta exceções tipadas de negócio (BusinessRuleException), 404 (NotFoundException), timeouts downstream (RetryableException), falhas de microsserviços (ClientApiException) e exceções genéricas (Exception).

2. registra informação suficiente para diagnóstico?
   PARCIALMENTE. No backend, há logging padronizado via SLF4J/Logback com nível, timestamp, thread, componente e contexto (sem vazar senhas ou tokens nos fluxos auditados). No Flutter, o diagnóstico operacional é mantido nos estados de erro dos Notifiers e em DeviceRegistrationDiagnosticsState. Porém, há ausência de Crashlytics/Sentry e ausência de Correlation ID distribuído entre o app e os microsserviços.

3. evita corrupção/estado inconsistente?
   SIM. No Flutter, falhas em parsing de JSON no Secure Storage descartam o cache malformado sem derrubar o isolate; erros 401 realizam logout atômico via sessionResetProvider; chamadas concorrentes utilizam controle de loading; no backend, os cenários exercitados retornaram erros controlados e o processo JVM permaneceu responsivo após as exceções; pool HTTP real de threads/conexões não foi instrumentado nesta bateria.

4. apresenta comportamento controlado ao usuário?
   SIM. As telas exibem mensagens claras de erro amigável, ícones visuais de fallback para imagens e PDFs com falha, ErrorWidget nativo sem loop infinito e ações de retry manual para tentar recarregar a informação.

5. consegue recuperar-se sem reinstalação ou intervenção indevida?
   SIM. Após restabelecimento de conexão ou da dependência externa, uma nova requisição manual carrega os dados normalmente; interrupções de ciclo de vida (background, app switch), am kill e am force-stop no Galaxy A52 demonstraram inicialização limpa a partir do zero, mantendo o KeyStore seguro operacional sem necessidade de reinstalar o aplicativo (valores lógicos de sessão específicos não foram aferidos nesta bateria).
```

---

## 3. Inventário de Mecanismos e Componentes Auditados

- **Total de Mecanismos Auditados:** 29 (17 no Flutter, 12 no Backend).
- **Classificação de Observabilidade Reconciliada (Q12-R02):**
  - **ESTRUTURADO:** 8 mecanismos (FLUTTER-ERR-13, BACKEND-ERR-01..06, 09)
  - **PARCIAL:** 15 mecanismos (FLUTTER-ERR-03..11, 14..16, BACKEND-ERR-07, 08, 12)
  - **SOMENTE DESENVOLVIMENTO:** 3 mecanismos (FLUTTER-ERR-01, 12, 17)
  - **AUSENTE:** 3 mecanismos (FLUTTER-ERR-02, BACKEND-ERR-10, 11)
  - **N/A:** 0 mecanismos
  - **TOTAL:** **29** (8 + 15 + 3 + 3 + 0 = 29)

---

## 4. Tabela de Observabilidade Reconciliada

| Recurso | Camada | Existe | Evidência | Limitação |
|---|---|---|---|---|
| **Tratamento e Logging de Exceções** | Backend | **ESTRUTURADO** | `@RestControllerAdvice` e SLF4J/Logback ativos em controllers/services | Formato de texto padrão (não JSON) |
| **Agregador Externo / APM de Erros** | Backend | **AUSENTE** | Não há Sentry, Elastic APM ou Datadog integrado | Falhas dependem de consulta a arquivos locais de log |
| **Crash Reporting em Produção** | Flutter | **AUSENTE** | Não consta Crashlytics ou Sentry no `pubspec.yaml` | Falhas não tratadas dependem de logcat local (`RISCO-Q12-004`) |
| **Logging Local na Aplicação** | Flutter | **PARCIAL** | Mapeamento no `state.errorMessage` dos Notifiers | Uso pontual de `print()` / stderr nativo |
| **Correlation / Trace ID Distribuído** | Backend | **AUSENTE** | Sem MDC ou cabeçalho `X-Request-ID` configurado | Rastreabilidade entre requisições concorrentes prejudicada (`RISCO-Q12-001`) |
| **Métricas (Prometheus / Micrometer)** | Backend | **AUSENTE** | Dependências não declaradas no `pom.xml` | Monitoramento restrito a métricas da JVM e SO |
| **Health / Liveness / Readiness** | Backend | **AUSENTE** | Spring Boot Actuator não incluído no build | Infraestrutura precisaria de probe TCP genérico (`RISCO-Q12-003`) |
| **Traces Distribuídos** | Ambas | **AUSENTE** | OpenTelemetry não integrado | Tracing distribuído não implementado |

---

## 5. Auditoria de Runtime Android no Samsung Galaxy A52

- **Aparelho:** Samsung Galaxy A52 (`SM-A525M`, Android 14 / One UI 6.1, API 34).
- **Serial ADB:** `RX8RC09H70X`.
- **Package Homolog:** `br.mp.mppbapp.app.homolog`.
- **Cenários Testados e Calibrados (Q12-R01):**
  - `Q12-T07` (Ciclo de Vida): Background (`KEYCODE_HOME`), foreground e alternância de apps (`KEYCODE_APP_SWITCH`). Foco retomado instantaneamente sem ANR ou crash. Bloqueio/desbloqueio de tela (screen lock) não exercitado fisicamente e retirado das afirmações.
  - `Q12-T08` (Morte do Processo): `am force-stop` eliminou processo (`PID ''`). Relançamento via launcher gerou novo processo limpo (`PID 2036`). KeyStore operacional (valores específicos não aferidos).
  - `Q12-T09` (Morte em Background): `am kill` em segundo plano removeu o processo. Reabertura gerou novo PID (`3739`). KeyStore operacional (valores específicos não aferidos).
- **Logcat Audit:** `0` FATAL exceptions, `0` SIGSEGV, `0` ANRs observados durante todas as transições.

---

## 6. Bugs e Riscos

### 6.1 Bugs
- Nenhum bug funcional impeditivo ou crash reproduzível detectado.
- *Nota sobre o Harness:* A reversão de `Q6ConcorrenciaIntegridadeTest.java` para a versão limpa da `master` executou com sucesso (6/6), confirmando que a suíte `Q12ResilienciaObservabilidadeTest` não contamina testes anteriores nem necessita de `BUG-Q12-HARNESS-001`.

### 6.2 Riscos Registrados

| ID | Camada | Risco | Impacto | Evidência |
|---|---|---|---|---|
| **RISCO-Q12-001** | Backend | Ausência de Correlation ID (`X-Request-ID` / MDC) | Alta concorrência de erros em produção dificulta correlação de logs entre chamadas distribuídas. | [Q12-observabilidade.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-observabilidade.md) |
| **RISCO-Q12-002** | Backend | Timeouts Feign dependentes de defaults OpenFeign (10s connect, 60s read) | Na ausência de override, o framework possui defaults esperados de 10s connect / 60s read; se efetivos no runtime, operações interativas podem permanecer aguardando por período elevado. | [Q12-backend-downstream.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-backend-downstream.md) |
| **RISCO-Q12-003** | Backend | Ausência de endpoints padronizados de Health/Readiness (Actuator) | Orquestradores (Kubernetes/Docker) dependem de probes TCP genéricos em vez de checagem real de dependências. | [Q12-health-recovery.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-health-recovery.md) |
| **RISCO-Q12-004** | Flutter | Ausência de Crash Reporting em Produção (Sentry/Crashlytics) | Erros assíncronos não capturados fora de zonas de teste dependem de inspeção manual de `logcat`. | [Q12-flutter-erros-globais.md](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q12/Q12-flutter-erros-globais.md) |

---

## 7. Matriz Consolidada Reconciliada (Q12-R02)

- **PASSOU:** 18 cenários (72.0%)
- **PARCIAL:** 7 cenários (28.0% — `Q12-T02`, `Q12-T12`, `Q12-T14`, `Q12-T17`, `Q12-T18`, `Q12-T19`, `Q12-T22`)
- **FALHOU:** 0 cenários (0.0%)
- **BLOQUEADO:** 0 cenários (0.0%)
- **N/A:** 0 cenários (0.0%)
- **Total:** **25 cenários avaliados**.

---

## 8. Conclusão Canônica

**Q12 CONCLUÍDA — RESILIÊNCIA, OBSERVABILIDADE E RECUPERAÇÃO VALIDADAS NO ESCOPO TESTADO**

---

## 9. Status da Fase Q13

**Q13 NÃO INICIADA**
