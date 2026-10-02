# Q13 — Log de Execução Reproduzível de Mutation Testing (24 Mutações)

**Data de Execução:** 02/10/2026  
**Ambiente de Execução:** Worktrees temporários `..\app_mppb_flutter_q13_mut` e `..\restapi_q13_mut`  
**Metodologia:** Amostragem semântica unitária, 1 mutação por vez, verificação de `git diff`, execução de teste-alvo com captura de asserção comportamental, `git restore` e conferência de working tree limpo.

---

## 1. Mutações Flutter (12 Mutações)

### MUT-FLUTTER-01
- **ID:** MUT-FLUTTER-01
- **Arquivo:** `lib/features/auth/providers/auth_provider.dart`
- **Linha/condição:** Linha 133, omitir `await _storage.write(key: 'token', value: token);`
- **Diff aplicado:**
```diff
- await _storage.write(key: 'token', value: token);
+ // MUT-FLUTTER-01: omitir persistencia segura do token
+ // await _storage.write(key: 'token', value: token);
```
- **Comando:** `flutter test test/features/auth/auth_provider_test.dart --no-pub`
- **Teste realmente executado:** `auth provider login sets token and authenticates`
- **Resultado do processo:** Exit code 1
- **Assertion que falhou:** `Expected: 'token-api', Actual: <null>` em `test/features/auth/auth_provider_test.dart:56:7`
- **Classificação:** **KILLED**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-FLUTTER-02
- **ID:** MUT-FLUTTER-02
- **Arquivo:** `lib/core/session/session_reset_provider.dart`
- **Linha/condição:** Linha 19, omitir `ref.invalidate(carteiraProvider);`
- **Diff aplicado:**
```diff
- ref.invalidate(carteiraProvider);
+ // MUT-FLUTTER-02: omitir invalidacao da carteira no reset de sessao
+ // ref.invalidate(carteiraProvider);
```
- **Comando (Baseline):** `flutter test --no-pub` (com `test/features/qualidade/q13_fuzz_property_test.dart` excluído temporariamente)
- **Teste realmente executado (Baseline):** Bateria histórica completa pré-Q13 (231 testes)
- **Resultado Baseline:** Exit code 0 (231/231 testes aprovados) -> **SURVIVED BASELINE** (nenhum teste da baseline histórica cobria o `sessionResetProvider`).
- **Comando (Pós-Gap Q13 P07):** `flutter test --no-pub test/features/qualidade/q13_fuzz_property_test.dart --name "P07"`
- **Teste realmente executado (Pós-Gap):** `P07: Invariantes de Sessão Atômica (sessionResetProvider invalida providers no logout)`
- **Resultado Pós-Gap:** Exit code 1
- **Assertion que falhou:** `Expected: null, Actual: <Instance of 'UsuarioCarteira'> (Dados da carteira devem ser resetados para null apos logout)` em `test/features/qualidade/q13_fuzz_property_test.dart:334:7`
- **Classificação:** **KILLED (Post-Gap)**
- **Restore confirmado:** `git restore lib/core/session/session_reset_provider.dart` executado, `git diff` vazio.

---

