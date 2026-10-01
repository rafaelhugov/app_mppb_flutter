# Evidência Q12 — Health, Readiness e Recuperação de Recursos

**Data de Execução:** 01/10/2026  
**Fase:** Q12 — Resiliência, Observabilidade e Recuperação  
**Reconciliação:** Q12-R02 — Correção Documental Residual e Consolidação Definitiva  
**Ambiente:** Spring Boot (`mobile-service` & `restapi-common`)  
**Arquivo de Teste:** `mobile-service/src/test/java/mppb/restapi/mobile/quality/Q12ResilienciaObservabilidadeTest.java`

---

## 1. Auditoria de Health / Readiness / Liveness (`Q12-T18`)

### 1.1 Auditoria do Código e Dependências
- O arquivo `pom.xml` não inclui o `spring-boot-starter-actuator`.
- Não existem endpoints `/actuator/health`, `/healthz` ou `/readyz`.
- **Calibração Metodológica (Q12-R01):**
  - Na ausência de health/readiness a nível de aplicação, a infraestrutura precisaria recorrer a probe de porta/TCP ou endpoint de negócio; a configuração efetiva de produção (balanceadores, Docker ou orquestração externa) não foi aferida nesta Q12.
- **Classificação:** **PARCIAL**
- **Risco Registrado:** **`RISCO-Q12-003`** (Severidade Média).

---

## 2. Recuperação de Memória e Threads Pós-Falhas (`Q12-T19`)

### 2.1 Análise de Execução e Escopo
- Os testes unitários e de integração exercitaram sequências consecutivas de chamadas com exceções de negócio, 404, 503 e runtime exceptions.
- O processo JVM completou as execuções sem estouro de memória (OutOfMemoryError) e permaneceu apto a responder requisições subsequentes válidas.
- **Calibração Metodológica (Q12-R01):**
  - Os testes foram executados dentro do processo de teste e harnesses locais;
  - Não houve injeção de carga HTTP concorrente sobre container servlet dedicado (Tomcat/Jetty) ou instrumentação de pool de conexões HTTP (Apache HttpClient/OkHttp) para essa métrica específica;
  - Portanto, não se sustenta que o pool HTTP real de conexões ou threads do servidor de produção foi instrumentado nesta bateria.
- **Classificação:** **PARCIAL**
- **Síntese:** Processo JVM permaneceu responsivo após sequência de exceções; pool HTTP real não foi instrumentado nesta bateria.
