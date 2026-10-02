# Q13 — Evidência de Property-Based Testing: Backend

**Data:** 02/10/2026  
**Arquivo de Teste:** `mobile-service/src/test/java/mppb/restapi/mobile/quality/Q13MutationPropertyFuzzTest.java`  
**Seed Canônica Global:** `130013`  

---

## 1. Visão Geral e Princípios Metodológicos

Os testes baseados em propriedades do backend Spring Boot validam as duas invariantes estruturais mais críticas de segurança e confiabilidade do serviço:
1. A integridade do mapeamento padronizado de exceções (`ProblemDetail` via RFC 7807) e a garantia de não vazamento de stacktrace sob profile de produção (`prod`).
2. A geração determinística e criptográfica do hash SHA-256 para tokens de notificação push FCM e a normalização formal dos identificadores e plataformas.

Cada propriedade foi executada com 500 iterações determinísticas a partir da seed `130013`.

---

## 2. Resumo de Execução das Propriedades (Backend)

| Property | Alvo | Seed | Iterações | Invariante Testada | Resultado |
|---|---|---:|---:|---|---|
| **P08** | `ApiExceptionHandler` | `130013` | 500 | Todas as exceções mapeiam para os códigos HTTP prescritos (422, 404, 503, 502, 403, 500); em profile `prod`, a propriedade `trace` é estritamente `null` e nenhuma mensagem de erro 500 expõe detalhes internos | **100% PASSOU** (500/500 conformes) |
| **P09** | `DispositivoFcmService` | `130013` | 500 | O hash passado ao repositório é rigorosamente idêntico ao digest SHA-256 canônico em minúsculas (`^[0-9a-f]{64}$`); plataformas ("AnDrOiD", "iOs") são normalizadas para maiúsculo | **100% PASSOU** (500/500 conformes, mata MUT-BACKEND-08) |

---

## 3. Detalhamento das Invariantes do Backend

### P08: Invariante de Mapeamento e Sanitização de ProblemDetail
- **Exceções Testadas em Rotação:**
  - `BusinessRuleException` $\implies$ `HttpStatus.UNPROCESSABLE_ENTITY` (422)
  - `NotFoundException` $\implies$ `HttpStatus.NOT_FOUND` (404)
  - `RetryableException` $\implies$ `HttpStatus.SERVICE_UNAVAILABLE` (503)
  - `ClientApiException` $\implies$ `HttpStatus.BAD_GATEWAY` (502)
  - `AccessDeniedException` $\implies$ `HttpStatus.FORBIDDEN` (403)
  - `RuntimeException` / `Exception` $\implies$ `HttpStatus.INTERNAL_SERVER_ERROR` (500)
- **Invariante de Segurança:**
  - Em ambiente produtivo (`setActiveProfiles("prod")`), o campo `trace` é sempre nulo.
  - Para falhas 500, a mensagem pública de detalhe é obrigatoriamente sanitizada para `"Ocorreu um erro inesperado no sistema. Por favor, tente novamente mais tarde."`, sem expor fragmentos de SQL, caminhos ou credenciais.

### P09: Invariante de Hash SHA-256 e Normalização FCM
- **Invariante Criptográfica:** O hash persistido deve corresponder bit a bit à saída de:
  $$\text{tokenHash} = \text{hex}(\text{SHA-256}(\text{tokenFcm.getBytes(UTF-8)}))$$
- **Eliminação de Gap:** Esta asserção mata diretamente qualquer mutação que tente enviar o token em texto claro ou aplicar truncamento indevido no hash.
