# Q4 - Runtime Android

Data: 2026-09-28

## Ambiente

- AVDs disponiveis: `Pixel_8`, `Pixel_9`
- AVD usado: `Pixel_9`
- Dispositivo: `emulator-5554`
- Android: `sdk gphone16k x86 64`, Android 17 API 37
- Modo: headless, sem snapshot, GPU `swiftshader_indirect`

## Execucao

Comandos principais:

```bash
emulator -avd Pixel_9 -no-window -no-audio -no-snapshot -gpu swiftshader_indirect
flutter run -d emulator-5554 --debug --flavor homolog -t lib/main.dart
adb exec-out screencap -p > qualidade/evidencias/Q4/screenshots/android-q4-home.png
adb emu kill
```

Resultado:

- APK homolog debug compilado, instalado e iniciado no emulador.
- Flutter indicou uso do backend Impeller/OpenGLES.
- VM Service foi aberto durante o smoke.
- Screenshot gerada em `qualidade/evidencias/Q4/screenshots/android-q4-home.png`.
- Nenhum `FATAL EXCEPTION`, `AndroidRuntime` ou `SIGSEGV` associado ao app homolog foi observado na amostra de log coletada.

## Limites

- Smoke limitado a inicializacao/home do app.
- Fluxos autenticados nao foram executados por ausencia de credencial e massa autorizada.
- Nao foram realizados testes E2E nem navegacao automatizada de Q5.

## Observacao de desligamento

No encerramento do emulador apareceu aviso nativo `bad color buffer handle 193`. Ele ocorreu durante shutdown do emulador, apos o smoke do app, e nao foi classificado como crash da aplicacao.
