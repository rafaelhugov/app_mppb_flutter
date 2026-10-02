# Q13 — Matriz de Mutation Testing, Property-Based Testing e Fuzz Testing

**Fase:** Q13 — Mutation Testing, Property-Based Testing e Fuzz Testing  
**Data:** 02/10/2026  
**Seed Fixa Global:** `130013`  
**Escopo:** Frontend Flutter (`app_mppb_flutter`) e Backend Spring Boot (`spring-boot/restapi`)  
**Log de Execução Reproduzível Completo:** [`qualidade/evidencias/Q13/Q13-mutation-execution-log.md`](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q13/Q13-mutation-execution-log.md)

---

## 1. Critérios de Avaliação

- **Mutation Testing:**
  - `KILLED`: O conjunto de testes falhou ao detectar a mutação (comportamento desejado).
  - `SURVIVED`: O conjunto de testes passou inalterado mesmo com a mutação (gap detectado).
  - Status `PASSOU` para mutação morta na baseline (`KILLED`), `PARCIAL` para `SURVIVED` tratado como `TEST GAP` e subsequentemente morto por teste Q13.
- **Property-Based Testing:**
  - Execução parametrizada determinística com validação de invariantes de domínio.
  - Métricas expressas como *Loop Iterations* e *Generated Cases*.
  - Status `PASSOU` se todas as iterações confirmarem a invariante sem regressão ou exceção inesperada.
- **Fuzz Testing:**
  - Submissão de entradas anômalas, truncadas, malformadas ou maliciosas.
  - Status `PASSOU` se o sistema mantiver o contrato de erro e não apresentar crashes, OOM ou travamento da JVM/runtime.

---

## 2. Matriz de Execução

