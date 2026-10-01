# Evidência Q8 — Backend: Performance Baseline (Q8-T02)

Data: 2026-09-30  
Branch: `qualidade/q8-performance-carga`  
Ambiente: Servidor de Teste `Q8PerformanceServer` (Host Windows 11 Físico, JDK 21 LTS Temurin)  
Porta: `http://localhost:8089`  
Ferramenta: k6 v0.54.0  
Configuração: 1 VU, duração de 10s, requisições com sleep de 50ms  
Classificação Arquitetural: **BENCHMARK DO HARNESS/CONTRATOS SINTÉTICOS** (ver `RISCO-Q8-002`)  

---

## 1. Auditoria Arquitetural do Harness (`Q8PerformanceServer`)

Conforme inspeção detalhada do arquivo `mobile-service/src/test/java/mppb/restapi/mobile/quality/Q8PerformanceServer.java`:
- O servidor utiliza `com.sun.net.httpserver.HttpServer` com serializador `Jackson ObjectMapper` e thread pool fixo de 200 threads.
- Os endpoints instanciam DTOs estáticos em memória replicando os contratos JSON do aplicativo móvel.
- **Ressalva Metodológica**: O tráfego **NÃO passa** pela stack Spring Boot completa do `mobile-service` (Spring MVC, DispatcherServlet, Tomcat embarcado, Spring Security Filters nem interceptors).
- **Enquadramento**: Os resultados representam o **benchmark do harness e dos contratos sintéticos locais**, servindo como teto teórico de serialização e protocolo, mas **NÃO refletem a capacidade de processamento da stack Spring real nem de produção**.
- **Risco Associado**: Formalizado sob `RISCO-Q8-002 — REPRESENTATIVIDADE DO HARNESS DE CARGA`.

---

## 2. Escopo e Endpoints Avaliados

A baseline de performance mediu o comportamento de referência do harness sob carga mínima e controlada, simulando os contratos:
1. `GET /api/public/health` (Probe sem autenticação)
2. `GET /api/public/noticias` (Serialização de listagem com 10 DTOs)
3. `GET /api/perfil/dados` (Validação de cabeçalho Bearer e perfil)
4. `GET /carteiras-funcionais/dados` (Payload de carteira funcional)
5. `GET /pagamentos/exercicios` (Lista de anos de folha)
6. `GET /pagamentos/2026` (Detalhamento mensal de proventos)

### Escopo das Asserções (Checks k6)
No script `q8_baseline.js`:
- Para todas as requisições: validação de status HTTP (`r.status === 200`).
- Para notícias: validação adicional de substring no corpo (`r.body.includes('noticia-1')`).
- *Nota Metodológica*: Não houve validação estrita de schema JSON completo em runtime.

---

## 3. Métricas Coletadas

| Métrica | Valor Observado | Detalhe |
| :--- | :---: | :--- |
| **Requisições Totais** | **1.074 reqs** | 100% de sucesso nas asserções |
| **Taxa de Throughput (RPS)** | **107,23 req/s** | Com delay de 50ms por iteração |
| **Latência Média (`http_req_duration`)** | **771,85 µs (0,77 ms)** | Tempo médio total de resposta |
| **Latência Mediana (p50)** | **581,90 µs (0,58 ms)** | 50% das requisições atendidas em < 0,6ms |
| **Latência Percentil 90 (p90)** | **1,58 ms** | 90% das requisições atendidas |
| **Latência Percentil 95 (p95)** | **1,99 ms** | 95% das requisições atendidas |
| **Latência Máxima** | **12,85 ms** | Warmup inicial de classes e sockets |
| **Percentil 99 (p99)** | *Não coletado* | k6 summary padrão não gerou p99 |
| **Taxa de Erro HTTP** | **0,00%** | Zero falhas de requisição ou status 4xx/5xx |
| **Heap JVM Utilizado** | **30 MB** (após baseline) | Heap total disponível: 3.888 MB |
| **Threads Ativas JVM** | **18 threads** | Thread pool estável |
| **CPU do Host** | *Não aferida* | `CPU HOST NÃO COLETADA DE FORMA DETERMINÍSTICA` |

---

## 4. Conclusão da Baseline

O harness sintético local apresenta latência sub-milissegundo em condições de 1 VU, demonstrando estabilidade estrita dos contratos locais e baixo consumo de recursos de heap (30 MB).
