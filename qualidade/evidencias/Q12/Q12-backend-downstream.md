# Evidência Q12 — Feign, Timeouts e Recuperação de Downstream

**Data de Execução:** 01/10/2026  
**Fase:** Q12 — Resiliência, Observabilidade e Recuperação  
**Reconciliação:** Q12-R02 — Correção Documental Residual e Consolidação Definitiva  
**Ambiente:** Spring Boot (`mobile-service` & `restapi-common`)  
**Arquivo de Teste:** `mobile-service/src/test/java/mppb/restapi/mobile/quality/Q12ResilienciaObservabilidadeTest.java`

---

## 1. Auditoria de Configuração Feign e Timeouts (`Q12-T12`)

### 1.1 Contexto e Reutilização de Achados Anteriores
Na fase Q7, foi identificado o risco `RISCO-Q7-001` apontando a ausência de governança explícita de timeout Feign via bean `Request.Options` ou propriedades customizadas por client.

### 1.2 Auditoria na Q12 e Calibração Q12-R02
- Os clients Feign (`AuthClient`, `MpVirtualClient`, `JcrClient`) herdam a configuração padrão do OpenFeign:
  - **Connect Timeout:** 10.000 ms (10s) — *default esperado do framework na ausência de override*.
  - **Read Timeout:** 60.000 ms (60s) — *default esperado do framework na ausência de override*.
- Estes valores representam as expectativas teóricas do OpenFeign e não um timeout medido fisicamente em runtime sob tráfego real.
- A ausência de parametrização explícita por endpoint/client permanece catalogada como **`RISCO-Q12-002`** (Severidade Média): na ausência de override, o framework possui defaults esperados de 10s connect / 60s read; se efetivos no runtime, operações interativas podem permanecer aguardando por período elevado.
- **Classificação:** **PARCIAL**

---

## 2. Testes com Dependências Downstream

### 2.1 Q12-T13: Downstream Indisponível
- **Cenário:** Simulação de recusa de conexão ou queda do serviço Auth/MPVirtual via mock de Feign client.
- **Comportamento Validado:**
  - A falha downstream foi isolada no fluxo testado e convertida em resposta HTTP 503/502 controlada, sem exceção não tratada propagada pelo serviço.
  - `mobile-service` capturou a falha via `RetryableException` / `ClientApiException`.
  - A causa foi registrada nos logs do servidor; sem afirmação de isolamento físico de threads.
- **Status:** **PASSOU**

### 2.2 Q12-T14: Timeout Downstream Simulado
- **Tipo de Teste:** **B) EXCEÇÃO DE TIMEOUT SIMULADA/MOCKADA**
- **Comportamento Validado:**
  - O teste exercitou o mapeamento de exceção de timeout (`RetryableException` com status 503 e `FeignErrorDecoder` recebendo HTTP 504 Gateway Timeout).
  - O controller/handler traduziu a falha para ProblemDetail padronizado (HTTP 503/502).
  - *Calibração Metodológica:* Não foi executado timeout HTTP real com servidor deliberadamente atrasado; portanto, não foi aferida a liberação física de socket ou encerramento de conexão na camada de transporte.
- **Status:** **PARCIAL**

### 2.3 Q12-T15: Recuperação Lógica Downstream
- **Cenário:**
  1. Chamada 1: Dependência externa indisponível via mock de client (retorna erro/timeout).
  2. Dependência externa reestabelecida no mock (`downstreamOnline.set(true)`).
  3. Chamada 2: Nova requisição disparada ao mesmo service.
- **Comportamento Validado:**
  - A segunda requisição obteve sucesso com retorno do DTO do usuário autenticado.
  - *Calibração Metodológica:* Trata-se de uma **recuperação lógica da camada de serviço**. Não houve tráfego HTTP real em rede física para comprovar reabertura de conexão Feign ou comportamento do pool de conexões do Apache/OkHttp.
- **Status:** **PASSOU**
