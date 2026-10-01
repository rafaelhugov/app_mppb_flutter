# Relatório Técnico Final — Fase Q8: Performance, Carga, Stress, Spike e Soak (Revalidação Metodológica Q8-R01)

Data de Consolidação: 2026-09-30  
Ciclo: Qualidade, Confiabilidade e Prontidão do App MPPB  
Fase: **Q8 — Performance, Carga, Stress, Spike e Soak**  
Status: **Q8 CONCLUÍDA — PERFORMANCE DO CLIENTE FLUTTER VALIDADA EM DISPOSITIVO FÍSICO E BENCHMARKS DE CARGA, STRESS, SPIKE E SOAK VALIDADOS NO HARNESS SINTÉTICO, MANTIDAS AS RESSALVAS DE CAPACIDADE DA STACK SPRING BOOT REAL E DO AMBIENTE DE PRODUÇÃO.**  
Próxima Fase: **Q9 NÃO INICIADA**  

---

## 1. Identificação de Ambiente e Rastreabilidade Git

| Componente | Repositório | Branch Ativa | Estado do Working Tree |
| :--- | :--- | :--- | :--- |
| **Flutter Frontend** | `C:\Users\rafae\projetosMPPB\app_mppb_flutter` | `qualidade/q8-performance-carga` | Working tree limpo para testes; sem commit; sem push; `pubspec.yaml +69 → +72` preservado |
| **Backend REST API** | `C:\Users\rafae\projetosMPPB\spring-boot\restapi` | `qualidade/q8-performance-carga` | Working tree limpo para testes; sem commit; sem push |
| **Dispositivo Android Físico** | Samsung Galaxy A52 (`SM-A525M`) | Serial `RX8RC09H70X` | Android 14 / API 34, `arm64-v8a`, Conexão física USB estável |

---

## 2. Histórico de Correções Metodológicas (Q8-R01)

A auditoria identificou não-conformidades metodológicas na bateria inicial da fase Q8. Todas foram corrigidas determinística e transparentemente na presente rodada Q8-R01:

1. **Build Flutter Profile Obrigatória (Problema 1)**:
   - A bateria inicial havia sido executada inadvertidamente sobre `app-homolog-debug.apk`.
   - Na rodada Q8-R01, gerou-se e instalou-se exclusivamente o APK **PROFILE**: `build/app/outputs/flutter-apk/app-homolog-profile.apk` (96,4 MB / 101.111.922 bytes), compilado com `--dart-define=API_URL=https://aplicativo-mppb-homolog.mppb.mp.br` e `--dart-define=Q5_E2E_DISABLE_FCM=true`. Nenhuma medição de debug foi reutilizada.
2. **Correção do Coletor PowerShell de Memória (Problema 2)**:
   - O script original gerou `0.12 MB` por causa de uma falha clássica de escopo em PowerShell: `$array -match regex` não popula grupos de captura em `$Matches` por elemento, reutilizando o resíduo do loop anterior (`123 / 1024 = 0.12 MB`).
   - Corrigido determinística com `Select-String -Pattern 'TOTAL PSS:\s*(\d+)' | Select-Object -First 1`, casado com `$linha.Line -match` e adicionada validação de sanidade (`assert $val > 50 MB`). Registrado como `BUG-Q8-HARNESS-001`.
3. **Cold Start com Amostras Válidas (Problema 3)**:
   - Reexecutado em hardware real até a obtenção de 5 amostras válidas (`> 0 ms`). Zero ocorrências de 0 ms aceitas. Mediana calculada estritamente sobre as 5 amostras válidas.
4. **Medição Real de Frame Timing e Jank (Problema 4)**:
   - Reconhecido que `dumpsys gfxinfo` retornava `0 frames` porque o Flutter utiliza `io.flutter.embedding.android.FlutterSurfaceView` com renderização C++ Vulkan/OpenGL direta, contornando a HWUI de Views Android nativas.
   - Adotada medição precisa via **SurfaceFlinger na camada BLAST do SurfaceView** (`dumpsys SurfaceFlinger --latency`), obtendo 125 frames reais exibidos no hardware do Galaxy A52.
5. **Série Temporal de Memória M0 a M4 (Problema 5)**:
   - Coletados 5 marcos temporais (M0 baseline, M1 após 5 ciclos, M2 após 10 ciclos, M3 após 15 ciclos e M4 pós-idle). Comprovada a desaceleração do crescimento e estabilização de consumo, sem tendência linear contínua de leak.
6. **Série Temporal de CPU (Problema 6)**:
   - Substituído snapshot pontual isolado por série temporal real (idle, scroll, navegação, pós-idle).
7. **Reclassificação Arquitetural do Backend (Problema 7)**:
   - Inspecionado `Q8PerformanceServer.java`. Constatado que o servidor é um harness sintético em memória baseado em `HttpServer` e Jackson, não trafegando pela stack Spring Boot real (`DispatcherServlet`, Spring MVC, Tomcat, Security Filters).
   - Reclassificado honestamente como **BENCHMARK DO HARNESS/CONTRATOS SINTÉTICOS**, sem extrapolação para a capacidade real de produção ou do `mobile-service`. Criado o `RISCO-Q8-002`.

