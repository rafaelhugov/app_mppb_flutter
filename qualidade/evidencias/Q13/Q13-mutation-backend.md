# Q13 — Evidência de Mutation Testing: Backend

**Data:** 02/10/2026  
**Repositório:** `spring-boot/restapi` (`restapi-common` e `mobile-service`)  
**Ambiente de Execução:** Worktree temporário isolado `..\restapi_q13_mut`  
**Baseline Testes:** 164 testes unitários e de integração  
**Log de Execução Reproduzível Completo:** [`qualidade/evidencias/Q13/Q13-mutation-execution-log.md`](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q13/Q13-mutation-execution-log.md)

---

## 1. Metodologia de Mutation Sampling Controlado

Conforme preconizado nas diretrizes da fase Q13, nenhuma dependência permanente pesada (como PITest) foi injetada no POM canônico. Em vez disso, foi criado um **worktree temporário** (`git worktree add ..\restapi_q13_mut master`), onde 12 mutações semânticas críticas de domínio foram aplicadas uma a uma e validadas contra a suíte de testes Maven (`mvn -pl restapi-common,mobile-service test`).

Para mutações situadas no módulo `restapi-common`, os testes foram executados com reabertura de dependência no mesmo reactor (`-pl restapi-common,mobile-service`), garantindo que o módulo `mobile-service` foi recompilado e testado diretamente contra a versão mutada em memória/target, e não contra artefatos desatualizados do cache local.

Para cada mutação foi rigorosamente registrado:
1. Código original
2. Aplicação da mutação
3. `git diff` exibindo exclusivamente a mutação
4. Teste específico executado
5. Falha de asserção comportamental
6. `git restore` e conferência de `git diff` vazio

Ao término da amostragem, o worktree temporário foi completamente desmontado e removido (`git worktree remove --force`), e a integridade de `Q6ConcorrenciaIntegridadeTest.java` e demais classes foi rigorosamente confirmada com `git diff` limpo.

---

## 2. Tabela de Mutações Amostrais — Backend

