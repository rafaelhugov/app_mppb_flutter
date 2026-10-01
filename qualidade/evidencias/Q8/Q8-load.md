# Evidência Q8 — Backend: Teste de Carga / Load (Q8-T03)

Data: 2026-09-30  
Branch: `qualidade/q8-performance-carga`  
Ambiente: Servidor de Teste `Q8PerformanceServer` (Host Windows 11 Físico, JDK 21 LTS Temurin)  
Porta: `http://localhost:8089`  
Ferramenta: k6 v0.54.0  
Configuração do Cenário:
- Carga progressiva: 5 VUs (10s) → 25 VUs (10s) → 50 VUs (10s) → ramp-down para 0 VUs (10s)
- Duração total: 40 segundos
Classificação Arquitetural: **BENCHMARK DO HARNESS/CONTRATOS SINTÉTICOS** (ver `RISCO-Q8-002`)  

---

## 1. Auditoria Arquitetural do Cenário

- **Servidor Testado**: Conforme detalhado em `Q8-backend-baseline.md`, o alvo é o harness sintético em memória `Q8PerformanceServer`. Ele não executa a stack Spring Boot real (`DispatcherServlet`, Spring MVC, Tomcat embarcado, Spring Security Filters).
- **Extrapolação**: Os dados de vazão (3.285 RPS) e latência (p95 de 1,13 ms) demonstram a robustez do harness e a eficiência da serialização Jackson em memória, mas **não representam a capacidade real do mobile-service em produção**.
- **Checks de Integridade**: O script `q8_load.js` valida **exclusivamente o status HTTP 200** (`check(res, { 'status is 200': (r) => r.status === 200 })`). Não houve validação profunda de estrutura ou campos do payload JSON durante o teste sob carga.

---

## 2. Escopo e Endpoints Avaliados

O teste avaliou o comportamento do harness sintético sob concorrência multiusuário nos seguintes contratos:
1. `GET /api/public/health` (Probe sem autenticação)
2. `GET /api/public/noticias` (Serialização DTO pública)
3. `GET /api/perfil/dados` (Validação Bearer e perfil)
4. `GET /pagamentos/exercicios` (Leitura de exercícios financeiros)

---

## 3. Métricas Coletadas

| Métrica | Valor Observado | Detalhe |
| :--- | :---: | :--- |
| **Requisições Totais Atendidas** | **131.448 reqs** | 100% de sucesso nas asserções de status |
| **Taxa Média de Throughput (RPS)** | **3.285,56 req/s** | Sustentada no harness durante o período |
| **Latência Média (`http_req_duration`)** | **0,50 ms** (495,85 µs) | Tempo médio de resposta por requisição |
| **Latência Mínima** | **0,00 ms** (sub-microsegundo) | Resposta imediata em memória |
| **Latência Mediana (p50)** | **0,38 ms** (384,70 µs) | 50% das requisições atendidas em < 0,4 ms |
| **Latência Percentil 90 (p90)** | **0,81 ms** (810,80 µs) | 90% das requisições atendidas em < 0,9 ms |
| **Latência Percentil 95 (p95)** | **1,13 ms** | 95% das requisições atendidas em ~1,1 ms |
| **Latência Máxima** | **130,54 ms** | Ocorrência pontual em transição de estágio |
| **Taxa de Erro HTTP (`http_req_failed`)**| **0,00%** (0 falhas) | Nenhuma requisição retornou status 4xx ou 5xx |
| **Volume de Dados Recebidos** | **234,2 MB** (5,85 MB/s) | Respostas JSON serializadas |
| **Volume de Dados Enviados** | **15,1 MB** (378,7 KB/s) | Requisições HTTP |
| **CPU do Host** | *Não aferida* | `CPU HOST NÃO COLETADA DE FORMA DETERMINÍSTICA` |
| **Heap JVM Utilizado** | **~45 MB** | Estável após execução |

---

## 4. Comportamento por Nível de Carga

| Estágio de Carga | Usuários Virtuais (VUs) | Comportamento Observado no Harness |
| :--- | :---: | :--- |
| **Ramp-up Inicial** | 5 VUs | Latência p50 ~0,35 ms, vazão estável |
| **Carga Média** | 25 VUs | Throughput crescente linearmente, sem aumento de fila |
| **Carga Máxima do Cenário** | 50 VUs | Throughput atingiu 3.285 RPS com p95 mantendo-se em 1,13 ms |
| **Ramp-down** | 50 → 0 VUs | Drenagem suave de conexões sem erros ou conexões presas |

---

## 5. Conclusão do Teste de Load

Classificação: **PASSOU (NO ESCOPO DO HARNESS SINTÉTICO)**.  
O harness local suportou a carga de 50 VUs com taxa de erro de 0,00% e latência p95 de 1,13 ms. A capacidade da stack Spring Boot real permanece não aferida conforme documentado em `RISCO-Q8-002`.