### MUT-FLUTTER-03
- **ID:** MUT-FLUTTER-03
- **Arquivo:** `lib/features/auth/providers/auth_provider.dart`
- **Linha/condição:** Linha 138, manter `isAuthenticated: false` após login
- **Diff aplicado:**
```diff
- isAuthenticated: true,
+ // MUT-FLUTTER-03: manter isAuthenticated false apos login bem-sucedido
+ isAuthenticated: false,
```
- **Comando:** `flutter test test/features/auth/auth_provider_test.dart --no-pub`
- **Teste realmente executado:** `auth provider login sets token and authenticates`
- **Resultado do processo:** Exit code 1
- **Assertion que falhou:** `Expected: true, Actual: <false>` em `test/features/auth/auth_provider_test.dart:54:7`
- **Classificação:** **KILLED**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-FLUTTER-04
- **ID:** MUT-FLUTTER-04
- **Arquivo:** `lib/features/noticias/providers/noticia_provider.dart`
- **Linha/condição:** Linha 101, catch de erro mantém `isLoading: true`
- **Diff aplicado:**
```diff
- isLoading: false,
+ // MUT-FLUTTER-04: manter isLoading true em caso de erro
+ isLoading: true,
```
- **Comando:** `flutter test test/features/resiliencia/q12_resiliencia_test.dart --plain-name "Q12-T04" --no-pub`
- **Teste realmente executado:** `Q12-T04: Falha transitória 503 com retry manual recupera estado operacional`
- **Resultado do processo:** Exit code 1
- **Assertion que falhou:** `Expected: false, Actual: <true>` em `test/features/resiliencia/q12_resiliencia_test.dart:117:7`
- **Classificação:** **KILLED**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-FLUTTER-05
- **ID:** MUT-FLUTTER-05
- **Arquivo:** `lib/features/noticias/providers/noticia_provider.dart`
- **Linha/condição:** Linha 95, recarga com sucesso mantém `errorMessage: state.errorMessage` em vez de limpar
- **Diff aplicado:**
```diff
- errorMessage: null,
+ // MUT-FLUTTER-05: nao limpar mensagem de erro residual no sucesso
+ errorMessage: state.errorMessage,
```
- **Comando:** `flutter test test/features/resiliencia/q12_resiliencia_test.dart --plain-name "Q12-T04" --no-pub`
- **Teste realmente executado:** `Q12-T04: Falha transitória 503 com retry manual recupera estado operacional`
- **Resultado do processo:** Exit code 1
- **Assertion que falhou:** `Expected: null, Actual: 'Erro ao carregar notícias: DioException [bad response]: Servico em manutencao'` em `test/features/resiliencia/q12_resiliencia_test.dart:126:7`
- **Classificação:** **KILLED**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-FLUTTER-06
- **ID:** MUT-FLUTTER-06
- **Arquivo:** `lib/features/perfil/providers/perfil_provider.dart`
- **Linha/condição:** Linha 181, no catch de `_loadFromCache()`, adicionar `rethrow;`
- **Diff aplicado:**
```diff
+ // MUT-FLUTTER-06: propagar excecao no cache corrompido em vez de degradar suavemente
+ rethrow;
```
- **Comando:** `flutter test test/features/resiliencia/q12_resiliencia_test.dart --plain-name "Q12-T06" --no-pub`
- **Teste realmente executado:** `Q12-T06: Payload corrompido em cache local dispara fallback limpo sem crash de widget`
- **Resultado do processo:** Exit code 1
- **Assertion que falhou:** `FormatException: Unexpected character (at character 1)` não tratada, abortando fluxo sem fallback gracioso.
- **Classificação:** **KILLED**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-FLUTTER-07
- **ID:** MUT-FLUTTER-07
- **Arquivo:** `lib/features/carteira/providers/carteira_provider.dart`
- **Linha/condição:** Linha 156, no fallback de cache offline, setar `isOffline: false`
- **Diff aplicado:**
```diff
- isOffline: true,
+ // MUT-FLUTTER-07: setar isOffline false no fallback offline
+ isOffline: false,
```
- **Comando:** `flutter test test/features/carteira/carteira_provider_test.dart --no-pub`
- **Teste realmente executado:** `carteira provider carrega do cache quando offline`
- **Resultado do processo:** Exit code 1
- **Assertion que falhou:** `Expected: true, Actual: <false>` em `test/features/carteira/carteira_provider_test.dart:79:7`
- **Classificação:** **KILLED**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-FLUTTER-08
- **ID:** MUT-FLUTTER-08
- **Arquivo:** `lib/features/ouvidoria/providers/ouvidoria_provider.dart`
- **Linha/condição:** Linha 235, alterar `d1 = 11 - (sum1 % 11)` para `d1 = 10 - (sum1 % 11)`
- **Diff aplicado:**
```diff
- int d1 = 11 - (sum1 % 11);
+ // MUT-FLUTTER-08: mutar algoritmo modulo 11 do primeiro digito
+ int d1 = 10 - (sum1 % 11);
```
- **Comando (Baseline):** `flutter test test/features/ouvidoria/ouvidoria_formatters_test.dart --no-pub`
- **Resultado Baseline:** Exit code 0 (Passou) -> **SURVIVED (TEST GAP)** (formatters testavam apenas máscara visual).
- **Comando (Pós-Gap Q13 P03):** `flutter test test/features/qualidade/q13_fuzz_property_test.dart --plain-name "P03" --no-pub`
- **Teste realmente executado:** `P03: Invariantes do Validador de CPF da Ouvidoria (500 iterações / 1000 casos)`
- **Resultado Pós-Gap:** Exit code 1
- **Assertion que falhou:** `Expected: null, Actual: 'O CPF informado é inválido.'` em `test/features/qualidade/q13_fuzz_property_test.dart:174:9`
- **Classificação:** **KILLED (Post-Gap)**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-FLUTTER-09
- **ID:** MUT-FLUTTER-09
- **Arquivo:** `lib/features/ouvidoria/providers/ouvidoria_provider.dart`
- **Linha/condição:** Linha 226, alterar `cpf.length != 11` para `cpf.length != 10`
- **Diff aplicado:**
```diff
- if (cpf.length != 11) return false;
+ // MUT-FLUTTER-09: aceitar CPF de 10 digitos em vez de 11
+ if (cpf.length != 10) return false;
```
- **Comando (Baseline):** `flutter test test/features/ouvidoria/ouvidoria_formatters_test.dart --no-pub`
- **Resultado Baseline:** Exit code 0 (Passou) -> **SURVIVED (TEST GAP)**
- **Comando (Pós-Gap Q13 P03):** `flutter test test/features/qualidade/q13_fuzz_property_test.dart --plain-name "P03" --no-pub`
- **Teste realmente executado:** `P03: Invariantes do Validador de CPF da Ouvidoria (500 iterações / 1000 casos)`
- **Resultado Pós-Gap:** Exit code 1
- **Assertion que falhou:** `Expected: null, Actual: 'O CPF informado é inválido.'` em `test/features/qualidade/q13_fuzz_property_test.dart:174:9`
- **Classificação:** **KILLED (Post-Gap)**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-FLUTTER-10
- **ID:** MUT-FLUTTER-10
- **Arquivo:** `lib/core/notifications/device_registration_provider.dart`
- **Linha/condição:** Linha 208, omitir `await _registrarComToken(token, 'ANDROID');`
- **Diff aplicado:**
```diff
- await _registrarComToken(token, 'ANDROID');
+ // MUT-FLUTTER-10: omitir registro do token no backend
+ // await _registrarComToken(token, 'ANDROID');
```
- **Comando:** `flutter test test/core/notifications/device_registration_provider_test.dart --no-pub`
- **Teste realmente executado:** `inicializacao registra token automaticamente`
- **Resultado do processo:** Exit code 1
- **Assertion que falhou:** `Expected: an object with length of <1>, Actual: []` em `test/core/notifications/device_registration_provider_test.dart:49:7`
- **Classificação:** **KILLED**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-FLUTTER-11
- **ID:** MUT-FLUTTER-11
- **Arquivo:** `lib/features/ouvidoria/utils/input_formatters.dart`
- **Linha/condição:** Linha 44, alterar `text.length <= 10` para `text.length <= 9`
- **Diff aplicado:**
```diff
- if (text.length <= 10) {
+ // MUT-FLUTTER-11: alterar limite de celular
+ if (text.length <= 9) {
```
- **Comando:** `flutter test test/features/ouvidoria/ouvidoria_formatters_test.dart --no-pub`
- **Teste realmente executado:** `TelefoneInputFormatter formata celular 11 digitos progressivamente`
- **Resultado do processo:** Exit code 1
- **Assertion que falhou:** `Expected: '(83) 99999-8888', Actual: '(83) 9999-98888'` em `test/features/ouvidoria/ouvidoria_formatters_test.dart:37:7`
- **Classificação:** **KILLED**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-FLUTTER-12
- **ID:** MUT-FLUTTER-12
- **Arquivo:** `lib/features/ouvidoria/utils/input_formatters.dart`
- **Linha/condição:** Linha 11, substituir pontos por hífens no formatador de CPF
- **Diff aplicado:**
```diff
- buffer.write('.');
+ // MUT-FLUTTER-12: usar hifen em vez de ponto
+ buffer.write('-');
```
- **Comando:** `flutter test test/features/ouvidoria/ouvidoria_formatters_test.dart --no-pub`
- **Teste realmente executado:** `CPFInputFormatter formata CPF progressivamente`
- **Resultado do processo:** Exit code 1
- **Assertion que falhou:** `Expected: '123.456.789-00', Actual: '123-456-789-00'` em `test/features/ouvidoria/ouvidoria_formatters_test.dart:14:7`
- **Classificação:** **KILLED**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