| ID | Arquivo | Mutação | Teste executado | Resultado Baseline | Resultado Pós-Gap (Q13) |
|---|---|---|---|---|---|
| MUT-BACKEND-01 | `ApiExceptionHandler.java` | Trocar `HttpStatus.UNPROCESSABLE_ENTITY` (422) por `HttpStatus.OK` (200) | `Q12ResilienciaObservabilidadeTest#testBusinessRuleExceptionGera422` | **KILLED** (`expected: 422 but was: 200`) | **KILLED** |
| MUT-BACKEND-02 | `ApiExceptionHandler.java` | Trocar `HttpStatus.NOT_FOUND` (404) por `HttpStatus.INTERNAL_SERVER_ERROR` (500) | `Q12ResilienciaObservabilidadeTest#testNotFoundExceptionGera404` | **KILLED** (`expected: 404 but was: 500`) | **KILLED** |
| MUT-BACKEND-03 | `ApiExceptionHandler.java` | Trocar `HttpStatus.SERVICE_UNAVAILABLE` (503) por `HttpStatus.OK` (200) | `Q12ResilienciaObservabilidadeTest#testRetryableExceptionGera503` | **KILLED** (`expected: 503 but was: 200`) | **KILLED** |
| MUT-BACKEND-04 | `ApiExceptionHandler.java` | Trocar `HttpStatus.BAD_GATEWAY` (502) por `HttpStatus.INTERNAL_SERVER_ERROR` (500) | `Q12ResilienciaObservabilidadeTest#testClientApiExceptionGera502` | **KILLED** (`expected: 502 but was: 500`) | **KILLED** |
| MUT-BACKEND-05 | `ApiExceptionHandler.java` | Forçar inclusão de `trace` mesmo com profile `prod` ativo | `Q12ResilienciaObservabilidadeTest#testErroInesperadoEmProdOmitiStackTrace` | **KILLED** (`not to contain key: "trace"`) | **KILLED** |
| MUT-BACKEND-06 | `FeignErrorDecoder.java` | Alterar `status >= 400` para `status >= 500` (ignora 4xx) | `Q12ResilienciaObservabilidadeTest#testFeignErrorDecoderTraduzDownstream` | **SURVIVED (TEST GAP)** | **KILLED** (`Q13MutationPropertyFuzzTest` F07: `Expecting actual throwable to be ClientApiException but was FeignException$Conflict`) |
| MUT-BACKEND-07 | `FeignErrorDecoder.java` | Em `readBody`, retornar `""` direto sem ler o corpo da resposta | `Q13MutationPropertyFuzzTest` F07 | **SURVIVED (TEST GAP)** | **KILLED** (`Q13MutationPropertyFuzzTest` F07: asserção esperava corpo incorporado na mensagem de exceção) |
| MUT-BACKEND-08 | `DispositivoFcmService.java` | Omitir hash SHA-256 e passar token bruto como `tokenHash` | `DispositivoFcmServiceTest#registraPrimeiroDispositivoSemRetornarToken` | **SURVIVED (TEST GAP)** | **KILLED** (`Q13MutationPropertyFuzzTest` P09: hash diferente de SHA-256 de 64 chars) |
| MUT-BACKEND-09 | `DispositivoFcmService.java` | Inverter condição: `if (!existentePorToken.isPresent())` no update | `DispositivoFcmServiceTest#registroDoMesmoTokenEIdempotente` | **KILLED** (`NoSuchElementException: No value present at Optional.get()`) | **KILLED** |
| MUT-BACKEND-10 | `DispositivoFcmService.java` | Rejeitar plataforma `ANDROID` em `plataformaValida` | `DispositivoFcmServiceTest#registraPrimeiroDispositivoSemRetornarToken` | **KILLED** (`IllegalArgumentException: plataforma invalida`) | **KILLED** |
| MUT-BACKEND-11 | `DispositivoFcmService.java` | Inverter retorno de `desativar`: `return !desativou` | `DispositivoFcmServiceTest#desativaDispositivoDoProprioUsuario` | **KILLED** (`expected: <true> but was: <false>`) | **KILLED** |
| MUT-BACKEND-12 | `ApiExceptionHandler.java` | Em `handleAccessDeniedException`, trocar 403 por 401 | `Q13MutationPropertyFuzzTest#testPropertyP08ExceptionMappingAndSanitization` | **KILLED** (`expected: 403 but was: 401`) | **KILLED** |

---

## 3. Classificação e Reexecução Concreta dos Sobreviventes

Os 3 mutantes sobreviventes na rodada inicial foram reexecutados contra as novas suítes e tiveram suas falhas de asserção confirmadas:
- **`MUT-BACKEND-06`:** Reexecutado contra `testFuzzF07FeignErrorDecoder()` (`F07`). Falhou na iteração 4 (status 409 Conflict) com `Expecting actual throwable to be an instance of: ClientApiException but was: feign.FeignException$Conflict`. Mutação morta.
- **`MUT-BACKEND-07`:** Reexecutado contra `testFuzzF07FeignErrorDecoder()` (`F07`). Falhou na iteração 4 com asserção de que o corpo não foi lido nem incorporado ao `ClientApiException`. Mutação morta.
- **`MUT-BACKEND-08`:** Reexecutado contra `testPropertyP09FcmTokenHashingAndNormalization()` (`P09`). Falhou na iteração 0 com `expected: "ba800231..." but was: "hdsmxle..."` (token bruto passado sem SHA-256). Mutação morta.

---

## 4. Métricas de Mutation Score — Backend

$$\text{Sampled Mutation Score} = \frac{\text{KILLED}}{\text{KILLED} + \text{SURVIVED}} \times 100$$

- **Total de Mutações Válidas:** 12
- **Mutações Executadas:** 12
- **KILLED (Baseline):** 9
- **SURVIVED (Baseline):** 3 (`MUT-BACKEND-06`, `MUT-BACKEND-07`, `MUT-BACKEND-08`)
- **EQUIVALENT:** 0
- **INVALID:** 0
- **INITIAL SAMPLED MUTATION SCORE:** **75,0%** (9/12)
- **POST-GAP SAMPLED MUTATION SCORE:** **100,0%** (12/12 mortas na rodada pós-gap com suíte Q13)