---

## 3. Síntese dos Resultados Técnicos Obrigatórios

### A. Flutter Build e Instalação
- **APK Efetivamente Instalado**: `build/app/outputs/flutter-apk/app-homolog-profile.apk` (96,4 MB / 101.111.922 bytes).
- **Modo**: **PROFILE**.
- **Endpoint**: `https://aplicativo-mppb-homolog.mppb.mp.br`.
- **Package**: `br.mp.mppbapp.app.homolog` (`versionCode=72`).

---

### B. Startup (Galaxy A52 / Android 14 Físico em PROFILE)

#### Cold Start (5 amostras válidas > 0)
- Amostras: `[1.970, 1.981, 1.897, 1.939, 1.897] ms`
- Mediana Observada: **1.939 ms (~1,94 s)**.
- Descarte de amostras inválidas: 0 amostras com 0 ms (100% válidas).

#### Warm Start (5 amostras válidas > 0)
- Amostras: `[139, 124, 93, 107, 92] ms`
- Mediana Observada: **107 ms (~0,11 s)**.

---

### C. Fluidez Visual, Frames e Jank (PROFILE)

- **Ferramenta**: SurfaceFlinger Latency na camada `SurfaceView[br.mp.mppbapp.app.homolog/br.mp.mppbapp.app.MainActivity]@0(BLAST)`.
- **Cenário**: `Home → scroll → Notícias → scroll contínuo → voltar`.
- **Total de Frames Analisados**: **125 frames** (> 0).
- **Taxa de Atualização do Hardware**: **11,11 ms (~90 Hz)**.
- **Mediana Observada de Frame Duration**: **11,11 ms**.
- **Percentil 90 (p90)**: **11,18 ms**.
- **Percentil 95 (p95)**: **11,19 ms**.
- **Máxima Frame Duration**: **11,40 ms**.
- **Frames > 16,67 ms (Orçamento 60 Hz)**: **0 / 125 (0,0%)**.
- **Frames > 11,11 ms (Orçamento Estrito 90 Hz)**: **56 / 125 (44,8%)** (oscilação transitória mínima entre 11,11 ms e 11,40 ms).
- **Conclusão**: **SEM JANK RELEVANTE OBSERVADO** (100% dos frames dentro do orçamento padrão de 60 FPS; máxima duração observada limitada a 11,40 ms).

---

### D. Série Temporal de Memória e Avaliação de Leak (PROFILE)

Métricas coletadas via `dumpsys meminfo br.mp.mppbapp.app.homolog`:

| Checkpoint | Cenário Executado | Total PSS | Variação vs M0 |
| :--- | :--- | :---: | :---: |
| **M0** | Home inicial estabilizada | **203,06 MB** | — |
| **M1** | Após 5 ciclos completos de navegação | **212,69 MB** | +9,63 MB |
| **M2** | Após 10 ciclos completos | **210,91 MB** | +7,85 MB (-1,78 MB vs M1) |
| **M3** | Após 15 ciclos completos | **208,13 MB** | +5,07 MB (-2,78 MB vs M2) |
| **M4** | Retorno à Home + repouso (idle 8s) | **208,13 MB** | +5,07 MB (estável vs M3) |

**Conclusão**: **SEM EVIDÊNCIA DE LEAK**. O crescimento inicial desacelerou, reverteu parcialmente com atuação do Garbage Collector e estabilizou em 208,13 MB; não houve tendência de crescimento linear contínuo.

---

### E. Série Temporal de CPU (PROFILE)

- **Idle Inicial**: Pico transitório de 90,3% durante bootstrap de threads, estabilizando rapidamente em < 2% em repouso.
- **Durante Scroll Contínuo**: Amostras coletadas de 74,1%, 73,3%, 63,3% e 61,2% durante processamento de gestos e animação da listagem.
- **Durante Navegação / Transição de Rotas**: 86,6% pontuais durante a montagem da nova rota.
- **Após Retorno a Idle**: Estabilizado em repouso (< 2% contínuo).

---

### F. Backend: Auditoria do Harness de Carga

- **Classificação**: **`HARNESS SINTÉTICO`**.
- **Justificativa**: O `Q8PerformanceServer` foi implementado como um servidor HTTP direto em Java (`HttpServer` + Jackson + 200 threads) para responder aos contratos da API móvel em ambiente local isolado. O tráfego não atravessa Spring Boot, DispatcherServlet, Tomcat nem filtros de segurança.
- **Métricas do Harness Local**:
  - *Baseline*: 107 RPS, p50 0,58 ms, p95 1,99 ms (0,00% erro).
  - *Load (50 VUs)*: 3.285 RPS, p95 1,13 ms (0,00% erro).
  - *Stress (200 VUs)*: 21.984 RPS pico, 1,09 milhão de requisições, p95 2,15 ms (0,00% erro).
  - *Spike (5 → 100 VUs)*: 11.483 RPS, p95 0,99 ms, absorção imediata.
  - *Soak (60s)*: 82.452 requisições, heap estável (165 MB → 159 MB). **Não foi observada tendência de leak durante a janela de 60s**.
