# Q2 - Runtime Android

Data: 2026-09-28
Branch: `qualidade/q2-testes-componentes`

## Tentativas

1. `Pixel_8`
   - Boot concluido e reconhecido inicialmente como `emulator-5554`.
   - App instalado/executado com `flutter run --flavor homolog -t lib/main.dart -d emulator-5554`.
   - Capturas geradas:
     - `screenshots/android-home.png`
     - `screenshots/android-home-publica.png`
     - `screenshots/android-home-publica-apos-espera.png`
   - Resultado: Home publica carregou apos negar permissao de notificacao. O emulador encerrou depois com `ERROR | bad color buffer handle 328` e exit code 139, causando perda de conexao ADB.

2. `Pixel_9`
   - Iniciado com `-no-window -no-audio -no-snapshot -gpu swiftshader_indirect`.
   - Reconhecido no fechamento como:
     - `adb devices`: `emulator-5554 device`
     - `flutter devices`: `sdk gphone16k x86 64`, Android 17 API 37.
   - `adb shell getprop sys.boot_completed`: `1`.
   - Logcat coletado em `android-logcat.txt`.

## Resultado

Runtime Android parcialmente validado na Q2:
- Instalacao e abertura do app homolog em Android foram executadas.
- Home publica apareceu em screenshot apos espera.
- Navegacao profunda autenticada/publica adicional ficou limitada pela queda do Pixel_8; Pixel_9 permaneceu disponivel ao final para coleta de dispositivos/logcat.

