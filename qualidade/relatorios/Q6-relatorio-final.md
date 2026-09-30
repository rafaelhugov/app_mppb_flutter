# Q6 — Relatório Final: Concorrência, Idempotência e Integridade

Data: 2026-09-29  
Branch: `qualidade/q6-concorrencia-integridade`  
Ciclo: Qualidade, Confiabilidade e Prontidão do App MPPB  
Status: **Q6 CONSOLIDADA — CONCORRÊNCIA, IDEMPOTÊNCIA E INTEGRIDADE VALIDADAS NO ESCOPO TESTADO**  
Próxima Fase: **Q7 NÃO INICIADA**  

---

## 1. Resumo Executivo

A fase **Q6 — Concorrência, Idempotência e Integridade** avaliou e comprovou o comportamento do ecossistema App MPPB (Flutter) e Backend (Spring Boot / mobile-service) sob condições de:
- Ações simultâneas e duplo toque rápido;
- Requisições concorrentes equivalentes;
- Respostas fora de ordem (race conditions de rede);
- Descarte de widgets/providers durante requisições em trânsito (acesso pós-dispose);
- Logout efetuado durante operações assíncronas;
- Troca de usuários e isolamento de cache seguro;
- Notificações duplicadas e desativação repetida de FCM;
- Downloads paralelos de arquivos e relatórios PDF;
- Rollback transacional e constraints de unicidade no backend;
- Concorrência de leitura com identidades e parâmetros distintos.

Todas as suítes foram implementadas com dublês e sincronizadores determinísticos (`Completer`, `CountDownLatch`, `CompletableFuture`), garantindo 100% de repetibilidade e zero dependência de delays arbitrários (`sleep`).

---

## 2. Inventário e Classificação de Operações

Foram mapeadas e classificadas **28 operações** em `qualidade/inventarios/Q6-inventario-concorrencia.md`:

| Categoria | Quantidade | Operações Típicas |
| :--- | :---: | :--- |
| **Mutáveis** | 10 | Login, Logout, Registro FCM, Desativação FCM, Solicitação/Adiamento/Antecipação/Cancelamento/Suspensão de Férias |
| **Somente Leitura** | 15 | Notícias, Pagamentos (anos/itens), Contracheque (exercícios/meses/PDF), Carteira (dados/foto), Perfil, Concessões, Ausências, Designações, Diário Oficial, Consulta Certidão |
| **Idempotentes Comprovadas** | 3 | Registro Dispositivo FCM, Desativação Dispositivo FCM, Logout |
| **Não Idempotentes** | 6 | Ações de RH no MPVirtual (solicitação de férias, adiamento, antecipação, cancelamento, suspensões) |
| **Idempotência Desconhecida** | 1 | Autenticação Auth API (`POST /acesso/autoriza`) |
| **Bloqueadas para Automação Real** | 3 | Manifestação Ouvidoria, Emissão de Certidão com efeito institucional, Consulta com Captcha |

---

## 3. Síntese dos Testes por Módulo

### A. Flutter (`q6_flutter_concurrency_test.dart`) — 11/11 PASS (100%)
1. **Q6-T02 (Duplo Toque Login)**: Disparo do login bloqueia imediatamente segundos envios enquanto `isLoading == true`. Exatamente 1 chamada HTTP efetuada.
2. **Q6-T02/T11 (Identificador FCM)**: Chamadas consecutivas de registro preservam o mesmo `UUIDv4` estável de instalação.
3. **Q6-T03 (Chamadas Simultâneas)**: Duas requisições paralelas de carteira convergem sem duplicação de dados.
4. **Q6-T04 (Respostas Fora de Ordem)**: Resposta tardia de exercício anterior (2024) não sobrescreve o exercício mais recente selecionado pelo usuário (2023).
5. **Q6-T05 (Dispose em Request)**: Descarte de container com request de perfil em trânsito não lança erro pós-dispose (`ref.mounted`).
6. **Q6-T06 (Logout em Request)**: Resposta autenticada que chega após logout não polui nem restaura a sessão no estado público.
7. **Q6-T07 (Troca de Usuário)**: Logout purga chaves de cache no storage seguro, garantindo isolamento entre usuário A e B.
8. **Q6-T11 (Deduplicação Push)**: Eventos idênticos de abertura de push com mesmo `messageKey` disparam apenas uma ação de navegação.
9. **Q6-T12 (Downloads PDF)**: Duas solicitações paralelas de PDF recebem buffers íntegros e idênticos sem corrupção.
10. **Q6-T13 (Filtros Rápidos)**: Digitação rápida concorrente converge para o último termo digitado.
11. **Q6-T16 (Concorrência de Leitura)**: Múltiplas leituras paralelas preservam cabeçalhos e dados isolados.

