# Evidência Q8 — Flutter: Performance em Dispositivo Físico Android (Q8-T08 a Q8-T14)

Data da Bateria Inicial: 2026-09-30  
Data da Revalidação Q8-R01: 2026-09-30  
Branch: `qualidade/q8-performance-carga`  
Dispositivo Físico: Samsung Galaxy A52 (`SM-A525M`)  
Arquitetura: `arm64-v8a`  
Sistema Operacional: Android 14 (API 34)  
Conexão: USB Físico via ADB (`RX8RC09H70X`)  
Pacote: `br.mp.mppbapp.app.homolog`  
Modo de Compilação: **PROFILE** (Obrigatório conforme Q8-R01)  
APK Efetivamente Instalado: `build/app/outputs/flutter-apk/app-homolog-profile.apk` (96,4 MB / 101.111.922 bytes)  
Endpoint Dart-Define: `https://aplicativo-mppb-homolog.mppb.mp.br`  

---

## 1. Histórico Metodológico (Q8 vs Q8-R01)

Na rodada inicial da Q8, a auditoria identificou falhas metodológicas:
1. **Build Flutter errada**: Foi gerada a build profile, mas instalado acidentalmente o APK debug. As medições de cold start, warm start, CPU, memória e frames foram invalidadas.
2. **Coletor de memória**: Falha no parser PowerShell de regex reutilizando capture groups de `$Matches` do loop anterior gerando o valor absurdo de `0.12 MB`. Registrado como `BUG-Q8-HARNESS-001`.
3. **Cold Start**: Presença de amostra com `0 ms` na amostragem original.
4. **Gfxinfo**: Registro de 0 frames rendered / 0 jank frames decorrente do uso de `FlutterSurfaceView` (que renderiza via Vulkan/OpenGL diretamente ao SurfaceFlinger sem passar pela HWUI de Views Android).
5. **Memória**: Apenas baseline e 5 ciclos, sem comprovar estabilização temporal.

Na rodada **Q8-R01**, todas as medições foram refeitas obrigatoriamente sobre **PROFILE** no hardware físico do Samsung Galaxy A52.

---

## 2. Startup: Cold Start e Warm Start (Q8-T08)

Medições realizadas em **PROFILE** via `am start -W -S` (Cold Start com `am force-stop` prévio) e retomada de background (Warm Start via `input keyevent 3` / HOME). Todas as amostras foram validadas como `> 0 ms`.

### A. Cold Start (5 amostras válidas em PROFILE)

| Amostra | Tempo Observado | Status |
| :---: | :---: | :--- |
| **Run 1** | 1.970 ms | Válido (>0) |
| **Run 2** | 1.981 ms | Válido (>0) |
| **Run 3** | 1.897 ms | Válido (>0) |
| **Run 4** | 1.939 ms | Válido (>0) |
| **Run 5** | 1.897 ms | Válido (>0) |
| **MEDIANA OBSERVADA** | **1.939 ms (~1,94 s)** | **Mediana calculada exclusivamente sobre as 5 amostras válidas** |

*Observação*: Zero amostras com 0 ms. Não há SLA institucional formal fixando limite; registra-se a mediana observada de 1.939 ms em hardware Samsung Galaxy A52 (Snapdragon 720G) em modo PROFILE.

### B. Warm Start (5 amostras válidas em PROFILE)

| Amostra | Tempo Observado | Status |
| :---: | :---: | :--- |
| **Run 1** | 139 ms | Válido (>0) |
| **Run 2** | 124 ms | Válido (>0) |
| **Run 3** | 93 ms | Válido (>0) |
| **Run 4** | 107 ms | Válido (>0) |
| **Run 5** | 92 ms | Válido (>0) |
| **MEDIANA OBSERVADA** | **107 ms (~0,11 s)** | **Mediana observada de retomada em PROFILE** |

---

## 3. Fluidez Visual, Frames e Jank (Q8-T11)

