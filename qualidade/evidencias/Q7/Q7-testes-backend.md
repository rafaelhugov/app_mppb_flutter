# Evidência Q7 — Testes Determinísticos Backend

Data: 2026-09-30  
Branch: `qualidade/q7-rede-offline-interrupcoes`  
Arquivo de Testes: `mobile-service/src/test/java/mppb/restapi/mobile/quality/Q7RedeInterrupcoesTest.java`  
Total de Testes na Suíte Q7: 6  
Resultado: 6 PASS / 0 FAIL  
Total Geral Backend (`restapi-common` + `mobile-service`): 148/148 testes PASS

---

## 1. Cobertura dos Cenários de Teste

| Teste | Cenário | Falha Simulada | Comportamento Validado | Status |
| :--- | :--- | :--- | :--- | :---: |
| **Q7-T19** | Dependência Indisponível | `feign.RetryableException` (Connection refused) | `ApiExceptionHandler` gera HTTP 503 com ProblemDetail padronizado ("Serviço externo indisponível") | PASSOU |
| **Q7-T20** | Tratamento de Timeout Feign | `feign.RetryableException` (Read timed out) | Handler responde HTTP 503 imediato sem reter thread no pool e sem expor stack trace (comprovado no handler; retenção de socket congelado coberta por `RISCO-Q7-001`) | PASSOU |
| **Q7-T19** | Erro 5xx Upstream | Resposta 500 do sistema externo | `FeignErrorDecoder` decodifica para `ClientApiException`; handler traduz para HTTP 502 Bad Gateway | PASSOU |
| **Q7-T19** | Falha de Consulta Externa (Fallback Null) | Host externo inacessível em `consultaAutorizacao` | `PerfilUsuarioService` captura falha com log e retorna `null` seguro sem propagar exceção descontrolada | PASSOU |
| **Q7-T15** | Token Inválido / Expirado | Token nulo ou rejeitado pelo upstream | `PerfilUsuarioController` retorna HTTP 401 Unauthorized de forma consistente | PASSOU |
| **Q7-T16** | Autorização Negada (403) | `AccessDeniedException` | `ApiExceptionHandler` gera HTTP 403 Forbidden com título "Acesso negado", preservando a integridade | PASSOU |

---

## 2. Risco Arquitetural Identificado no Backend

- **`RISCO-Q7-001` (Governança de Timeout em Clientes Feign)**: Os clientes Feign (`AuthServiceClient`, `MPVirtualClient`) não possuem timeout explicitamente governado na configuração da aplicação; portanto, o comportamento de retenção de socket depende da configuração/default efetivamente aplicada pela stack utilizada. A camada de tratamento de exceções converte com segurança `RetryableException` em HTTP 503, mas a parametrização explícita de socket permanece pendente de governança.
