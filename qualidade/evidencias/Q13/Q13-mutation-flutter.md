# Q13 — Evidência de Mutation Testing: Flutter

**Data:** 02/10/2026  
**Repositório:** `app_mppb_flutter`  
**Ambiente de Execução:** Worktree temporário isolado `..\app_mppb_flutter_q13_mut`  
**Baseline Testes:** 231 testes unitários e de integração  
**Log de Execução Reproduzível Completo:** [`qualidade/evidencias/Q13/Q13-mutation-execution-log.md`](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q13/Q13-mutation-execution-log.md)

---

## 1. Metodologia de Mutation Sampling Controlado

Conforme preconizado nas diretrizes da fase Q13, não foi introduzida dependência permanente de mutação pesada em produção. Em vez disso, foi criado um **worktree temporário** (`git worktree add ..\app_mppb_flutter_q13_mut master`), onde 12 mutações semânticas críticas de domínio foram aplicadas uma a uma e validadas contra a suíte de testes.

Para cada mutação foi rigorosamente registrado:
1. Código original
2. Aplicação da mutação
3. `git diff` exibindo exclusivamente a mutação
4. Teste específico executado
5. Falha de asserção comportamental
6. `git restore` e conferência de `git diff` vazio

Ao término da amostragem, o worktree temporário foi completamente desmontado e removido (`git worktree remove --force`), garantindo que nenhuma alteração mutante permanecesse no working tree canônico.

---

## 2. Tabela de Mutações Amostrais — Flutter

| ID | Arquivo | Mutação | Teste executado | Resultado Baseline | Resultado Pós-Gap (Q13) |
|---|---|---|---|---|---|
| MUT-FLUTTER-01 | `lib/features/auth/providers/auth_provider.dart` | Omitir `_storage.write(key: 'token', value: token)` no método `login` | `auth_provider_test.dart` | **KILLED** (`Expected: 'token-api', Actual: <null>`) | **KILLED** |
| MUT-FLUTTER-02 | `lib/core/session/session_reset_provider.dart` | Omitir `ref.invalidate(carteiraProvider)` no reset de sessão | Suíte histórica pré-Q13 (231 testes) | **SURVIVED BASELINE (TEST GAP)** | **KILLED** (`q13_fuzz_property_test.dart` P07: `Expected: null, Actual: <Instance of 'UsuarioCarteira'>`) |
| MUT-FLUTTER-03 | `lib/features/auth/providers/auth_provider.dart` | Definir `isAuthenticated: false` após login bem-sucedido | `auth_provider_test.dart` | **KILLED** (`Expected: true, Actual: <false>`) | **KILLED** |
| MUT-FLUTTER-04 | `lib/features/noticias/providers/noticia_provider.dart` | No catch de erro, definir `isLoading: true` em vez de `false` | `q12_resiliencia_test.dart` | **KILLED** (`Expected: false, Actual: <true>`) | **KILLED** |
| MUT-FLUTTER-05 | `lib/features/noticias/providers/noticia_provider.dart` | No sucesso de recarga, manter `errorMessage: state.errorMessage` | `q12_resiliencia_test.dart` | **KILLED** (`Expected: null, Actual: 'Erro ao carregar notícias...'`) | **KILLED** |
| MUT-FLUTTER-06 | `lib/features/perfil/providers/perfil_provider.dart` | No catch de cache corrompido, adicionar `rethrow` de `FormatException` | `q12_resiliencia_test.dart` | **KILLED** (`FormatException: Unexpected character...`) | **KILLED** |
| MUT-FLUTTER-07 | `lib/features/carteira/providers/carteira_provider.dart` | No fallback offline, definir `isOffline: false` | `carteira_provider_test.dart` | **KILLED** (`Expected: true, Actual: <false>`) | **KILLED** |
| MUT-FLUTTER-08 | `lib/features/ouvidoria/providers/ouvidoria_provider.dart` | Alterar cálculo de módulo 11 do 1º dígito de CPF: `d1 = 10 - ...` | `ouvidoria_formatters_test.dart` | **SURVIVED (TEST GAP)** | **KILLED** (`q13_fuzz_property_test.dart` P03: `Expected: null, Actual: 'O CPF informado é inválido.'`) |
| MUT-FLUTTER-09 | `lib/features/ouvidoria/providers/ouvidoria_provider.dart` | Na validação de tamanho de CPF, alterar de `!= 11` para `!= 10` | `ouvidoria_formatters_test.dart` | **SURVIVED (TEST GAP)** | **KILLED** (`q13_fuzz_property_test.dart` P03: `Expected: null, Actual: 'O CPF informado é inválido.'`) |
| MUT-FLUTTER-10 | `lib/core/notifications/device_registration_provider.dart` | Omitir chamada `_registrarComToken(token, 'ANDROID')` | `device_registration_provider_test.dart` | **KILLED** (`Expected: an object with length of <1>, Actual: []`) | **KILLED** |
| MUT-FLUTTER-11 | `lib/features/ouvidoria/utils/input_formatters.dart` | Em `TelefoneInputFormatter`, alterar `text.length <= 10` para `<= 9` | `ouvidoria_formatters_test.dart` | **KILLED** (`Expected: '(83) 99999-8888', Actual: '(83) 9999-98888'`) | **KILLED** |
| MUT-FLUTTER-12 | `lib/features/ouvidoria/utils/input_formatters.dart` | Em `CPFInputFormatter`, substituir pontos por hífens | `ouvidoria_formatters_test.dart` | **KILLED** (`Expected: '123.456.789-00', Actual: '123-456-789-00'`) | **KILLED** |

---

## 3. Classificação e Reexecução Concreta dos Sobreviventes

Os 3 mutantes sobreviventes na rodada inicial foram reexecutados contra as novas suítes e tiveram suas falhas de asserção confirmadas:
- **`MUT-FLUTTER-02`:** Reexecutado contra `testPropertyP07SessionResetAtomic()` (`P07`). Falhou com `Expected: null, Actual: <Instance of 'UsuarioCarteira'>`. Mutação morta.
- **`MUT-FLUTTER-08`:** Reexecutado contra `testPropertyP03CpfValidationInvariants()` (`P03`). Falhou com `Expected: null, Actual: 'O CPF informado é inválido.'` para CPF válido. Mutação morta.
- **`MUT-FLUTTER-09`:** Reexecutado contra `testPropertyP03CpfValidationInvariants()` (`P03`). Falhou com `Expected: null, Actual: 'O CPF informado é inválido.'` para CPF válido de 11 dígitos. Mutação morta.

---

## 4. Métricas de Mutation Score — Flutter

$$\text{Sampled Mutation Score} = \frac{\text{KILLED}}{\text{KILLED} + \text{SURVIVED}} \times 100$$

- **Total de Mutações Válidas:** 12
- **Mutações Executadas:** 12
- **KILLED (Baseline):** 9
- **SURVIVED (Baseline):** 3 (`MUT-FLUTTER-02`, `MUT-FLUTTER-08`, `MUT-FLUTTER-09`)
- **EQUIVALENT:** 0
- **INVALID:** 0
- **INITIAL SAMPLED MUTATION SCORE:** **75,0%** (9/12)
- **POST-GAP SAMPLED MUTATION SCORE:** **100,0%** (12/12 mortas na rodada pós-gap com suíte Q13)
