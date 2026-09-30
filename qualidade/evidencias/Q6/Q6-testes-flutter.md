# Q6 — Evidência de Testes de Concorrência e Integridade (Flutter)

Data: 2026-09-29  
Branch: `qualidade/q6-concorrencia-integridade`  
Arquivo de Testes: `test/features/concorrencia/q6_flutter_concurrency_test.dart`  
Status: **12/12 PASS (100%)**  

---

## 1. Contexto e Objetivos

Esta suíte de testes comprova determinística e isoladamente o comportamento do App MPPB sob condições concorrentes, assíncronas e fora de ordem, validando a integridade do estado e ausência de contaminação ou exceções pós-dispose.

Foram utilizados dublês determinísticos (`_AsyncMockAdapter` e `_ControlledAsyncSecureStorage` com `Completer` para controle milimétrico de ordem de resolução) em vez de timeouts ou delays arbitrários suscetíveis a flakiness.

---

## 2. Cenários Testados e Resultados

| ID | Cenário | Mecanismo de Sincronização | Resultado |
| :--- | :--- | :--- | :---: |
| **Q6-T02** | Duplo clique no botão de login não dispara múltiplas requisições de autenticação | `Completer` segurando resposta de rede; segundo toque acionado durante `isLoading == true` | **PASS (1 única requisição)** |
| **Q6-T02/T11** | Duplo registro de dispositivo FCM reutiliza o mesmo identificador estável de instalação | `DeviceRegistrationManager` acionado sequencialmente/concorrentemente com o mesmo token | **PASS (Mesmo UUIDv4)** |
| **Q6-T03** | Duas requisições simultâneas de carteira funcional preservam integridade sem duplicação | `Future.wait([req1, req2])` com `Completer` único de API | **PASS (Dados íntegros)** |
| **Q6-T04** | Resposta antiga (fora de ordem) não sobrescreve estado mais recente em Pagamentos | `Completer` de 2023 resolvido antes do `Completer` tardio de 2024; validação de `state.exercicioAtual` | **PASS (Sem contaminação)** |
| **Q6-T05** | `PerfilNotifier` lida com dispose do container/widget durante requisição em trânsito | `container.dispose()` acionado antes do retorno da API; sem `ref after dispose` | **PASS (Sem crash/erro)** |
| **Q6-T05 (BUG-Q6-004)** | `AuthNotifier` lida com dispose durante `_checkInitialAuth` sem erro pós-dispose | `Completer` segurando leitura assíncrona de storage; descarte antes da resolução | **PASS (Sem Ref._throwIfInvalidUsage)** |
| **Q6-T06** | Resposta autenticada de carteira que chega após logout não polui estado público | `logout()` acionado enquanto API em trânsito; verificação de token atual no retorno | **PASS (Sem vazamento)** |
| **Q6-T07** | Troca de Usuário A -> Logout -> Usuário B garante isolamento total de cache seguro | Simulação de chaves no storage seguro; purga completa de chaves no logout | **PASS (Zero resíduos)** |
| **Q6-T11** | `PushNavigationService` ignora eventos duplicados de push com mesma `messageKey` | Chamadas repetidas a `handleOpenedPayload` com mesma chave técnica | **PASS (1 navegação)** |
| **Q6-T12** | Duas requisições simultâneas de download de PDF retornam bytes íntegros | Downloads paralelos via Dio retornando streams de bytes | **PASS (Bytes idênticos)** |
| **Q6-T13** | Filtros rápidos concorrentes convergem confiavelmente para o último termo digitado | Mutações consecutivas de `searchTerm` ('c' -> 'con' -> 'concurso') | **PASS (Convergência)** |
| **Q6-T16** | Múltiplas leituras paralelas de carteira e perfil não misturam tokens nem estados | `Future.wait` com tokens distintos em headers Authorization separados | **PASS (Isolamento total)** |

---

## 3. Logs de Execução

```text
00:00 +0: loading test/features/concorrencia/q6_flutter_concurrency_test.dart
00:00 +0: Q6 - Concorrência, Idempotência e Integridade (Flutter) Q6-T02: duplo clique no login nao dispara multiplas autenticacoes concorrentes
00:00 +1: Q6 - Concorrência, Idempotência e Integridade (Flutter) Q6-T02/T11: duplo registro de FCM reutiliza o mesmo identificador unico de instalacao
00:00 +2: Q6 - Concorrência, Idempotência e Integridade (Flutter) Q6-T03: duas requisicoes simultaneas de carteira preservam integridade e nao duplicam dados
00:00 +3: Q6 - Concorrência, Idempotência e Integridade (Flutter) Q6-T04: resposta antiga (fora de ordem) nao sobrescreve estado mais recente em Pagamentos
00:00 +4: Q6 - Concorrência, Idempotência e Integridade (Flutter) Q6-T05: PerfilNotifier lida com dispose durante request sem erro pos-dispose
00:00 +5: Q6 - Concorrência, Idempotência e Integridade (Flutter) Q6-T05: AuthNotifier lida com dispose durante _checkInitialAuth sem erro pos-dispose (BUG-Q6-004)
00:00 +6: Q6 - Concorrência, Idempotência e Integridade (Flutter) Q6-T06: resposta de sessao autenticada que chega apos logout nao polui o estado publico
00:00 +7: Q6 - Concorrência, Idempotência e Integridade (Flutter) Q6-T07: troca de usuario A -> logout -> usuario B garante isolamento total de dados e cache
00:00 +8: Q6 - Concorrência, Idempotência e Integridade (Flutter) Q6-T11: PushNavigationService ignora eventos duplicados de mesmo payload e messageKey
00:00 +9: Q6 - Concorrência, Idempotência e Integridade (Flutter) Q6-T12: duas requisicoes simultaneas de download de PDF retornam bytes integros
00:00 +10: Q6 - Concorrência, Idempotência e Integridade (Flutter) Q6-T13: filtros rapidos concorrentes convergem para o ultimo termo digitado
00:00 +11: Q6 - Concorrência, Idempotência e Integridade (Flutter) Q6-T16: multiplas leituras simultaneas de carteira e perfil nao misturam tokens nem estados
00:00 +12: All tests passed!
```

---

## 4. Análise de Código e Linter

```text
flutter analyze
Analyzing app_mppb_flutter...
No issues found! (ran in 16.3s)
```