### B. Backend (`Q6ConcorrenciaIntegridadeTest.java`) — 6/6 PASS (100%)
1. **Q6-T08/T09 (Registro Concorrente)**: 4 threads concorrentes registrando o mesmo token/identificador convergem atomicamente para 1 registro ativo no banco.
2. **Q6-T11 (Desativação Repetida)**: Desativações repetidas do mesmo dispositivo são idempotentes (sem erro e sem reativação espúria).
3. **Q6-T14 (Rollback Transacional)**: Payload inválido em método `@Transactional` é abortado sem persistir registros órfãos.
4. **Q6-T15 (Constraints de Unicidade)**: Re-registro de token FCM existente para novo identificador realiza atualização lógica sem colisão de chave única.
5. **Q6-T16 (Leitura Concorrente Perfil)**: 10 threads paralelas para usuários distintos recebem estritamente seus próprios dados.
6. **Q6-T16 (Leitura Concorrente Pagamentos)**: Consultas paralelas de múltiplos usuários e exercícios operam isoladamente sem vazamento de CPFs.

---

## 4. Bugs Encontrados e Corrigidos

| ID | Módulo | Descrição do Bug | Causa Raiz | Correção Aplicada | Status |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **BUG-Q6-001** | Flutter / Pagamentos | Resposta fora de ordem de exercício anterior sobrescrevia exercício selecionado mais recente | `fetchPagamentos` não verificava se o exercício que respondeu ainda correspondia a `state.exercicioAtual` | Adicionado guard `if (!ref.mounted \|\| state.exercicioAtual != exercicioRequisitado) return;` e preservação do exercício atual selecionado | **CORRIGIDO** |
| **BUG-Q6-002** | Flutter / Auth | Duplo clique rápido no botão Entrar disparava múltiplas requisições concorrentes POST `/acesso/autoriza` | `AuthNotifier.login` não checava `state.isLoading` antes de iniciar nova chamada assíncrona | Adicionada guarda inicial `if (state.isLoading) return false;` no método `login()` | **CORRIGIDO** |
| **BUG-Q6-003** | Flutter / Carteira & Perfil | Resposta de API autenticada em trânsito que chegava pós-logout restaurava dados no estado da UI | Providers não verificavam se o token continuava ativo após o retorno assíncrono da rede | Inserida validação pós-await `currentToken == null \|\| currentToken != token` e reset de estado no logout | **CORRIGIDO** |
| **BUG-Q6-004** | Flutter / Auth & Dispose | `AuthNotifier._checkInitialAuth` acessava o `ref` e mutava estado após `await` assíncrono em provider descartado | Leitura assíncrona em secure storage durante inicialização tentava mutar `state` em `Ref` após descarte do container (`Ref._throwIfInvalidUsage`) | Adicionada guarda `if (!ref.mounted) return;` após as operações assíncronas em `_checkInitialAuth()` | **CORRIGIDO** |

---

## 5. Riscos Identificados e Formalizados

### `RISCO-Q6-001` — Ausência de Idempotency-Key Institucional no MPVirtual (RH)
- **Descrição**: Operações mutáveis de RH (solicitação de gozo de férias, adiamento, antecipação, suspensão) executadas via `mobile-service` funcionam como proxy para o sistema legado MPVirtual.
- **Proteção Atual**: O App MPPB bloqueia duplo clique na UI via flags booleanas locais (`_isSubmitting`, `_isExecuting`).
- **Gargalo**: Em caso de timeout de rede ou retry automático entre proxy e MPVirtual, não há protocolo padronizado de cabeçalho `Idempotency-Key`.
- **Recomendação**: Documentado como decisão de arquitetura corporativa para futuras fases de evolução de infraestrutura do MPPB. Não alterado no código para respeitar a integridade de regras de negócio legadas.

---

## 6. Critérios de Saída e Encerramento

- [x] Operações suscetíveis a concorrência inventariadas e classificadas (`Q6-inventario-concorrencia.md`);
- [x] Duplo toque no Flutter avaliado e corrigido (`BUG-Q6-002`);
- [x] Respostas fora de ordem avaliadas e corrigidas (`BUG-Q6-001`);
- [x] Logout e dispose durante requests assíncronas avaliados e corrigidos (`BUG-Q6-003`);
- [x] Backend mutável com concorrência e idempotência validadas (`Q6ConcorrenciaIntegridadeTest.java`);
- [x] Transações backend e rollback verificados;
- [x] Deduplicação e estabilidade de FCM comprovadas;
- [x] Testes concorrentes 100% determinísticos;
- [x] Regressão final de gates executada e verde;
- [x] Q7 não foi iniciada;
- [x] `pubspec.yaml` preservado com alteração local pré-existente (`4.0.0+69 -> 4.0.0+72`) fora do escopo;
- [x] Nenhum commit e nenhum push efetuados.
