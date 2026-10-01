# Evidência Q8 — Auditoria de Runtime em Android Físico (Q8-R01)

Data: 2026-09-30  
Branch: `qualidade/q8-performance-carga`  
Dispositivo Físico: Samsung Galaxy A52 (`SM-A525M`)  
Serial ADB: `RX8RC09H70X`  
Versão do Android: Android 14 (API 34)  
Arquitetura da CPU: `arm64-v8a` (Qualcomm Snapdragon 720G)  
Memória RAM Total: 6.0 GB  

---

## 1. Integridade do Processo e Instalação (PROFILE)

- **Pacote**: `br.mp.mppbapp.app.homolog`
- **Modo de Compilação**: **PROFILE** (Obrigatório conforme Q8-R01)
- **Instalação**: APK homolog profile (`build/app/outputs/flutter-apk/app-homolog-profile.apk`, 96,4 MB / 101.111.922 bytes) transferido e instalado via `adb install -r -d` (`Performing Streamed Install - Success`).
- **PID em Execução**: 11134
- **UID**: `u0_a362`
- **Endpoint Dart-Define**: `https://aplicativo-mppb-homolog.mppb.mp.br`

---

## 2. Auditoria de Estabilidade e Logcat do Sistema

Durante toda a bateria de testes de performance, navegação repetida, scrolls intensivos e transições de tela no dispositivo físico em modo PROFILE, o logcat foi monitorado para detecção de anomalias:

| Tipo de Anomalia | Ocorrências | Status |
| :--- | :---: | :---: |
| **`FATAL EXCEPTION`** | **0** | **LIMPO** |
| **`AndroidRuntime` Crash** | **0** | **LIMPO** |
| **`SIGSEGV` / Falha de Segmentação Nativa** | **0** | **LIMPO** |
| **`OutOfMemoryError` (OOM)** | **0** | **LIMPO** |
| **`Application Not Responding` (ANR)** | **0** | **LIMPO** |
| **`PlatformException` Não Tratada** | **0** | **LIMPO** |
| **Exceções de Renderização Flutter (Red Screen)** | **0** | **LIMPO** |
| **Travamento ou Reinício do Daemon ADB** | **0** | **ESTÁVEL** |

---

## 3. Gestão Térmica e de Bateria

- **Estado de Conexão**: Conexão USB física direta ao host Windows via cabo com debouncing.
- **Temperatura do Dispositivo**: Operação dentro dos parâmetros normais, sem throttling térmico detectado pelo sistema operacional.
- **Drenagem de Bateria em Repouso**: Processo consome < 2% de CPU em background/repouso, com threads de renderização suspensas adequadamente quando o app não está sob toque ou animação.

---

## 4. Conclusão do Runtime Android

O ambiente de execução no hardware físico Samsung Galaxy A52 permaneceu 100% íntegro, sem falhas de sistema, vazamento crítico ou interrupções de runtime durante toda a execução da rodada Q8-R01 em modo PROFILE.
