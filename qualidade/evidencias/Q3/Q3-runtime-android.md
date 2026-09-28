# Q3 - Runtime Android

Data: 2026-09-28

## AVD

- AVD preferencial: `Pixel_9`.
- Device ID durante execucao: `emulator-5554`.
- Sistema: Android 17 API 37.
- Boot: concluido em 27350 ms.

## Smoke executado

- App homolog instalado via `flutter run --flavor homolog -t lib/main.dart -d emulator-5554`.
- Prompt de notificacao capturado.
- Permissao de notificacao negada.
- Home publica carregada e capturada em `screenshots/android-q3-home.png`.

## Limitacao

Ao tentar navegar para Noticias, o ADB retornou `device offline`. O processo do emulador encerrou com:

```text
ERROR | bad color buffer handle 291
exit code 139
```

O `flutter run` registrou `Lost connection to device`.

## Classificacao

Classificacao Q3 para o `exit 139`: FALHA NATIVA/EMULADOR GRAFICO.

Justificativa:
- A Home do app renderizou antes da queda.
- A queda ocorreu junto do processo do emulador, com `bad color buffer handle`.
- Nao houve evidencia de `FATAL EXCEPTION`, `AndroidRuntime`, erro de parsing JSON, `TypeError` ou `PlatformException` do app antes da perda do device.
- A mesma familia de falha ocorreu na Q2 (`bad color buffer handle`, exit 139).

Fluxos autenticados nao foram executados por ausencia de credenciais autorizadas fornecidas para a Q3.

