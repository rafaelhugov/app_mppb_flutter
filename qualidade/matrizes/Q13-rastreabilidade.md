# Q13 — Matriz de Rastreabilidade

**Fase:** Q13 — Mutation Testing, Property-Based Testing e Fuzz Testing  
**Data:** 02/10/2026  
**Seed Canônica Global:** `130013`  
**Log de Execução Reproduzível Completo:** [`qualidade/evidencias/Q13/Q13-mutation-execution-log.md`](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q13/Q13-mutation-execution-log.md)

---

## 1. Rastreabilidade Completa de Alvos, Mutações, Propriedades e Fuzz

| Alvo | Técnica | Teste Automatizado | Mutação Aplicada / Invariante / Fuzz | Resultado | BUG / RISCO |
|---|---|---|---|---|---|
| `auth_provider.dart` | Mutation | `auth_provider_test.dart` | Omitir escrita do token JWT no storage | KILLED | N/A |
| `session_reset_provider.dart` | Mutation | `q13_fuzz_property_test.dart` (P07) | Remover invalidação de `carteiraProvider` no logout | SURVIVED -> KILLED por P07 | RISCO-Q13-001 (Gap de teste na baseline) |
| `auth_provider.dart` | Mutation | `auth_provider_test.dart` | Manter `isAuthenticated: false` após login | KILLED | N/A |
| `noticia_provider.dart` | Mutation | `q12_resiliencia_test.dart` | Definir `isLoading: true` no bloco catch | KILLED | N/A |
| `noticia_provider.dart` | Mutation | `q12_resiliencia_test.dart` | Manter `errorMessage` anterior em retry com sucesso | KILLED | N/A |
| `perfil_provider.dart` | Mutation | `q12_resiliencia_test.dart` | Re-lançar exceção `FormatException` do cache local | KILLED | N/A |
| `carteira_provider.dart` | Mutation | `carteira_provider_test.dart` | Forçar `isOffline: false` no fallback de cache | KILLED | N/A |
| `ouvidoria_provider.dart` | Mutation | `q13_fuzz_property_test.dart` (P03) | Inverter cálculo do 1º dígito verificador do CPF | SURVIVED -> KILLED por P03 | RISCO-Q13-001 (Gap de teste na baseline) |
| `ouvidoria_provider.dart` | Mutation | `q13_fuzz_property_test.dart` (P03) | Alterar validação de tamanho de `!= 11` para `!= 10` | SURVIVED -> KILLED por P03 | RISCO-Q13-001 (Gap de teste na baseline) |
| `device_registration_provider.dart` | Mutation | `device_registration_provider_test.dart` | Omitir chamada de registro de dispositivo no backend | KILLED | N/A |
| `input_formatters.dart` (Telefone) | Mutation | `ouvidoria_formatters_test.dart` | Alterar branch `text.length <= 10` para `<= 9` | KILLED | N/A |
| `input_formatters.dart` (CPF) | Mutation | `ouvidoria_formatters_test.dart` | Trocar delimitador de ponto por hífen no CPF | KILLED | N/A |
| `ApiExceptionHandler` (422) | Mutation | `Q12ResilienciaObservabilidadeTest.java` | Retornar HTTP 200 para `BusinessRuleException` | KILLED | N/A |
| `ApiExceptionHandler` (404) | Mutation | `Q12ResilienciaObservabilidadeTest.java` | Retornar HTTP 500 para `NotFoundException` | KILLED | N/A |
| `ApiExceptionHandler` (503) | Mutation | `Q12ResilienciaObservabilidadeTest.java` | Retornar HTTP 200 para `RetryableException` | KILLED | N/A |
| `ApiExceptionHandler` (502) | Mutation | `Q12ResilienciaObservabilidadeTest.java` | Retornar HTTP 500 para `ClientApiException` | KILLED | N/A |
| `ApiExceptionHandler` (500) | Mutation | `Q12ResilienciaObservabilidadeTest.java` | Incluir stacktrace `trace` em profile `prod` | KILLED | N/A |
| `FeignErrorDecoder` (decode) | Mutation | `Q13MutationPropertyFuzzTest.java` (F07) | Alterar `status >= 400` para `status >= 500` | SURVIVED -> KILLED por F07 | RISCO-Q13-001 (Gap de teste na baseline) |
| `FeignErrorDecoder` (readBody) | Mutation | `Q13MutationPropertyFuzzTest.java` (F07) | Retornar string vazia sem ler stream de resposta | SURVIVED -> KILLED por F07 | RISCO-Q13-001 (Gap de teste na baseline) |
| `DispositivoFcmService` (sha256) | Mutation | `Q13MutationPropertyFuzzTest.java` (P09) | Omitir hash e enviar `tokenFcm` bruto como hash | SURVIVED -> KILLED por P09 | RISCO-Q13-001 (Gap de teste na baseline) |
| `DispositivoFcmService` (lookup) | Mutation | `DispositivoFcmServiceTest.java` | Inverter condição `!existentePorToken.isPresent()` | KILLED | N/A |
| `DispositivoFcmService` (plataforma) | Mutation | `DispositivoFcmServiceTest.java` | Rejeitar plataforma `"ANDROID"` com exceção | KILLED | N/A |
| `DispositivoFcmService` (desativar) | Mutation | `DispositivoFcmServiceTest.java` | Retornar `!desativou` no método desativar | KILLED | N/A |
| `ApiExceptionHandler` (403) | Mutation | `Q13MutationPropertyFuzzTest.java` (P08) | Retornar HTTP 401 para `AccessDeniedException` | KILLED | N/A |
| DTOs Flutter (`UsuarioCarteira`, `Perfil`) | Property | `q13_fuzz_property_test.dart` (P01) | Seed 130013, 100 iterações / 100 casos | 100/100 íntegros | N/A |
| Formatters e Validadores Flutter | Property | `q13_fuzz_property_test.dart` (P02) | Seed 130014, 200 iterações / 200 casos | 0 exceções | N/A |
| `_isValidCPF` em Ouvidoria | Property | `q13_fuzz_property_test.dart` (P03) | Seed 130015, 500 iterações / 1.000 CPFs (válidos e corrompidos) | 500 aceitos / 500 rejeitados | N/A |
| `TelefoneInputFormatter` | Property | `q13_fuzz_property_test.dart` (P04) | Seed 130016, 500 iterações / 500 números | 500/500 válidos | N/A |
| `ServicoLinksExternos` | Property | `q13_fuzz_property_test.dart` (P05) | Seed 130017, 200 iterações / 200 URIs mailto | 200/200 válidas | N/A |
| Estados de Loading/Erro Flutter | Property | `q13_fuzz_property_test.dart` (P06) | Transição determinística de estados | Invariante mantida | N/A |
| Sessão e Reset Flutter | Property | `q13_fuzz_property_test.dart` (P07) | Logout em container com providers privados | Invariante mantida | N/A |
| Mapeamento de Exceções Backend | Property | `Q13MutationPropertyFuzzTest.java` (P08) | Seed 130013, 500 iterações / 500 exceções | 500/500 conformes | N/A |
| Hashing e Normalização FCM | Property | `Q13MutationPropertyFuzzTest.java` (P09) | Seed 130013, 500 iterações / 500 registros FCM | 500/500 conformes | N/A |
| Parsers de Cache Local Flutter | Fuzz | `q13_fuzz_property_test.dart` (F01) | 14 vetores de JSON malformados/aninhados | 0 crashes não tratados | N/A |
| Strings Extremas Flutter | Fuzz | `q13_fuzz_property_test.dart` (F02) | 100 casos com strings de 0 a 4096 caracteres | 0 vazamentos de memória | N/A |
| Unicode / Emojis / RTL Flutter | Fuzz | `q13_fuzz_property_test.dart` (F03) | 120 casos de caracteres complexos e controle | 0 falhas | N/A |
| Paginação e Limites Flutter | Fuzz | `q13_fuzz_property_test.dart` (F04) | 200 casos de índices negativos (-1) a 1000 | 0 RangeErrors | N/A |
| Jackson DTO Backend | Fuzz | `Q13MutationPropertyFuzzTest.java` (F05) | Seed 130013, 500 mutações de payload | 0 crashes | N/A |
| Sanitização ApiExceptionHandler | Fuzz | `Q13MutationPropertyFuzzTest.java` (F06) | Seed 130013, 500 vetores maliciosos | 0 vazamentos | N/A |
| Status / Corpos Feign Decoder | Fuzz | `Q13MutationPropertyFuzzTest.java` (F07) | Seed 130013, 500 respostas sintéticas | 0 falhas | N/A |
