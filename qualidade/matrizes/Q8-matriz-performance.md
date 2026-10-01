# Q8 — Matriz de Testes de Performance, Carga, Stress, Spike e Soak (Revalidação Q8-R01)

Data: 2026-09-30  
Branch: `qualidade/q8-performance-carga`  
Objetivo: Consolidação metodologicamente corrigida dos testes de performance em Backend e Flutter, com dados reais coletados em PROFILE e classificação auditada.

---

## 1. Matriz de Execução Q8 Revalidada

| ID | Componente | Teste | Carga / Cenário Aplicado | Métrica Principal | Resultado Observado | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **Q8-MAT-01** | Backend (Harness Sintético) | Performance Baseline (Q8-T02) | 1 VU (10s), delay 50ms | Latência p50/p95, Throughput | p50: 0,58ms, p95: 1,99ms, 107,23 RPS, 0,00% erro HTTP | **PASSOU** |
| **Q8-MAT-02** | Backend (Stack Real vs Harness) | Carga Progressiva / Load (Q8-T03) | 5 a 50 VUs (40s) no harness | Throughput, Latência p95 | 3.285 RPS, p95: 1,13ms no harness sintético local; capacidade do backend Spring real não aferida (`RISCO-Q8-002`) | **PARCIAL** |
| **Q8-MAT-03** | Backend (Harness Sintético) | Estresse Progressivo / Stress (Q8-T04) | 20 a 200 VUs (50s) no harness | Ponto de Degradação, RPS pico | 21.984 RPS pico, p95: 2,15ms, 0 erros no harness local; limite não determinado no ambiente disponível | **PASSOU** |
| **Q8-MAT-04** | Backend (Harness Sintético) | Pico Abrupto / Spike (Q8-T05) | 5 → 100 → 5 VUs (31s) no harness | Absorção de pico e recuperação | 11.483 RPS pico, p95: 0,99ms no harness, recuperação imediata pós-pico | **PASSOU** |
| **Q8-MAT-05** | Backend (Harness Sintético) | Carga Sustentada / Soak 60s (Q8-T06) | 20 VUs sustentados (60s) | Heap JVM, Threads, Tendência | 82.452 reqs (1.373 RPS), Heap estável (165MB → 159MB), sem tendência de leak na janela de 60s | **PASSOU** |
| **Q8-MAT-06** | Backend (Harness Sintético) | Recuperação pós-Stress (Q8-T07) | 200 VUs → 0 VUs | Retorno da latência e liberação | Latência normalizada para < 1ms, threads liberadas, pool estável no harness | **PASSOU** |
| **Q8-MAT-07** | Flutter (Galaxy A52 Profile) | Cold Start (Q8-T08) | 5 amostras válidas com force-stop | Mediana do tempo de inicialização | Mediana observada: 1.939 ms (amostras: 1970, 1981, 1897, 1939, 1897 ms; 0% com 0ms) | **PASSOU** |
| **Q8-MAT-08** | Flutter (Galaxy A52 Profile) | Warm Start (Q8-T08) | 5 amostras válidas pós-background | Mediana de retomada do app | Mediana observada: 107 ms (amostras: 139, 124, 93, 107, 92 ms) | **PASSOU** |
| **Q8-MAT-09** | Flutter (Galaxy A52 Profile) | Frames e Fluidez Visual (Q8-T11) | Scroll Home → Notícias → Scroll contínuo → Retorno | SurfaceFlinger SurfaceView BLAST | 125 frames analisados; 0% frames > 16,67 ms (60 FPS); máxima de 11,40 ms; sem jank relevante observado | **PASSOU** |
| **Q8-MAT-10** | Backend (Ambiente Corporativo) | Soak Longo de Produção | Janela prolongada (horas/dias) | Ausência de leak de longo prazo | Janela de horas não aplicável ao ambiente local; coberto soak de 60s no harness | **N/A** |
| **Q8-MAT-11** | Flutter (Galaxy A52 Profile) | Memória Temporal e Leak (Q8-T11) | Marcos M0 a M4 (dumpsys meminfo) | PSS, Estabilização temporal | M0 (203MB) → M1 (212MB) → M2 (210MB) → M3 (208MB) → M4 (208MB). Delta: +5,07 MB. Sem evidência de leak | **PASSOU** |
| **Q8-MAT-12** | Flutter (Dispositivo Físico) | Concorrência SQLite Local | Operações concorrentes no device | Integridade transacional e bloqueio | Validação arquitetural e funcional preservada; stress de I/O isolado não medido | **PARCIAL** |
| **Q8-MAT-13** | Flutter (Galaxy A52 Profile) | Cache e Decode de Imagens (Q8-T13) | Scroll contínuo em lista de notícias | Degradação de frame rate e RAM | Frames fluidos (11,11 ms) e memória estável sob scroll de imagens; impacto isolado de decode não desacoplável | **PARCIAL** |
| **Q8-MAT-14** | Flutter (Dispositivo Físico) | Streaming de Arquivos/PDF (Q8-T14) | Download de documentos | Alocação de memória em runtime | Arquitetura de streaming em disco verificada no código; impacto de runtime não medido sem arquivo corporativo real | **PARCIAL** |

---

## 2. Síntese Quantitativa da Matriz (Q8-R01)

- **Total de Cenários Avaliados**: 14
- **PASSOU**: 9 (Q8-MAT-01, Q8-MAT-03, Q8-MAT-04, Q8-MAT-05, Q8-MAT-06, Q8-MAT-07, Q8-MAT-08, Q8-MAT-09, Q8-MAT-11)
- **PARCIAL**: 4 (Q8-MAT-02, Q8-MAT-12, Q8-MAT-13, Q8-MAT-14)
- **SATURA**: 0
- **N/A**: 1 (Q8-MAT-10 — Soak corporativo de longo prazo não aplicável ao ambiente local)
- **DEGRADA**: 0
- **BLOQUEADO**: 0
- **Falhas / Violações Críticas**: 0