- **Ponto de Limite**: **`LIMITE NÃO DETERMINADO NO AMBIENTE DISPONÍVEL`** (o harness local permaneceu estável até a carga máxima aplicada de 200 VUs).
- **Ressalva Formal**: Criado o **`RISCO-Q8-002`** documentando que a capacidade real do Spring Boot e de produção não foi inferida do harness.

---

### G. Auditoria de Checks k6 (Payload Integrity)

- **`q8_baseline.js`**: Valida `status === 200` em todos os endpoints e `body.includes('noticia-1')` no endpoint de notícias.
- **`q8_load.js`, `q8_stress.js`, `q8_spike.js`, `q8_soak.js`**: Validam **exclusivamente `status === 200`**.
- **Ressalva Documental**: Não houve validação profunda de integridade estrutural/schema JSON sob carga extrema; confirma-se estritamente que 100% das requisições responderam com sucesso HTTP 200.

---

### H. CPU do Host e p99

- **CPU do Host**: Registrado como **`CPU HOST NÃO COLETADA DE FORMA DETERMINÍSTICA`** (valores estimados removidos).
- **p99**: O summary padrão emitido pelo k6 reporta p90 e p95; percentuais p99 foram removidos por ausência de fonte bruta determinística.

---

## 4. Matriz Quantitativa Revalidada Q8-R01

- **Total de Cenários Avaliados**: 14
- **PASSOU**: **9** (Q8-MAT-01 Baseline, Q8-MAT-03 Stress Harness, Q8-MAT-04 Spike, Q8-MAT-05 Soak 60s, Q8-MAT-06 Recuperação, Q8-MAT-07 Cold Start Profile, Q8-MAT-08 Warm Start Profile, Q8-MAT-09 Frames/Jank Profile, Q8-MAT-11 Memória Temporal Profile)
- **PARCIAL**: **4** (Q8-MAT-02 Load vs Stack Real, Q8-MAT-12 Concorrência SQLite, Q8-MAT-13 Imagens, Q8-MAT-14 PDF Streaming)
- **SATURA**: **0** (Limite não atingido no ambiente disponível)
- **N/A**: **1** (Q8-MAT-10 Soak Corporativo de Longo Prazo — não aplicável ao ambiente local)
- **DEGRADA**: 0
- **BLOQUEADO**: 0
- **Falhas Críticas / Bloqueios**: 0

---

## 5. Registro de Riscos e Harness Bug

| Identificador | Categoria | Descrição |
| :--- | :--- | :--- |
| **`RISCO-Q8-001`** | Risco Arquitetural | **Capacidade de produção não aferida**: Por regra mandatória de segurança, nenhuma carga foi gerada contra a infraestrutura de produção (`https://aplicativo-api.mppb.mp.br`) ou dependências externas reais. |
| **`RISCO-Q8-002`** | Risco Arquitetural | **Representatividade do harness de carga**: O teste de carga foi executado sobre o harness sintético local `Q8PerformanceServer`, e não sobre a stack Spring Boot completa do `mobile-service`. Os valores de 22k RPS não podem ser extrapolados para a aplicação real. |
| **`BUG-Q8-HARNESS-001`** | Bug de Infraestrutura | **Falha de parsing no coletor de memória PowerShell**: Uso indevido de `$Matches` em `$array -match regex` gerou métrica absurda de `0.12 MB`. Corrigido deterministicamente com `Select-String` e validação `> 50 MB`. Sem impacto no aplicativo. |

---

## 6. Gates de Regressão Automatizada

- **Flutter Frontend (`app_mppb_flutter`)**:
  - `flutter analyze`: **0 issues** (`No issues found!`).
  - `flutter test`: **187/187 testes passando**.
  - `pubspec.yaml`: alteração preexistente `+69 → +72` estritamente preservada uncommitted.
- **Backend REST API (`spring-boot/restapi`)**:
  - `mvn test`: **153/153 testes passando** (11 restapi-common + 142 mobile-service).
  - `mvn package -DskipTests`: **BUILD SUCCESS**.

---

## 7. Conclusão Final e Diretriz de Parada

A rodada **Q8-R01** sanou integralmente as falhas metodológicas apontadas pela auditoria. Todas as métricas apresentadas representam medições reais, auditadas e comprovadas no hardware físico do Samsung Galaxy A52 (em modo **PROFILE**) e no harness controlado local.

Declaração de fechamento:
**Q8 CONCLUÍDA — PERFORMANCE DO CLIENTE FLUTTER VALIDADA EM DISPOSITIVO FÍSICO E BENCHMARKS DE CARGA, STRESS, SPIKE E SOAK VALIDADOS NO HARNESS SINTÉTICO, MANTIDAS AS RESSALVAS DE CAPACIDADE DA STACK SPRING BOOT REAL E DO AMBIENTE DE PRODUÇÃO.**

Diretriz estrita:
- Nenhum commit realizado.
- Nenhum push realizado.
- Nenhum merge realizado.
- **Q9 NÃO INICIADA**.
