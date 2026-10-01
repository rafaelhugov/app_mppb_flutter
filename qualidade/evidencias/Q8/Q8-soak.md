# Evidência Q8 — Backend: Teste de Soak / Carga Sustentada (Q8-T06)

Data: 2026-09-30  
Branch: `qualidade/q8-performance-carga`  
Ambiente: Servidor de Teste `Q8PerformanceServer` (Host Windows 11 Físico, JDK 21 LTS Temurin)  
Porta: `http://localhost:8089`  
Ferramenta: k6 v0.54.0  
Configuração do Cenário:
- Carga sustentada contínua: 20 VUs constantes
- Duração: 60 segundos ininterruptos
- Cadência de iteração: sleep de 50 ms por ciclo por usuário virtual  
Classificação Arquitetural: **BENCHMARK DO HARNESS/CONTRATOS SINTÉTICOS** (ver `RISCO-Q8-002`)  

---

## 1. Justificativa Técnica da Janela de Teste e Calibração

- A execução de 60 segundos sob 20 VUs gerou **82.452 requisições** adicionais no harness local, elevando o acumulado do processo para mais de 1,6 milhão de requisições.
- **Ressalva Metodológica de Soak de Longo Prazo**:
  > A janela de 60 segundos é tecnicamente válida para detectar problemas rápidos do harness (exaustão imediata de descritores de sockets TCP, descontrole de threads no pool ou vazamentos grosseiros de buffers de serialização).  
  > **NÃO constitui prova definitiva de ausência de memory leak de longo prazo** (dias/semanas de operação corporativa contínua).  
  > Formulação correta: **não foi observada tendência de leak durante a janela de 60s**.
- **Checks de Integridade**: O script `q8_soak.js` valida **exclusivamente o status HTTP 200** (`check(res, { 'status is 200': (r) => r.status === 200 })`). Não houve validação profunda de estrutura ou campos do payload JSON.

---

## 2. Escopo e Endpoints Avaliados

1. `GET /api/public/health` (Probe)
2. `GET /api/public/noticias` (Serialização DTO)
3. `GET /api/perfil/dados` (Validação de Token e Perfil)
4. `GET /pagamentos/exercicios` (Consulta de Exercícios)

---

## 3. Métricas Coletadas

| Métrica | Valor Observado | Detalhe |
| :--- | :---: | :--- |
| **Requisições Totais Atendidas** | **82.452 reqs** | 100% com status HTTP 200 |
| **Taxa Média de Throughput (RPS)** | **1.373,53 req/s** | Taxa sustentada e constante |
| **Latência Média (`http_req_duration`)** | **0,60 ms** (603,86 µs) | Estabilidade temporal no harness |
| **Latência Mediana (p50)** | **0,43 ms** (429,60 µs) | Sem acúmulo de fila |
| **Latência Percentil 90 (p90)** | **1,02 ms** | 90% das requisições em ~1 ms |
| **Latência Percentil 95 (p95)** | **1,44 ms** | 95% das requisições em ~1,4 ms |
| **Latência Máxima** | **69,85 ms** | Ocorrência isolada sem impacto global |
| **Taxa de Erro HTTP (`http_req_failed`)**| **0,00%** (0 falhas) | Zero erros ou timeouts |
| **Volume de Dados Recebidos** | **146,92 MB** (2,45 MB/s) | Tráfego total transferido |
| **Volume de Dados Enviados** | **9,50 MB** (158,3 KB/s) | Requisições HTTP |
| **CPU do Host** | *Não aferida* | `CPU HOST NÃO COLETADA DE FORMA DETERMINÍSTICA` |

---

## 4. Evolução Temporal da JVM do Processo de Teste

Comparação de métricas coletadas diretamente da JVM (`metrics_after_stress.json` vs `metrics_after_soak.json`):

| Indicador | Antes do Soak (Pós-Stress) | Ao Final do Soak (60s) | Variação / Diagnóstico |
| :--- | :---: | :---: | :--- |
| **Heap Utilizado** | 165 MB | **159 MB** | -6 MB (GC atuou normalmente) |
| **Heap Máximo** | 3.888 MB | 3.888 MB | Inalterado |
| **Non-Heap (Metaspace)** | 34 MB | 34 MB | Estabilizado |
| **Threads Ativas JVM** | 212 | 212 | 0 threads acumuladas indevidamente |
| **Pico de Threads** | 215 | 215 | Sem crescimento progressivo |
| **Erros Acumulados** | 0 | **0** | Zero erros no período |
| **Latência Inicial vs Final** | p50: 0,38 ms | p50: 0,43 ms | Sem degradação progressiva |

---

## 5. Conclusão do Teste de Soak

Classificação: **PASSOU (NO ESCOPO DO HARNESS LOCAL DE 60S)**.  
**Não foi observada tendência de leak durante a janela de 60s** no harness sintético local (heap oscilando de 165 MB para 159 MB e threads estáveis em 212). A ausência de leak em longo prazo para a stack de produção corporativa não foi inferida nem comprovada nesta execução.