## 2. Mutações Backend (12 Mutações)

### MUT-BACKEND-01
- **ID:** MUT-BACKEND-01
- **Arquivo:** `mppb.restapi.common.core.handler.ApiExceptionHandler`
- **Linha/condição:** Linha 55, trocar `HttpStatus.UNPROCESSABLE_ENTITY` (422) por `HttpStatus.OK` (200)
- **Diff aplicado:**
```diff
- return createProblemDetail(HttpStatus.UNPROCESSABLE_ENTITY, "Regra de negócio violada", exception, null);
+ // MUT-BACKEND-01: retornar 200 em vez de 422
+ return createProblemDetail(HttpStatus.OK, "Regra de negócio violada", exception, null);
```
- **Comando:** `mvn -pl restapi-common,mobile-service test -Dtest=Q12ResilienciaObservabilidadeTest#testBusinessRuleExceptionGera422 "-Dsurefire.failIfNoSpecifiedTests=false"`
- **Teste realmente executado:** `Q12ResilienciaObservabilidadeTest#testBusinessRuleExceptionGera422`
- **Resultado do processo:** Exit code 1
- **Assertion que falhou:** `expected: 422 UNPROCESSABLE_ENTITY but was: 200 OK` em `Q12ResilienciaObservabilidadeTest.java:76`
- **Classificação:** **KILLED**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-BACKEND-02
- **ID:** MUT-BACKEND-02
- **Arquivo:** `mppb.restapi.common.core.handler.ApiExceptionHandler`
- **Linha/condição:** Linha 65, trocar `HttpStatus.NOT_FOUND` (404) por `HttpStatus.INTERNAL_SERVER_ERROR` (500)
- **Diff aplicado:**
```diff
- return createProblemDetail(HttpStatus.NOT_FOUND, "Recurso não encontrado", exception, null);
+ // MUT-BACKEND-02: retornar 500 em vez de 404
+ return createProblemDetail(HttpStatus.INTERNAL_SERVER_ERROR, "Recurso não encontrado", exception, null);
```
- **Comando:** `mvn -pl restapi-common,mobile-service test -Dtest=Q12ResilienciaObservabilidadeTest#testNotFoundExceptionGera404 "-Dsurefire.failIfNoSpecifiedTests=false"`
- **Teste realmente executado:** `Q12ResilienciaObservabilidadeTest#testNotFoundExceptionGera404`
- **Resultado do processo:** Exit code 1
- **Assertion que falhou:** `expected: 404 NOT_FOUND but was: 500 INTERNAL_SERVER_ERROR` em `Q12ResilienciaObservabilidadeTest.java:88`
- **Classificação:** **KILLED**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-BACKEND-03
- **ID:** MUT-BACKEND-03
- **Arquivo:** `mppb.restapi.common.core.handler.ApiExceptionHandler`
- **Linha/condição:** Linha 83, trocar `HttpStatus.SERVICE_UNAVAILABLE` (503) por `HttpStatus.OK` (200)
- **Diff aplicado:**
```diff
- HttpStatus.SERVICE_UNAVAILABLE,
+ // MUT-BACKEND-03: retornar 200 em vez de 503
+ HttpStatus.OK,
```
- **Comando:** `mvn -pl restapi-common,mobile-service test -Dtest=Q12ResilienciaObservabilidadeTest#testRetryableExceptionGera503 "-Dsurefire.failIfNoSpecifiedTests=false"`
- **Teste realmente executado:** `Q12ResilienciaObservabilidadeTest#testRetryableExceptionGera503`
- **Resultado do processo:** Exit code 1
- **Assertion que falhou:** `expected: 503 SERVICE_UNAVAILABLE but was: 200 OK` em `Q12ResilienciaObservabilidadeTest.java:101`
- **Classificação:** **KILLED**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-BACKEND-04
- **ID:** MUT-BACKEND-04
- **Arquivo:** `mppb.restapi.common.core.handler.ApiExceptionHandler`
- **Linha/condição:** Linha 92, trocar `HttpStatus.BAD_GATEWAY` (502) por `HttpStatus.INTERNAL_SERVER_ERROR` (500)
- **Diff aplicado:**
```diff
- return createProblemDetail(HttpStatus.BAD_GATEWAY, "Erro em serviço externo", exception, null);
+ // MUT-BACKEND-04: retornar 500 em vez de 502
+ return createProblemDetail(HttpStatus.INTERNAL_SERVER_ERROR, "Erro em serviço externo", exception, null);
```
- **Comando:** `mvn -pl restapi-common,mobile-service test -Dtest=Q12ResilienciaObservabilidadeTest#testClientApiExceptionGera502 "-Dsurefire.failIfNoSpecifiedTests=false"`
- **Teste realmente executado:** `Q12ResilienciaObservabilidadeTest#testClientApiExceptionGera502`
- **Resultado do processo:** Exit code 1
- **Assertion que falhou:** `expected: 502 BAD_GATEWAY but was: 500 INTERNAL_SERVER_ERROR` em `Q12ResilienciaObservabilidadeTest.java:113`
- **Classificação:** **KILLED**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-BACKEND-05
- **ID:** MUT-BACKEND-05
- **Arquivo:** `mppb.restapi.common.core.handler.ApiExceptionHandler`
- **Linha/condição:** Linha 196, forçar inclusão da propriedade `trace` com stacktrace mesmo em profile `prod`
- **Diff aplicado:**
```diff
- if (includeTrace && runtimeEnv.shouldIncludeTrace()) {
+ // MUT-BACKEND-05: sempre incluir trace vazando em produção
+ if (true) {
```
- **Comando:** `mvn -pl restapi-common,mobile-service test -Dtest=Q12ResilienciaObservabilidadeTest#testErroInesperadoEmProdOmitiStackTrace "-Dsurefire.failIfNoSpecifiedTests=false"`
- **Teste realmente executado:** `Q12ResilienciaObservabilidadeTest#testErroInesperadoEmProdOmitiStackTrace`
- **Resultado do processo:** Exit code 1
- **Assertion que falhou:** `not to contain key: "trace"` em `Q12ResilienciaObservabilidadeTest.java:148`
- **Classificação:** **KILLED**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-BACKEND-06
- **ID:** MUT-BACKEND-06
- **Arquivo:** `mppb.restapi.common.core.error.feign.FeignErrorDecoder`
- **Linha/condição:** Linha 19, alterar `status >= 400 && status < 600` para `status >= 500 && status < 600`
- **Diff aplicado:**
```diff
- if (status >= 400 && status < 600) {
+ // MUT-BACKEND-06: não tratar 4xx como ClientApiException (apenas >= 500)
+ if (status >= 500 && status < 600) {
```
- **Comando (Baseline):** `mvn -pl restapi-common,mobile-service test -Dtest=Q12ResilienciaObservabilidadeTest#testFeignErrorDecoderTraduzDownstream "-Dsurefire.failIfNoSpecifiedTests=false"`
- **Resultado Baseline:** Exit code 0 (Passou) -> **SURVIVED (TEST GAP)** (teste da baseline cobria apenas status 504).
- **Comando (Pós-Gap Q13 F07):** `mvn -pl restapi-common,mobile-service test -Dtest=Q13MutationPropertyFuzzTest#testFuzzF07FeignErrorDecoder "-Dsurefire.failIfNoSpecifiedTests=false"`
- **Teste realmente executado:** `Q13MutationPropertyFuzzTest#testFuzzF07FeignErrorDecoder` (500 casos de status e bodies)
- **Resultado Pós-Gap:** Exit code 1
- **Assertion que falhou:** `[MUT-BACKEND-06: Status 409 deve decodificar para ClientApiException na iteracao 4] Expecting actual throwable to be an instance of: mppb.restapi.common.core.error.feign.ClientApiException but was: feign.FeignException$Conflict` em `Q13MutationPropertyFuzzTest.java:409`
- **Classificação:** **KILLED (Post-Gap)**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-BACKEND-07
- **ID:** MUT-BACKEND-07
- **Arquivo:** `mppb.restapi.common.core.error.feign.FeignErrorDecoder`
- **Linha/condição:** Linha 28, em `readBody`, retornar `""` direto sem ler o stream de corpo da resposta
- **Diff aplicado:**
```diff
- if (response.body() != null) { ... }
- return bodyString;
+ // MUT-BACKEND-07: retornar vazio direto sem ler o stream de corpo
+ return "";
```
- **Comando:** `mvn -pl restapi-common,mobile-service test -Dtest=Q13MutationPropertyFuzzTest#testFuzzF07FeignErrorDecoder "-Dsurefire.failIfNoSpecifiedTests=false"`
- **Teste realmente executado:** `Q13MutationPropertyFuzzTest#testFuzzF07FeignErrorDecoder`
- **Resultado do processo:** Exit code 1
- **Assertion que falhou:** `[MUT-BACKEND-07: Body deve ser incorporado na mensagem na iteracao 4] Expecting actual: "UpstreamClient#endpoint4 # ApiHttpStatus: 409 # body: " to contain: "Normal error body 4"` em `Q13MutationPropertyFuzzTest.java:417`
- **Classificação:** **KILLED**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-BACKEND-08
- **ID:** MUT-BACKEND-08
- **Arquivo:** `mppb.restapi.mobile.feature.notificacao.service.DispositivoFcmService`
- **Linha/condição:** Linha 35, omitir cálculo do hash SHA-256 e passar token bruto como `tokenHash`
- **Diff aplicado:**
```diff
- String tokenHash = sha256(tokenFcm);
+ // MUT-BACKEND-08: omitir o cálculo do hash SHA-256 e passar token bruto como tokenHash
+ String tokenHash = tokenFcm;
```
- **Comando (Baseline):** `mvn -pl mobile-service test -Dtest=DispositivoFcmServiceTest#registraPrimeiroDispositivoSemRetornarToken "-Dsurefire.failIfNoSpecifiedTests=false"`
- **Resultado Baseline:** Exit code 0 (Passou) -> **SURVIVED (TEST GAP)** (teste histórico usava mock sem validar o algoritmo SHA-256).
- **Comando (Pós-Gap Q13 P09):** `mvn -pl mobile-service test -Dtest=Q13MutationPropertyFuzzTest#testPropertyP09FcmTokenHashingAndNormalization "-Dsurefire.failIfNoSpecifiedTests=false"`
- **Teste realmente executado:** `Q13MutationPropertyFuzzTest#testPropertyP09FcmTokenHashingAndNormalization` (500 iterações)
- **Resultado Pós-Gap:** Exit code 1
- **Assertion que falhou:** `[MUT-BACKEND-08: TokenHash deve coincidir com o hash SHA-256 de 64 caracteres na iteracao 0] expected: "ba800231..." but was: "hdsmxle..."` em `Q13MutationPropertyFuzzTest.java:233`
- **Classificação:** **KILLED (Post-Gap)**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-BACKEND-09
- **ID:** MUT-BACKEND-09
- **Arquivo:** `mppb.restapi.mobile.feature.notificacao.service.DispositivoFcmService`
- **Linha/condição:** Linha 39, inverter condição: `if (!existentePorToken.isPresent())`
- **Diff aplicado:**
```diff
- if (existentePorToken.isPresent()) {
+ // MUT-BACKEND-09: inverter condição isPresent
+ if (!existentePorToken.isPresent()) {
```
- **Comando:** `mvn -pl mobile-service test -Dtest=DispositivoFcmServiceTest#registroDoMesmoTokenEIdempotente "-Dsurefire.failIfNoSpecifiedTests=false"`
- **Teste realmente executado:** `DispositivoFcmServiceTest#registroDoMesmoTokenEIdempotente`
- **Resultado do processo:** Exit code 1
- **Assertion que falhou:** `NoSuchElementException: No value present at Optional.get(Optional.java:143) at DispositivoFcmService.registrar(DispositivoFcmService.java:42)`
- **Classificação:** **KILLED**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-BACKEND-10
- **ID:** MUT-BACKEND-10
- **Arquivo:** `mppb.restapi.mobile.feature.notificacao.service.DispositivoFcmService`
- **Linha/condição:** Linha 110, alterar para rejeitar `ANDROID` (`if (!"IOS".equals(normalizada))`)
- **Diff aplicado:**
```diff
- if (!"ANDROID".equals(normalizada) && !"IOS".equals(normalizada)) {
+ // MUT-BACKEND-10: rejeitar ANDROID
+ if (!"IOS".equals(normalizada)) {
```
- **Comando:** `mvn -pl mobile-service test -Dtest=DispositivoFcmServiceTest#registraPrimeiroDispositivoSemRetornarToken "-Dsurefire.failIfNoSpecifiedTests=false"`
- **Teste realmente executado:** `DispositivoFcmServiceTest#registraPrimeiroDispositivoSemRetornarToken`
- **Resultado do processo:** Exit code 1
- **Assertion que falhou:** `IllegalArgumentException: plataforma invalida at DispositivoFcmService.plataformaValida(DispositivoFcmService.java:112)`
- **Classificação:** **KILLED**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-BACKEND-11
- **ID:** MUT-BACKEND-11
- **Arquivo:** `mppb.restapi.mobile.feature.notificacao.service.DispositivoFcmService`
- **Linha/condição:** Linha 88, inverter retorno de `desativar`: `return !desativou;`
- **Diff aplicado:**
```diff
- return desativou;
+ // MUT-BACKEND-11: inverter retorno booleano
+ return !desativou;
```
- **Comando:** `mvn -pl mobile-service test -Dtest=DispositivoFcmServiceTest#desativaDispositivoDoProprioUsuario "-Dsurefire.failIfNoSpecifiedTests=false"`
- **Teste realmente executado:** `DispositivoFcmServiceTest#desativaDispositivoDoProprioUsuario`
- **Resultado do processo:** Exit code 1
- **Assertion que falhou:** `expected: <true> but was: <false>` em `DispositivoFcmServiceTest.java:121`
- **Classificação:** **KILLED**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.

