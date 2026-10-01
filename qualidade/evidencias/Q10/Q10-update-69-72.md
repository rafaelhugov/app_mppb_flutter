# Evidência Q10-T02 — Atualização In-Place (+69 → +72)

Data: 01/10/2026  
Dispositivo: Samsung Galaxy A52 (SM-A525M, Android 14 / One UI 6.1, API 34)  
Origem: Versão commitada `4.0.0+69` (SHA `8fcb889`)  
Destino: Versão candidata `4.0.0+72` (working tree local Q10)  
Endpoint: `https://aplicativo-mppb-homolog.mppb.mp.br`

---

## 1. Geração dos Artefatos Sem Adulteração de Histórico

Para garantir a geração fidedigna da versão base sem corromper o estado de trabalho local:
1. Foi utilizado um **git worktree temporário** (`..\app_mppb_flutter_q10_old`) apontando para o commit `8fcb889` (`version: 4.0.0+69`).
2. Compilou-se o APK base:
   ```powershell
   flutter build apk --debug --flavor homolog -t lib/main.dart --dart-define=API_URL=https://aplicativo-mppb-homolog.mppb.mp.br
   # Artefato gerado: app-homolog-debug-v69.apk (181.504.117 bytes)
   ```
3. No working tree principal (`qualidade/q10-instalacao-atualizacao-migracao`), compilou-se a versão candidata com `version: 4.0.0+72`:
   ```powershell
   flutter build apk --debug --flavor homolog -t lib/main.dart --dart-define=API_URL=https://aplicativo-mppb-homolog.mppb.mp.br
   # Artefato gerado: app-homolog-debug-v72.apk (220.343.957 bytes)
   ```
4. O worktree temporário foi imediatamente removido do Git após a extração do artefato.

---

## 2. Execução da Sequência de Upgrade no Android Real

1. **Instalação e Execução da Versão +69**:
   ```powershell
   adb uninstall br.mp.mppbapp.app.homolog
   adb install build\app\outputs\flutter-apk\app-homolog-debug-v69.apk
   # Performing Streamed Install -> Success
   adb shell am start -W -n br.mp.mppbapp.app.homolog/br.mp.mppbapp.app.MainActivity
   ```
   Verificação do pacote via `dumpsys`:
   ```text
   versionCode=69 minSdk=24 targetSdk=36
   versionName=4.0.0
   ```
   Arquivos gerados no sandbox inspecionados via `run-as`:
   - `shared_prefs/FlutterSecureStorage.xml`
   - `shared_prefs/FlutterSecureKeyStorage.xml`
   - `shared_prefs/com.google.android.gms.appid.xml`
   - `files/flutter_callback_cache.json`
   - `files/Manrope_*.ttf` (fontes cacheadas)

2. **Aplicação do Upgrade In-Place via ADB**:
   ```powershell
   adb install -r build\app\outputs\flutter-apk\app-homolog-debug-v72.apk
   # Output:
   # Performing Streamed Install
   # Success
   ```

3. **Verificação Imediata da Nova Versão**:
   ```powershell
   adb shell dumpsys package br.mp.mppbapp.app.homolog | Select-String "versionCode|versionName"
   # Output:
   # versionCode=72 minSdk=24 targetSdk=36
   # versionName=4.0.0
   ```

4. **Inicialização da Versão +72 Atualizada**:
   ```powershell
   adb shell am start -W -n br.mp.mppbapp.app.homolog/br.mp.mppbapp.app.MainActivity
   # Output:
   # Status: ok
   # LaunchState: COLD
   # Activity: br.mp.mppbapp.app.homolog/br.mp.mppbapp.app.MainActivity
   # TotalTime: 8616
   # Complete
   ```
   Processo criado: PID `14411`.

---

## 3. Avaliação de Falhas e Erros

- **Aceitação do Upgrade pelo Android**: Sim (`Success`).
- **Erros de Parsing / DTO**: Zero.
- **Erros de Migração / KeyStore**: Zero. Chaves criptográficas existentes foram reutilizadas transparentemente.
- **ClassCastException / SQLite Migration Error**: Nenhum. O app não possui SQLite e o modelo de dados é retrocompatível.
- **UI / Telas**: A tela inicial pública ("Serviços ao Cidadão", "Notícias") renderizou de forma íntegra e sem anomalias visuais.
