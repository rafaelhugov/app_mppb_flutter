# Evidência Q10-T01 — Instalação Limpa (Clean Install)

Data: 01/10/2026  
Dispositivo: Samsung Galaxy A52 (SM-A525M, Android 14 / One UI 6.1, API 34)  
Artefato Instalado: `app-homolog-debug-v72.apk` (`version: 4.0.0+72`)  
Endpoint configurado: `--dart-define=API_URL=https://aplicativo-mppb-homolog.mppb.mp.br`

---

## 1. Procedimento Executado

1. Desinstalação prévia do pacote de homologação para garantir ambiente estéril:
   ```powershell
   adb uninstall br.mp.mppbapp.app.homolog
   # Retorno: Success
   ```

2. Instalação limpa da versão candidata v72:
   ```powershell
   adb install -r build\app\outputs\flutter-apk\app-homolog-debug-v72.apk
   # Retorno: Performing Streamed Install -> Success
   ```

3. Primeira abertura (Cold Start):
   ```powershell
   adb shell am start -W -n br.mp.mppbapp.app.homolog/br.mp.mppbapp.app.MainActivity
   ```

---

## 2. Resultados e Métricas

- **Status da Inicialização**: `Status: ok`
- **LaunchState**: `COLD`
- **TotalTime**: `5989 ms`
- **Processo Criado**: PID `7731`
- **Janela em Foco**: `mCurrentFocus=Window{9140aaf u0 br.mp.mppbapp.app.homolog/br.mp.mppbapp.app.MainActivity}`

### Comportamento do Logcat:
```text
FlutterSecureStorage: No data found in EncryptedSharedPreferences.
FlutterSecureStorage: Key mismatch detected during cipher initialization: Algorithm changed detected
FlutterSecureStorage: migrateOnAlgorithmChange is enabled. Attempting data migration...
FlutterSecureStorage: Starting data migration from saved to current cipher algorithms...
keystore2: In generate_key. Some("br.mp.mppbapp.app.homolog.FlutterSecureStoragePluginKey")
FlutterSecureStorage: Step 1/6: Initializing saved cipher...
FlutterSecureStorage: Step 2/6: Decrypting all data with saved cipher...
FlutterSecureStorage: Successfully decrypted 0 items with saved cipher
FlutterSecureStorage: Step 3/6: Deleting old RSA key from Android KeyStore...
FlutterSecureStorage: Step 4/6: Updating algorithm markers to current...
FlutterSecureStorage: Step 5/6: Initializing current cipher with fresh AES key...
keystore2: In generate_key. Some("br.mp.mppbapp.app.homolog.FlutterSecureStoragePluginKeyOAEP")
FlutterSecureStorage: Step 6/6: No data to migrate, continuing...
FlutterSecureStorage: Non-biometric migration completed successfully! Migrated 0 items.
FlutterSecureStorage: Data migration completed successfully!
ViewRootImpl@78af1e5[MainActivity]: reportDrawFinished seqId=0
```

---

## 3. Verificações de Integridade

- **Instalação sem erro**: Sim (`Success`).
- **App abre**: Sim.
- **Nenhuma exceção fatal**: Confirmado (zero crashs no logcat).
- **Home pública funcional**: Confirmado (Serviços ao Cidadão e Notícias renderizados com sucesso).
- **Storage inicial vazio/coerente**: Confirmado (0 itens descriptografados; chaves novas criadas no KeyStore).
- **Nenhuma sessão fantasma**: Confirmado (botão "Entrar" exibido, `auth_token` nulo).
- **Dependência de versão anterior**: Nenhuma dependência detectada.