---

### MUT-BACKEND-12
- **ID:** MUT-BACKEND-12
- **Arquivo:** `mppb.restapi.common.core.handler.ApiExceptionHandler`
- **Linha/condição:** Linha 77, em `handleAccessDeniedException`, trocar `HttpStatus.FORBIDDEN` (403) por `HttpStatus.UNAUTHORIZED` (401)
- **Diff aplicado:**
```diff
- return createProblemDetail(HttpStatus.FORBIDDEN, "Acesso negado", exception, "Acesso negado.");
+ // MUT-BACKEND-12: retornar 401 UNAUTHORIZED em vez de 403 FORBIDDEN
+ return createProblemDetail(HttpStatus.UNAUTHORIZED, "Acesso negado", exception, "Acesso negado.");
```
- **Comando:** `mvn -pl restapi-common,mobile-service test -Dtest=Q13MutationPropertyFuzzTest#testPropertyP08ExceptionMappingAndSanitization "-Dsurefire.failIfNoSpecifiedTests=false"`
- **Teste realmente executado:** `Q13MutationPropertyFuzzTest#testPropertyP08ExceptionMappingAndSanitization`
- **Resultado do processo:** Exit code 1
- **Assertion que falhou:** `expected: 403 FORBIDDEN but was: 401 UNAUTHORIZED` em `Q13MutationPropertyFuzzTest.java:142`
- **Classificação:** **KILLED**
- **Restore confirmado:** `git restore` executado, `git diff` vazio.
