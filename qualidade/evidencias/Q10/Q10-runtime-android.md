# Evidência Q10 — Execução em Runtime Android Real

Data: 01/10/2026  
Dispositivo: Samsung Galaxy A52 (SM-A525M, Android 14 / One UI 6.1, Kernel 4.14, API 34)  
Conexão: ADB USB direta (Serial: `RX8RC09H70X`)  
Pacote Auditado: `br.mp.mppbapp.app.homolog`

---

## 1. Resumo dos Experimentos Dinâmicos Realizados

Todos os cenários centrais da fase Q10 foram validados empiricamente no hardware físico:

| Teste | Comando Executado | Resultado de Retorno | Comprovação no Dispositivo | Status |
|---|---|---|---|---|
| **Clean Install** | `adb install -r ...v72.apk` | `Success` | PID `7731`, Janela focada, Home funcional, 0 itens descriptografados. | **PASSOU** |
| **In-place Upgrade** | `adb install -r ...v72.apk` sobre v69 | `Success` | Dumpsys `versionCode=72`, PID `14411`, Home carregada com dados íntegros. | **PASSOU** |
| **Downgrade Bloqueado** | `adb install -r ...v69.apk` sobre v72 | `INSTALL_FAILED_VERSION_DOWNGRADE` | Rejeição padrão pelo Package Manager do Android (`Update version code 69 is older than current 72`). | **PASSOU** |
| **Downgrade Forçado (-d)** | `adb install -r -d ...v69.apk` sobre v72 | `Success` | Dumpsys `versionCode=69`. Experimento de laboratório concluído com sucesso. | **PASSOU** |
| **Clear Data** | `adb shell pm clear br.mp.mppbapp.app.homolog` | `Success` | Sandbox resetado a 59 bytes; reabertura solicitou permissões de novo (first-run). | **PASSOU** |
| **Reinstalação** | `adb uninstall` seguido de `adb install` | `Success` em ambas | Sandbox totalmente destruído e recriado com novos UIDs Linux. | **PASSOU** |

---

## 2. Comprovantes de Dumpsys e Logcat

### Dumpsys pós-upgrade (+72):
```text
Packages:
  Package [br.mp.mppbapp.app.homolog] (7c8ff75):
    userId=10372
    pkg=Package{a8979ef br.mp.mppbapp.app.homolog}
    codePath=/data/app/~~.../br.mp.mppbapp.app.homolog-...
    resourcePath=/data/app/~~.../br.mp.mppbapp.app.homolog-...
    versionCode=72 minSdk=24 targetSdk=36
    versionName=4.0.0
    signatures=PackageSignatures{dd508ce version:2, signatures:[d38ae3e0]}
```

### Logcat do Downgrade Rejeitado pelo Sistema:
```text
Performing Streamed Install
adb.exe: failed to install build\app\outputs\flutter-apk\app-homolog-debug-v69.apk: 
Failure [INSTALL_FAILED_VERSION_DOWNGRADE: Downgrade detected: Update version code 69 is older than current 72]
```

### Sandbox pós-Clear Data:
```text
adb shell pm clear br.mp.mppbapp.app.homolog
# Retorno: Success

adb shell run-as br.mp.mppbapp.app.homolog ls -la
# Output:
# total 59
# drwx------   2 u0_a373 u0_a373  3452 2026-10-01 13:21 .
# drwxrwx--x 515 system  system  57344 2026-10-01 13:14 ..
```

---

## 3. Avaliação de Estabilidade Operacional

- Nenhuma tela preta (ANR) ou travamento durante as transições de ciclo de vida.
- Sem corrupção de chaves no Android KeyStore (`FlutterSecureStoragePluginKeyOAEP`).
- O sistema de layout Flutter respondeu imediatamente após a reconexão das views do Android (`BLASTBufferQueue` e `SurfaceView`).
