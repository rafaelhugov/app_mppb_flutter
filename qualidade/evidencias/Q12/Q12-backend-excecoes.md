# Evidência Q12 — Backend Exception Handling e Erro Inesperado

**Data de Execução:** 01/10/2026  
**Fase:** Q12 — Resiliência, Observabilidade e Recuperação  
**Ambiente:** Spring Boot (`mobile-service` & `restapi-common`)  
**Arquivo de Teste:** `mobile-service/src/test/java/mppb/restapi/mobile/quality/Q12ResilienciaObservabilidadeTest.java`

---

## 1. Auditoria dos Handlers em `ApiExceptionHandler`

O controlador central de exceções `@RestControllerAdvice` (`mppb.restapi.common.infrastructure.exception.handler.ApiExceptionHandler`) mapeia as seguintes exceções:

1. `@ExceptionHandler(BusinessRuleException.class)` → Retorna HTTP 422 *Unprocessable Entity* em ProblemDetail (RFC 7807).
2. `@ExceptionHandler(NotFoundException.class)` → Retorna HTTP 404 *Not Found*.
3. `@ExceptionHandler(RetryableException.class)` → Retorna HTTP 503 *Service Unavailable*.
4. `@ExceptionHandler(ClientApiException.class)` → Retorna HTTP 502 *Bad Gateway*.
5. `@ExceptionHandler(MethodArgumentNotValidException.class)` → Retorna HTTP 400 *Bad Request* com validação detalhada de campos.
6. `@ExceptionHandler(Exception.class)` → Handler genérico para exceções inesperadas (HTTP 500 *Internal Server Error*).

---

## 2. Testes de Falha Controlada (`Q12-T10` e `Q12-T11`)

Executados na suíte automatizada `Q12ResilienciaObservabilidadeTest`:

### 2.1 Q12-T10: Exceções de Domínio e Validação
- `testHandleBusinessRuleExceptionRetorna422`: Lançamento controlado de `BusinessRuleException` resultou em status HTTP 422 com corpo padronizado RFC 7807 contendo mensagem clara de negócio.
- `testHandleNotFoundExceptionRetorna404`: Lançamento de `NotFoundException` gerou HTTP 404 com indicação segura do recurso.
- `testHandleRetryableExceptionRetorna503`: Lançamento de `RetryableException` (timeout ou downstream fora) retornou HTTP 503 padronizado.
- `testHandleClientApiExceptionRetorna502`: Erro retornado por microsserviço Feign downstream mapeado para HTTP 502 isolando a causa.
- **Status:** **PASSOU**

### 2.2 Q12-T11: Erro Inesperado Backend e Mascaramento de Stacktrace
- `testHandleGenericExceptionSemVazamentoDeStacktrace`: Lançamento de `RuntimeException("Erro critico interno inesperado")` simulando falha imprevista.
- **Validações de Segurança:**
  - Status HTTP retornado: `500 Internal Server Error`.
  - Corpo da resposta: `ProblemDetail` com campos `status`, `title`, `detail`.
  - `RuntimeEnv.shouldIncludeTrace()`: Em perfil `prod`, retorna `false`.
  - O corpo da resposta **NÃO** inclui `trace`, **NÃO** expõe queries SQL, caminhos de diretório do servidor (`C:\Users\...` ou `/home/...`), credenciais ou variáveis de ambiente.
- **Status:** **PASSOU**

### 2.3 Tratamento de Exceção Durante Streaming de PDF
- `testHandleGenericExceptionComResponseCommitted`: Quando a resposta já possui streaming iniciado (e.g. download de contracheque ou certidão), o handler redefine o buffer ou grava ProblemDetail diretamente no servlet output stream evitando `HttpMessageNotWritableException`.
- **Status:** **PASSOU**