| ID | Técnica | Alvo | Mutação / Invariante / Fuzz | Resultado Baseline | Resultado Pós-Gap | Status |
|---|---|---|---|---|---|---|
| MUT-FLUTTER-01 | Mutation | `auth_provider.dart` (`login`) | Omitir `_storage.write(key: 'token', ...)` | KILLED | KILLED | PASSOU |
| MUT-FLUTTER-02 | Mutation | `session_reset_provider.dart` | Omitir `ref.invalidate(carteiraProvider)` | SURVIVED* | KILLED (P07) | PARCIAL |
| MUT-FLUTTER-03 | Mutation | `auth_provider.dart` (`login`) | Definir `isAuthenticated: false` | KILLED | KILLED | PASSOU |
| MUT-FLUTTER-04 | Mutation | `noticia_provider.dart` (`fetchNoticias`) | Manter `isLoading: true` no catch de erro | KILLED | KILLED | PASSOU |
| MUT-FLUTTER-05 | Mutation | `noticia_provider.dart` (`fetchNoticias`) | Não limpar `errorMessage` no sucesso do retry | KILLED | KILLED | PASSOU |
| MUT-FLUTTER-06 | Mutation | `perfil_provider.dart` (`_loadFromCache`) | Re-lançar `FormatException` em vez de fallback | KILLED | KILLED | PASSOU |
| MUT-FLUTTER-07 | Mutation | `carteira_provider.dart` (`_carregar`) | Definir `isOffline: false` no fallback de cache | KILLED | KILLED | PASSOU |
| MUT-FLUTTER-08 | Mutation | `ouvidoria_provider.dart` (`_isValidCPF`) | Alterar cálculo de módulo 11 do 1º dígito | SURVIVED* | KILLED (P03) | PARCIAL |
| MUT-FLUTTER-09 | Mutation | `ouvidoria_provider.dart` (`_isValidCPF`) | Alterar validação de tamanho de `!= 11` para `!= 10` | SURVIVED* | KILLED (P03) | PARCIAL |
| MUT-FLUTTER-10 | Mutation | `device_registration_provider.dart` | Omitir chamada `_registrarComToken(...)` | KILLED | KILLED | PASSOU |
| MUT-FLUTTER-11 | Mutation | `input_formatters.dart` (`Telefone`) | Alterar `text.length <= 10` para `<= 9` | KILLED | KILLED | PASSOU |
| MUT-FLUTTER-12 | Mutation | `input_formatters.dart` (`CPF`) | Trocar separador `.` por `-` na máscara | KILLED | KILLED | PASSOU |
| MUT-BACKEND-01 | Mutation | `ApiExceptionHandler` (BusinessRule) | Alterar status HTTP 422 para 200 | KILLED | KILLED | PASSOU |
| MUT-BACKEND-02 | Mutation | `ApiExceptionHandler` (NotFound) | Alterar status HTTP 404 para 500 | KILLED | KILLED | PASSOU |
| MUT-BACKEND-03 | Mutation | `ApiExceptionHandler` (Retryable) | Alterar status HTTP 503 para 200 | KILLED | KILLED | PASSOU |
| MUT-BACKEND-04 | Mutation | `ApiExceptionHandler` (ClientApi) | Alterar status HTTP 502 para 500 | KILLED | KILLED | PASSOU |
| MUT-BACKEND-05 | Mutation | `ApiExceptionHandler` (Generic) | Expor stacktrace `trace` em profile prod | KILLED | KILLED | PASSOU |
| MUT-BACKEND-06 | Mutation | `FeignErrorDecoder` (`decode`) | Alterar `status >= 400` para `status >= 500` | SURVIVED* | KILLED (F07) | PARCIAL |
| MUT-BACKEND-07 | Mutation | `FeignErrorDecoder` (`readBody`) | Retornar string vazia ignorando corpo | SURVIVED* | KILLED (F07) | PARCIAL |
| MUT-BACKEND-08 | Mutation | `DispositivoFcmService` (`registrar`) | Omitir hash `sha256(tokenFcm)` | SURVIVED* | KILLED (P09) | PARCIAL |
| MUT-BACKEND-09 | Mutation | `DispositivoFcmService` (`registrar`) | Inverter `!existentePorToken.isPresent()` | KILLED | KILLED | PASSOU |
| MUT-BACKEND-10 | Mutation | `DispositivoFcmService` (`plataformaValida`) | Rejeitar plataforma `"ANDROID"` | KILLED | KILLED | PASSOU |
| MUT-BACKEND-11 | Mutation | `DispositivoFcmService` (`desativar`) | Inverter retorno de `desativar`: `!desativou` | KILLED | KILLED | PASSOU |
| MUT-BACKEND-12 | Mutation | `ApiExceptionHandler` (AccessDenied) | Alterar status HTTP 403 para 401 | KILLED | KILLED | PASSOU |
| PROP-FLUTTER-01 | Property | `UsuarioCarteira` e `PerfilUsuario` (P01) | Roundtrip toJson -> fromJson (100 casos) | 100/100 íntegros | N/A | PASSOU |
| PROP-FLUTTER-02 | Property | Validadores e Formatters (P02) | Entradas variadas, vazias, limites (200 casos) | 0 exceções | N/A | PASSOU |
| PROP-FLUTTER-03 | Property | `OuvidoriaNotifier._isValidCPF` (P03) | 500 iterações / 1.000 CPFs (500 válidos vs 500 inválidos) | 500 válidos / 500 inválidos | N/A | PASSOU |
| PROP-FLUTTER-04 | Property | `TelefoneInputFormatter` (P04) | 500 números de 10 e 11 dígitos com regex | 500/500 válidos | N/A | PASSOU |
| PROP-FLUTTER-05 | Property | `ServicoLinksExternos.uriEmail` (P05) | 200 e-mails institucionais variados | 200/200 válidos | N/A | PASSOU |
| PROP-FLUTTER-06 | Property | `NoticiaState` (P06) | Transição de estados de loading e erro | Invariante mantida | N/A | PASSOU |
| PROP-FLUTTER-07 | Property | `sessionResetProvider` (P07) | Invalidação de sessão atômica no logout | Invariante mantida | N/A | PASSOU |
| PROP-BACKEND-08 | Property | `ApiExceptionHandler` (P08) | 500 casos de exceções e supressão de trace | 500/500 íntegros | N/A | PASSOU |
| PROP-BACKEND-09 | Property | `DispositivoFcmService` (P09) | 500 tokens FCM com validação de SHA-256 | 500/500 íntegros | N/A | PASSOU |
| FUZZ-FLUTTER-01 | Fuzz | Parsers de Cache Local (F01) | 14 vetores de JSON malformados/aninhados | 0 crashes não tratados | N/A | PASSOU |
| FUZZ-FLUTTER-02 | Fuzz | Validadores de Entrada (F02) | Strings de 0 a 4096 caracteres (100 casos) | 0 estouros de memória | N/A | PASSOU |
| FUZZ-FLUTTER-03 | Fuzz | Sanitizadores de Texto (F03) | Unicode, emojis, RTL, zero-width (120 casos) | 0 falhas de parsing | N/A | PASSOU |
| FUZZ-FLUTTER-04 | Fuzz | Paginação e Limites (F04) | Índices negativos (-1), 0, max, max+1 (200 casos) | 0 exceções de Range | N/A | PASSOU |
| FUZZ-BACKEND-05 | Fuzz | Jackson DTO Deserializer (F05) | 500 payloads DTO corrompidos/incompletos | 0 crashes da JVM | N/A | PASSOU |
| FUZZ-BACKEND-06 | Fuzz | Sanitização `ApiExceptionHandler` (F06) | 500 payloads maliciosos (SQL, paths, tokens) | 0 vazamentos de dados | N/A | PASSOU |
| FUZZ-BACKEND-07 | Fuzz | `FeignErrorDecoder` (F07) | 500 combinações de status (200..601) e bodies | 0 falhas inesperadas | N/A | PASSOU |

*\* Nota de classificação: Os sobreviventes amostrais detectados na bateria inicial (`MUT-FLUTTER-02`, `MUT-FLUTTER-08`, `MUT-FLUTTER-09`, `MUT-BACKEND-06`, `MUT-BACKEND-07`, `MUT-BACKEND-08`) foram formalmente classificados como `TEST GAP`, documentados e eliminados pelas novas suítes de testes determinísticos de propriedade e fuzzing adicionadas na Q13.*

---

## 3. Resumo Consolidado de Status

- **Total de Itens Auditados:** 38
- **PASSOU:** 32
- **PARCIAL (Gaps de teste identificados na baseline e eliminados na suíte Q13):** 6
- **FALHOU:** 0
- **BLOQUEADO:** 0
- **N/A:** 0
