# Evidência Q12 — Recuperação de Providers e Retry Manual

**Data de Execução:** 01/10/2026  
**Fase:** Q12 — Resiliência, Observabilidade e Recuperação  
**Ambiente:** Flutter (App Mobile)  
**Arquivo de Teste:** `test/features/resiliencia/q12_resiliencia_test.dart`

---

## 1. Objetivo

Verificar se os principais Notifiers e Providers da aplicação, diante de falhas de rede, 5xx, timeouts ou sessão expirada:
1. Detectam a falha e capturam a exceção sem crashar o isolate;
2. Entram em estado previsível (`isLoading = false`, `errorMessage != null`);
3. Não ficam permanentemente travados em loading;
4. Conseguem se recuperar para estado válido após acionamento de retry quando o backend ou a conexão retornam.

---

## 2. Testes de Recuperação dos Providers

### 2.1 NotíciaProvider (`NoticiaNotifier`)
- **Falha Injetada:** HTTP 500 no endpoint `/api/public/noticias`.
- **Comportamento Validado:**
  - `state.isLoading` transitou de `true` para `false`.
  - `state.errorMessage` foi populado com a mensagem de erro da API.
  - `state.noticias` permaneceu lista vazia e consistente (sem `null pointer`).
- **Recuperação:** Nova chamada a `fetchNoticias()` com backend recuperado resultou em:
  - `isLoading = false`;
  - `errorMessage = null`;
  - `noticias.length = 1` com título `'Noticia Recuperada Q12'`.
- **Status:** **PASSOU**

### 2.2 PagamentosProvider (`PagamentosNotifier`)
- **Falha Injetada:** `DioExceptionType.connectionTimeout` durante chamada a `/pagamentos`.
- **Comportamento Validado:**
  - `state.isLoading` desativado (`false`).
  - `state.errorMessage` exibiu mensagem amigável contextualizada.
  - `state.dados` permaneceu `null` sem corromper estado anterior.
- **Recuperação:** Chamada subsequente com sucesso preencheu `state.dados` com total de pagamentos e zerou `errorMessage`.
- **Status:** **PASSOU**

### 2.3 ContrachequeProvider (`ContraChequeNotifier`)
- **Falha Injetada:** HTTP 503 no endpoint `/contracheques/competencias`.
- **Comportamento Validado:**
  - `state.isLoading = false`, `state.errorMessage` preenchido.
  - `state.competencias` vazia e estável.
- **Recuperação:** Novo disparo de `carregarCompetencias()` carregou competências de 2026 e recuperou o contracheque mensal de valor líquido R$ 15.000,00 com sucesso.
- **Status:** **PASSOU**

### 2.4 Retry Manual de Tela (`Q12-T04`)
- **Cenário:** Falha de conexão simulada na primeira tentativa (`DioExceptionType.connectionError`), seguida de ação de retry manual do usuário.
- **Validação:**
  - Tentativa 1: `errorMessage != null`, `noticias` vazio.
  - Tentativa 2: Notifier reiniciou o fluxo, limpou o erro anterior, carregou notícia 201 com sucesso (`errorMessage == null`).
- **Status:** **PASSOU**

### 2.5 Sessão Expirada — 401 vs 403 (`Q12-T05`)
- **Cenário:** Simulação determinística de expiração de token.
- **Validação:**
  - **HTTP 401 Unauthorized:** Dispara logout automático no `authProvider`, limpando tokens de sessão e acionando `sessionResetProvider`.
  - **HTTP 403 Forbidden:** O usuário autenticado não possui permissão para acessar aquele recurso específico, mas sua sessão NÃO é destruída indevidamente (`isAuthenticated = true` mantido).
- **Status:** **PASSOU**
