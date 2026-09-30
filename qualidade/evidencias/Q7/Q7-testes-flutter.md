# Evidência Q7 — Testes Determinísticos Flutter

Data: 2026-09-30  
Branch: `qualidade/q7-rede-offline-interrupcoes`  
Arquivo de Testes: `test/features/rede/q7_rede_interrupcoes_test.dart`  
Total de Testes na Suíte Q7: 18  
Resultado: 18 PASS / 0 FAIL  
Total Geral Flutter: 187/187 testes PASS

---

## 1. Cobertura dos Cenários de Teste

| Teste | Cenário | Falha Simulada | Comportamento Validado | Status |
| :--- | :--- | :--- | :--- | :---: |
| **Q7-T03** | Mapeamento Dio | Todos os tipos de `DioExceptionType` | Mapeamento e diferenciação precisa de 8 tipos de exceção de rede | PASSOU |
| **Q7-T04** | Notícias Offline | `DioExceptionType.connectionError` | `isLoading` encerra, `noticias` vazia, erro legível, sem crash | PASSOU |
| **Q7-T05** | Queda em Requisição | `DioExceptionType.cancel` | Encerra loading sem dados parciais corrompidos | PASSOU |
| **Q7-T06** | Timeout de Conexão | `DioExceptionType.connectionTimeout` | Encerra loading em timeout de forma controlada | PASSOU |
| **Q7-T07** | Retry de Leitura | Falha inicial seguida de retry com rede ativa | Erro limpo, loading transiciona e notícias são renderizadas | PASSOU |
| **Q7-T09** | Preservação em Refresh | Falha de rede durante pull-to-refresh | Itens prévios na tela são preservados intactos; erro sinalizado | PASSOU |
| **Q7-T11** | Reconexão de Rede | Offline inicial seguido de recuperação | Restabelecimento de rede permite nova chamada sem reiniciar app | PASSOU |
| **Q7-T12** | Interrupção de Lifecycle | Notifier descartado com request em trânsito | `!ref.mounted` previne mutação pós-dispose e `StateError` (BUG-Q7-002) | PASSOU |
| **Q7-T14** | Resposta Malformada | JSON truncado / objeto em vez de lista | Tratamento captura `FormatException`/`TypeError` sem crash | PASSOU |
| **Q7-T04** | Carteira Offline com Cache | Falha de conexão com cache prévio | Recupera dados do secure storage e ativa badge offline | PASSOU |
| **Q7-T04** | Carteira Dispose em Fallback | Dispose durante fallback de cache | `ref.mounted` previne mutação pós-dispose em leitura assíncrona (BUG-Q7-001) | PASSOU |
| **Q7-T04** | Perfil Offline com Cache | Timeout com cache prévio | Recupera dados locais e apresenta perfil sem travar | PASSOU |
| **Q7-T10** | Pagamentos Timeout | `DioExceptionType.receiveTimeout` | Loading encerra com mensagem amigável de erro de internet | PASSOU |
| **Q7-T15** | HTTP 401 na Sessão | Resposta 401 do backend | Interceptor aciona `authProvider.logout()`, invalidando sessão | PASSOU |
| **Q7-T16** | HTTP 403 na Sessão | Resposta 403 do backend | Não aciona logout indevido; mantém autenticação do usuário | PASSOU |
| **Q7-T18** | HTTP 503 Backend | Resposta 503 Service Unavailable | Mensagem amigável de indisponibilidade, sem crash | PASSOU |
| **Q7-T13** | Download Interrompido | Conexão abortada em download de PDF | Arquivo corrompido não é persistido nem considerado sucesso | PASSOU |
| **Q7-T08** | Política de Retry Mutável | Inspeção de interceptors do `dioProvider` | Sem interceptor de retry automático em operações mutáveis | PASSOU |
| **Q7-MAT-18** | Rate Limiting (429) | N/A | Sem contrato ou política de rate limiting vigente no projeto móvel | N/A |

---

## 2. Bugs Identificados e Corrigidos na Fase

- **`BUG-Q7-001`**: `CarteiraNotifier._loadFromCache` não checava `ref.mounted` após leituras assíncronas do secure storage. Se o container fosse descartado durante a leitura offline, disparava `StateError`. Corrigido com guardas `if (!ref.mounted) return;`.
- **`BUG-Q7-002`**: `NoticiaNotifier.fetchNoticias` não checava `ref.mounted` no início do método assíncrono disparado pelo microtask de `build()`. Corrigido com verificação de `ref.mounted`.
