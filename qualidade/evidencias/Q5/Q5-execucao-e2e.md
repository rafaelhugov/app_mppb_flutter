# Q5 - Execucao E2E Android

Data: 2026-09-29  
Flavor: `homolog`  
API_URL: `https://aplicativo-mppb-homolog.mppb.mp.br`

## Automacao criada

Arquivo: `integration_test/q5_public_e2e_test.dart`

Arquivo corretivo Q5-R01: `integration_test/q5_smoke_home_e2e_test.dart`

Fluxo coberto:

1. Inicializar app real.
2. Validar Home publica.
3. Abrir Contatos pela grade publica.
4. Voltar para Home.
5. Abrir Noticias.
6. Validar lista/estado vazio/erro seguro.
7. Quando houver lista, abrir detalhe/modal de noticia e retornar.

## Comando E2E usado

```bash
flutter test integration_test/q5_public_e2e_test.dart -d emulator-5554 --flavor homolog --dart-define=API_URL=https://aplicativo-mppb-homolog.mppb.mp.br --dart-define=Q5_E2E_DISABLE_FCM=true
```

## Tentativas

| Tentativa | Device | Resultado | Observacao |
| --- | --- | --- | --- |
| 1 | Pixel_9, Android 17/API 37 | FALHOU | Dialogo nativo de permissao de notificacao bloqueou a arvore Flutter. Evidencia: `screenshots/q5-falha-primeira-execucao.png`. |
| 2 | Pixel_9, Android 17/API 37 | FALHOU | FCM foi desabilitado para E2E publico, mas o provider de navegacao push ainda instanciava FirebaseMessaging sem Firebase inicializado. Corrigido. |
| 3 | Pixel_9, Android 17/API 37 | PARCIAL | App alcancou Home/Contatos; ajuste de assert de textos duplicados e chaves estaveis aplicado. |
| 4 | Pixel_9, Android 17/API 37 | BLOQUEADO | Emulador saiu com `exit 139`; ADB perdeu o device durante cleanup (`device not found`). |
| 5 | Pixel_8, Android 16/API 36 | BLOQUEADO | Tentativa complementar tambem perdeu o device (`device offline`) e o processo do emulador encerrou com `exit 139`. |

## Q5-R01 - Estabilizacao

| Ambiente | Teste | Execucoes | Resultado | Classificacao |
| --- | --- | ---: | --- | --- |
| Pixel_8, Android 16/API 36 | Smoke minimo Home | 3 | 3 verdes | ESTAVEL |
| Pixel_8, Android 16/API 36 | Jornada publica completa | 1 | `adb: device offline` | BLOQUEADO |
| Pixel_9, Android 17/API 37 | Smoke minimo Home | 1 | 1 verde | PASSOU |
| Pixel_9, Android 17/API 37 | Jornada publica completa | 1 | `adb: device offline` | BLOQUEADO |

Comando smoke:

```bash
flutter test integration_test/q5_smoke_home_e2e_test.dart -d emulator-5554 --flavor homolog --dart-define=API_URL=https://aplicativo-mppb-homolog.mppb.mp.br --dart-define=Q5_E2E_DISABLE_FCM=true
```

Comando jornada publica:

```bash
flutter test integration_test/q5_public_e2e_test.dart -d emulator-5554 --flavor homolog --dart-define=API_URL=https://aplicativo-mppb-homolog.mppb.mp.br --dart-define=Q5_E2E_DISABLE_FCM=true
```

## Resultado Q5 E2E

Resultado: **BLOQUEADO POR INFRAESTRUTURA ANDROID/ADB**.

Nao houve aprovacao verde de jornada E2E Android publica completa. O smoke minimo demonstrou que o harness consegue iniciar o app e encontrar a Home de forma estavel no Pixel_8, mas a jornada publica completa perdeu o device nos dois AVDs testados.

Nao foi identificado novo bug real do App MPPB. O bloqueio observado foi perda/queda do emulador/ADB.
