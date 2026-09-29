# Q5-R01 - Resumo das Tentativas Android

Data: 2026-09-29

## Sanity

- Branch Flutter: `qualidade/q5-e2e`.
- Dispositivo fisico Android: nao detectado por `adb devices`/`flutter devices`.
- AVDs disponiveis: `Pixel_8`, `Pixel_9`.
- System images instaladas: `android-36.1/google_apis_playstore/x86_64` e `android-37.1/google_apis_playstore_ps16k/x86_64`.
- Nenhuma imagem nova foi instalada.

## Tentativas

| Tentativa | Ambiente | Teste | Resultado | Evidencia |
| --- | --- | --- | --- | --- |
| 01 | Pixel_8, Android 16/API 36 | `q5_smoke_home_e2e_test.dart` | PASSOU | `tentativa-01-smoke-logcat.txt` |
| 02 | Pixel_8, Android 16/API 36 | `q5_smoke_home_e2e_test.dart` | PASSOU | `tentativa-02-smoke-logcat.txt` |
| 03 | Pixel_8, Android 16/API 36 | `q5_smoke_home_e2e_test.dart` | PASSOU | `tentativa-03-smoke-logcat.txt` |
| 04 | Pixel_8, Android 16/API 36 | `q5_public_e2e_test.dart` | BLOQUEADO | `tentativa-04-publica-logcat.txt`; `adb: device offline`; emulador desapareceu de `adb devices`. |
| 05 | Pixel_9, Android 17/API 37 | `q5_smoke_home_e2e_test.dart` | PASSOU | `tentativa-05-pixel9-smoke-logcat.txt` |
| 06 | Pixel_9, Android 17/API 37 | `q5_public_e2e_test.dart` | BLOQUEADO | `tentativa-06-pixel9-publica-falha.txt`; `adb: device offline`; emulador desapareceu de `adb devices`. |

## Classificacao

- Harness minimo: **ESTAVEL** em Pixel_8, 3/3 execucoes verdes.
- Jornada publica completa: **BLOQUEADA POR INFRAESTRUTURA ANDROID/ADB** em Pixel_8 e Pixel_9.
- App: nenhum novo bug real comprovado. Nao houve evidencia preservada de `FATAL EXCEPTION` do app; a falha observavel foi perda do device/emulador pelo ADB.