### A. Metodologia de Coleta
O Flutter utiliza `io.flutter.embedding.android.FlutterSurfaceView` com pipeline C++ Impeller (Vulkan/OpenGL). O `dumpsys gfxinfo` do Android HWUI não contabiliza frames renderizados diretamente na superfície BLAST. Para aferir frames reais exibidos na tela física com precisão de nanossegundos, utilizou-se o coletor de latência do **SurfaceFlinger** na camada:
`SurfaceView[br.mp.mppbapp.app.homolog/br.mp.mppbapp.app.MainActivity]@0(BLAST)`

O buffer foi resetado com `dumpsys SurfaceFlinger --latency-clear` imediatamente antes da execução do cenário.

### B. Cenário Executado
1. **Home**: estabilização inicial.
2. **Scroll na Home**: 4 ciclos de swipe vertical.
3. **Navegação para Notícias**: toque no card de notícias e carregamento da listagem.
4. **Scroll contínuo em Notícias**: 6 ciclos de swipe vertical contínuo na listagem.
5. **Retorno**: comando de voltar à Home.

### C. Métricas de Frames Observadas

| Métrica | Valor Observado | Detalhe Técnico |
| :--- | :---: | :--- |
| **Total de Frames Analisados** | **125 frames** | Amostras reais registradas pelo SurfaceFlinger (> 0) |
| **Taxa de Atualização do Display** | **11,11 ms (~90 Hz)** | Frequência de varredura nativa do Galaxy A52 |
| **Mediana de Frame Duration** | **11,11 ms** | Alinhamento nominal com o vsync de 90 Hz |
| **Percentil 90 (p90)** | **11,18 ms** | Variação residual de 0,07 ms |
| **Percentil 95 (p95)** | **11,19 ms** | Variação residual de 0,08 ms |
| **Máxima Frame Duration** | **11,40 ms** | Menos de 0,3 ms acima do vsync nominal de 11,11 ms |
| **Frames > 16,67 ms (Orçamento 60 Hz)** | **0 / 125 (0,0%)** | 100% dos frames dentro do orçamento padrão de 60 FPS |
| **Frames > 11,11 ms (Orçamento Estrito 90 Hz)** | **56 / 125 (44,8%)** | Oscilação microscópica entre 11,11 e 11,40 ms |
| **Conclusão de Jank** | **SEM JANK RELEVANTE OBSERVADO** | Nenhum stuttering perceptível; 0 frames acima de 16,67 ms |

---

## 4. Análise Temporal de Memória e Avaliação de Leak (Q8-T11 e Q8-T12)

### A. Série Temporal em PROFILE (`dumpsys meminfo`)

Para comprovar estabilização e ausência de vazamento progressivo de memória, foi realizada amostragem em 5 marcos temporais com a correção do coletor PowerShell (`BUG-Q8-HARNESS-001` corrigido; validação determinística `Total PSS > 50 MB`):

| Checkpoint | Evento Executado | Total PSS | Variação vs M0 |
| :--- | :--- | :---: | :---: |
| **M0** | Home inicial estabilizada | **203,06 MB** | — |
| **M1** | Após 5 ciclos completos (Home ↔ Notícias ↔ Diário) | **212,69 MB** | +9,63 MB |
| **M2** | Após 10 ciclos completos | **210,91 MB** | +7,85 MB (-1,78 MB vs M1) |
| **M3** | Após 15 ciclos completos | **208,13 MB** | +5,07 MB (-2,78 MB vs M2) |
| **M4** | Retorno à Home + repouso (idle 8s) | **208,13 MB** | +5,07 MB (estável vs M3) |

