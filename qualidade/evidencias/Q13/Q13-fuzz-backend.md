# Q13 — Evidência de Fuzz Testing: Backend

**Data:** 02/10/2026  
**Arquivo de Teste:** `mobile-service/src/test/java/mppb/restapi/mobile/quality/Q13MutationPropertyFuzzTest.java`  
**Seed Canônica Global:** `130013`  

---

## 1. Visão Geral do Fuzzing no Backend

O Fuzz Testing no ecossistema Spring Boot teve como finalidade auditar as interfaces de borda e infraestrutura de rede externa (clientes Feign, deserialização Jackson e manipulador de exceções global) para comprovar:
1. Resiliência do deserializador JSON (`ObjectMapper`) sob payloads corrompidos, truncados ou contendo tipos divergentes;
2. Comportamento rigorosamente seguro do `ApiExceptionHandler` contra vazamento de strings maliciosas (SQL injection, paths de sistema operacional, tokens de autenticação) em respostas `ProblemDetail`;
3. Estabilidade do `FeignErrorDecoder` sob qualquer código de status HTTP sintético (inclusive fora do padrão) e payloads com corpos binários ou unicode corrompido.

---

## 2. Resumo de Execução do Fuzzing (Backend)

| Fuzz target | Seed | Casos | Crashes | Bugs |
|---|---:|---:|---:|---:|
| **F05**: Jackson DTO Deserialization (`RegistrarDispositivoRequest`, `PerfilUsuarioDto`, `AutenticaRequestDto`) | `130013` | 500 | 0 | 0 |
| **F06**: Sanitização de Resposta Pública em `ApiExceptionHandler` | `130013` | 500 | 0 | 0 |
| **F07**: HTTP Status e Body Fuzzing em `FeignErrorDecoder` | `130013` | 500 | 0 | 0 |

---

## 3. Detalhamento dos Vetores de Fuzzing Backend

### F05: Deserialização de DTOs Jackson
- **Mutações Injetadas:**
  - Payloads vazios `""` e apenas espaços `"    "`;
  - Payloads truncados na metade da estrutura JSON;
  - Injeção de dezenas de propriedades desconhecidas dinâmicas (`unknown_prop_i`);
  - Inversão de tipos (números substituindo strings, booleanos substituindo objetos);
  - Strings com repetições extremas e caracteres Unicode/emojis (`\uD83D\uDD25\u200B\uFEFF`).
- **Comportamento Observado:** O Jackson gerenciou todas as 500 iterações lançando `JsonProcessingException` ou `IllegalArgumentException` controladas quando o formato era inválido, sem nenhum crash da máquina virtual (`JVM`), vazamento de memória ou encerramento anômalo de threads.

### F06: Sanitização do ApiExceptionHandler
- **Vetores Maliciosos Fictícios Injetados:**
  - SQL-like: `'; DROP TABLE tb_usuario; --`
  - XSS-like: `<script>alert('XSS')</script>`
  - File paths: `C:\inetpub\wwwroot\web.config`, `/etc/passwd\0.png`
  - Segredos / Credenciais: `password=my_ultra_secret_pw`, `Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6...`
  - Sequências extremas de 500 caracteres repetidos.
- **Comportamento Observado:**
  - Sob profile de produção (`prod`), a propriedade `trace` permaneceu estritamente `null` em 100% dos 500 casos.
  - Para exceções não tratadas (HTTP 500), a mensagem retornada ao usuário final foi rigorosamente mascarada para `"Ocorreu um erro inesperado no sistema. Por favor, tente novamente mais tarde."`, sem vazar os vetores injetados.

### F07: Respostas Sintéticas e Fuzzing do FeignErrorDecoder
- **Status Codes Testados:**
  - 4xx: 400, 401, 403, 404, 409, 422, 429
  - 5xx: 500, 502, 503, 504, 599
  - Fora de [400, 600): 200, 204, 301, 302, 399, 600, 601
- **Corpos Testados:** `null`, `""`, strings normais, strings longas repetidas (> 500 chars), sequências complexas de emojis e quebras de linha (`\r\n\t`).
- **Comportamento Observado:**
  - Para todo status em $[400, 599]$, o decoder gerou `ClientApiException` preservando o status e o corpo sem falhas de NullPointer ou BufferOverflow.
  - Para status fora dessa faixa, o fallback padrão do Feign foi acionado com total previsibilidade.
