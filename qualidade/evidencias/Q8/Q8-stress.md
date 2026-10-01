# Evidência Q8 — Backend: Teste de Stress / Estresse Progressivo (Q8-T04)

Data: 2026-09-30  
Branch: `qualidade/q8-performance-carga`  
Ambiente: Servidor de Teste `Q8PerformanceServer` (Host Windows 11 Físico, JDK 21 LTS Temurin)  
Porta: `http://localhost:8089`  
Ferramenta: k6 v0.54.0  
Configuração do Cenário:
- Carga progressiva: 20 VUs (10s) → 50 VUs (10s) → 100 VUs (10s) → 200 VUs (10s) → ramp-down (10s)
- Duração total: 50 segundos  
Classificação Arquitetural: **BENCHMARK DO HARNESS/CONTRATOS SINTÉTICOS** (ver `RISCO-Q8-002`)  

---

## 1. Auditoria Arquitetural do Cenário

- **Servidor Testado**: O alvo é o harness sintético em memória `Q8PerformanceServer`.
- **Ressalva Metodológica de Extrapolação**:
  > **NÃO DECLARAR QUE PRODUÇÃO OU O BACKEND REAL SUPORTAM 22K RPS.**  
  > Os valores de 21.984 RPS e p95 de 2,15 ms refletem a capacidade máxima do servidor sintético local em loopback TCP e não podem ser extrapolados para a stack Spring Boot nem para produção corporativa.
- **Checks de Integridade**: O script `q8_stress.js` valida **exclusivamente o status HTTP 200** (`check(res, { 'status is 200': (r) => r.status === 200 })`). Não houve validação profunda de estrutura ou campos do payload JSON.

---

## 2. Escopo e Endpoints Avaliados

O teste elevou a concorrência no harness nos seguintes contratos:
1. `GET /api/public/health` (Probe)
2. `GET /api/public/noticias` (Serialização DTO pública)
3. `GET /api/perfil/dados` (Validação Bearer e perfil autenticado)

---

## 3. Métricas Coletadas

| Métrica | Valor Observado | Detalhe |
| :--- | :---: | :--- |
| **Requisições Totais Atendidas** | **1.099.299 reqs** | Processadas pelo harness local |
| **Taxa de Throughput de Pico (RPS)**| **21.984,67 req/s** | Carga máxima aplicada (200 VUs) |
| **Latência Média (`http_req_duration`)** | **0,62 ms** (620,58 µs) | No harness local |
| **Latência Mediana (p50)** | **0,38 ms** (383,30 µs) | Praticamente inalterada |
| **Latência Percentil 90 (p90)** | **1,44 ms** | Elevação controlada de 0,81 ms → 1,44 ms |
| **Latência Percentil 95 (p95)** | **2,15 ms** | Elevação controlada de 1,13 ms → 2,15 ms |
| **Latência Máxima** | **39,29 ms** | Sem congelamento ou spike destrutivo |
| **Taxa de Erro HTTP (`http_req_failed`)**| **0,00%** (0 falhas) | Nenhuma requisição rejeitada |
| **Volume de Dados Recebidos** | **1.583,98 MB (1,58 GB)**| Tráfego local gerado |
| **Volume de Dados Enviados** | **134,11 MB** | Requisições HTTP locais |
| **CPU do Host** | *Não aferida* | `CPU HOST NÃO COLETADA DE FORMA DETERMINÍSTICA` |

---

## 4. Monitoramento da JVM do Processo de Teste

Métricas extraídas via probe interno (`metrics_after_stress.json`):

| Parâmetro JVM | Valor Observado | Análise |
| :--- | :---: | :--- |
| **Heap Utilizado** | **165 MB** | Muito inferior ao limite de 3.888 MB |
| **Non-Heap (Metaspace/CodeCache)** | **34 MB** | Estável |
| **Threads Totais da JVM** | **212 threads** | Thread pool escalou para 200 VUs |
| **Pico Histórico de Threads** | **215 threads** | Gerenciamento de pool estável |
| **Erros Internos da JVM** | **0** | Sem `OutOfMemoryError` |

---

## 5. Análise de Ponto de Degradação e Saturação

- **Curva de Degradação no Harness**: A latência p95 aumentou de 1,13 ms (50 VUs) para 2,15 ms (200 VUs), aumento linear e proporcional à concorrência.
- **Limite Técnico**:
  > **LIMITE NÃO DETERMINADO NO AMBIENTE DISPONÍVEL**  
  > O harness local permaneceu estável até a carga máxima aplicada de 200 VUs e ~22.000 RPS sem apresentar saturação ou quebra no ambiente de teste local.

---

## 6. Conclusão do Teste de Stress

Classificação: **PASSOU (NO ESCOPO DO HARNESS SINTÉTICO)**.  
O harness local permaneceu estável até a carga máxima aplicada. A capacidade da stack Spring real e de produção permanece não aferida conforme `RISCO-Q8-001` e `RISCO-Q8-002`.