### B. Avaliação de Tendência e Critério de Leak
- **Comportamento observado**: A alocação subiu inicialmente de 203,06 MB para 212,69 MB (+9,63 MB) nos primeiros 5 ciclos. A partir do ciclo 10 (M2) e ciclo 15 (M3), o consumo desacelerou e reduziu para 208,13 MB após atuação do Garbage Collector do runtime Dart.
- **Pós-idle (M4)**: Permaneceu estável em 208,13 MB.
- **Delta total (M4 - M0)**: **+5,07 MB**, variação compatível com cache/alocação de runtime.
- **Conclusão**: **SEM EVIDÊNCIA DE LEAK**. O crescimento desacelerou, reverteu parcialmente e estabilizou; não houve tendência de crescimento linear contínuo.

---

## 5. Série Temporal de CPU (PROFILE)

Em vez de snapshot isolado de pico, registrou-se a série temporal por meio do comando `top -b -n 1` filtrando o processo da aplicação:

1. **Bootstrap / Inicialização**: Registro transitório de pico (90,3%) durante inicialização do processo e vinculação de threads, estabilizando rapidamente em repouso.
2. **Durante Scroll Contínuo na Home**: Séries de 74,1%, 73,3%, 63,3% e 61,2% de CPU durante os eventos ininterruptos de toque na tela e rolagem de lista.
3. **Durante Navegação / Mudança de Rota**: 86,6% pontuais na transição de telas e montagem de nova árvore de widgets.
4. **Após Retorno ao Repouso (Idle)**: Redução progressiva para < 2% de uso contínuo de CPU, sem processos em background consumindo recursos de forma indevida.

*Nota*: Não se atribui pico a causas não comprovadas como JIT de Dart ou compilação de shaders sem telemetria interna detalhada. Os picos são pontuais e restritos a momentos de processamento de entrada de usuário ou transição de tela.

---

## 6. Manipulação de Imagens e Documentos/PDF (Q8-T13 e Q8-T14)

### A. Imagens (Q8-T13) — Classificação: PARCIAL
- **Cenário Executado**: A listagem de notícias com cards contendo imagens remotas foi rolada continuamente sob monitoramento de frame timing e memória.
- **Resultado Observado**: Nenhuma degradação de frame rate foi detectada durante a exibição das imagens (mediana de 11,11 ms de frame duration preservada) e a memória permaneceu estável (208 MB a 212 MB).
- **Ressalva Técnica**: Embora a arquitetura utilize `cached_network_image` e o comportamento em tela tenha sido fluido, o impacto isolado de decodificação de imagem na GPU/CPU não pôde ser desacoplado do pipeline global de renderização no ambiente de teste disponível.
- **Classificação**: **PARCIAL**.

### B. PDF e Streaming (Q8-T14) — Classificação: PARCIAL
- **Avaliação Arquitetural**: O código-fonte implementa streaming direto via Dio para persistência temporária local, evitando acumulação de buffers volumosos na memória heap do Dart.
- **Ressalva Técnica**: Não há massa de dados de teste ou PDF corporativo seguro disponível para download de carga sem acionar sistemas externos de produção/autenticação.
- **Classificação**: **PARCIAL — ARQUITETURA DE STREAMING VERIFICADA, IMPACTO RUNTIME NÃO MEDIDO**.

---

## 7. Resumo da Performance Flutter no Escopo Q8-R01

- **Cold Start (Profile)**: Mediana observada de 1.939 ms (5/5 amostras válidas > 0).
- **Warm Start (Profile)**: Mediana observada de 107 ms (5/5 amostras válidas > 0).
- **Frames e Fluidez (Profile)**: 125 frames analisados; 0% frames > 16,67 ms (60 FPS); máxima de 11,40 ms. Sem jank relevante observado.
- **Memória (Profile)**: M0 (203 MB) → M1 (212 MB) → M2 (210 MB) → M3 (208 MB) → M4 (208 MB). Ausência de tendência linear de leak; estabilização comprovada.
- **CPU (Profile)**: Picos transitórios durante interações ativas (61% a 86%) e retorno estável a <2% em repouso.
