# Evidência Q8 — Backend: Teste de Spike / Pico Abrupto (Q8-T05 e Q8-T07)

Data: 2026-09-30  
Branch: `qualidade/q8-performance-carga`  
Ambiente: Servidor de Teste `Q8PerformanceServer` (Host Windows 11 Físico, JDK 21 LTS Temurin)  
Porta: `http://localhost:8089`  
Ferramenta: k6 v0.54.0  
Configuração do Cenário:
- Carga basal inicial: 5 VUs (5s)
- Subida abrupta (Spike): 5 → 100 VUs em 3s (aceleração de 20x)
- Sustentação do pico: 100 VUs (10s)
- Queda abrupta: 100 → 5 VUs em 3s
- Estabilização pós-pico: 5 VUs (10s)
- Duração total: 31 segundos  
Classificação Arquitetural: **BENCHMARK DO HARNESS/CONTRATOS SINTÉTICOS** (ver `RISCO-Q8-002`)  

---

## 1. Auditoria Arquitetural do Cenário

- **Servidor Testado**: O alvo é o harness sintético em memória `Q8PerformanceServer`.
- **Ressalva Metodológica**: Os dados de vazão (11.483 RPS) e latência (p95 de 0,99 ms) demonstram a resiliência do harness local, mas não refletem a absorção de spike do backend Spring Boot completo nem de instâncias corporativas de produção.
- **Checks de Integridade**: O script `q8_spike.js` valida **exclusivamente o status HTTP 200** (`check(res, { 'status is 200': (r) => r.status === 200 })`). Não houve validação profunda de estrutura ou campos do payload JSON.

---

## 2. Escopo e Endpoints Avaliados

O teste simulou o aumento rápido de concorrência nos seguintes contratos:
1. `GET /api/public/health` (Probe)
2. `GET /api/public/noticias` (Serialização DTO pública)
3. `GET /api/perfil/dados` (Validação Bearer e perfil)

---

## 3. Métricas Coletadas

| Métrica | Valor Observado | Detalhe |
| :--- | :---: | :--- |
| **Requisições Totais Atendidas** | **356.085 reqs** | Atendimento no harness durante o ciclo |
| **Taxa Média de Throughput (RPS)** | **11.483,62 req/s** | Média do ciclo com pico |
| **Latência Média (`http_req_duration`)** | **0,34 ms** (340,45 µs) | Tempo médio global no harness |
| **Latência Mediana (p50)** | **0,32 ms** (323,20 µs) | Absorção do pico sem atraso de fila |
| **Latência Percentil 90 (p90)** | **0,72 ms** (716,80 µs) | 90% das requisições < 0,8 ms |
| **Latência Percentil 95 (p95)** | **0,99 ms** (993,06 µs) | p95 permaneceu abaixo de 1 ms no harness |
| **Latência Máxima Registrada** | **47,08 ms** | Ponto de acomodação de sockets |
| **Taxa de Erro HTTP (`http_req_failed`)**| **0,00%** (0 falhas) | Zero requisições com status 4xx/5xx |
| **Volume de Dados Recebidos** | **513,08 MB** (16,55 MB/s) | Volume de tráfego de respostas |
| **Volume de Dados Enviados** | **43,44 MB** (1,40 MB/s) | Volume de requisições enviadas |
| **CPU do Host** | *Não aferida* | `CPU HOST NÃO COLETADA DE FORMA DETERMINÍSTICA` |

---

## 4. Avaliação da Capacidade de Absorção e Recuperação (Q8-T07)

```text
Linha de base (5 VUs)  ──>  p50: ~0,30 ms, p95: ~0,60 ms
          │
          ▼ [Salto de 20x em 3 segundos]
Pico Máximo (100 VUs)  ──>  Throughput atingiu > 11.000 RPS, p95: 0,99 ms, 0 erros
          │
          ▼ [Queda para 5 VUs em 3 segundos]
Recuperação Pós-Pico   ──>  Latência p50 normalizou imediatamente para 0,32 ms,
                            sem conexões presas no harness local.
```

- **Absorção no Harness**: O servidor local absorveu a transição de 5 para 100 VUs sem recusa de conexão (`ECONNREFUSED`), sem timeouts e com 100% de status HTTP 200.
- **Recuperação no Harness**: Após a cessação do pico, a latência retornou imediatamente aos patamares de repouso.

---

## 5. Conclusão do Teste de Spike

Classificação: **PASSOU (NO ESCOPO DO HARNESS SINTÉTICO)**.  
O harness local absorveu a variação de carga e normalizou imediatamente. A capacidade de produção e da stack Spring Boot real permanece resguardada sob `RISCO-Q8-001` e `RISCO-Q8-002`.
