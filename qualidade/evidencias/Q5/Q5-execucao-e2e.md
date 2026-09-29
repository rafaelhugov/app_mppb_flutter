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

## Tentativas Iniciais em Linux VM

| Tentativa | Device | Resultado | Observacao |
| --- | --- | --- | --- |
| 1 | Pixel_9, Android 17/API 37 | FALHOU | Dialogo nativo de permissao de notificacao bloqueou a arvore Flutter. |
| 2 | Pixel_9, Android 17/API 37 | FALHOU | FCM foi desabilitado para E2E publico, mas o provider de navegacao push ainda instanciava FirebaseMessaging sem Firebase inicializado. Corrigido. |
| 3 | Pixel_9, Android 17/API 37 | PARCIAL | App alcancou Home/Contatos; ajuste de assert de textos duplicados e chaves estaveis aplicado. |
| 4 | Pixel_9, Android 17/API 37 | BLOQUEADO | Emulador saiu com `exit 139`; ADB perdeu o device durante cleanup (`device not found`). |
| 5 | Pixel_8, Android 16/API 36 | BLOQUEADO | Tentativa complementar tambem perdeu o device (`device offline`) e o processo do emulador encerrou com `exit 139`. |

## Q5-R01 - Estabilizacao em Linux VM

| Ambiente | Teste | Execucoes | Resultado | Classificacao |
| --- | --- | ---: | --- | --- |
| Pixel_8, Android 16/API 36 | Smoke minimo Home | 3 | 3 verdes | ESTAVEL |
| Pixel_8, Android 16/API 36 | Jornada publica completa | 1 | `adb: device offline` | BLOQUEADO |
| Pixel_9, Android 17/API 37 | Smoke minimo Home | 1 | 1 verde | PASSOU |
| Pixel_9, Android 17/API 37 | Jornada publica completa | 1 | `adb: device offline` | BLOQUEADO |

---

## Q5-R02 - Execução no Ambiente Físico Windows + Samsung Galaxy A52

Data: 2026-09-29  
Dispositivo: Samsung Galaxy A52 (`SM-A525M`), Android 14 / API 34 (`RX8RC09H70X`) via USB física.

### 1. Bateria Oficial Gate 3/3 — Jornada Pública Principal
Após a correção da asserção do harness em `integration_test/q5_public_e2e_test.dart` (exigindo evidência positiva estrita com `Key('lista-noticias')` e `'Abrir'`, sem tolerar estados de erro de API como falso positivo):

```powershell
flutter test integration_test/q5_public_e2e_test.dart --flavor homolog -d RX8RC09H70X --dart-define=API_URL=https://aplicativo-mppb-homolog.mppb.mp.br --dart-define=Q5_E2E_DISABLE_FCM=true
```

| Execução | Teste / Jornada | Duração | Resultado do Runner | Estado ADB |
| :---: | :--- | :---: | :---: | :---: |
| **1** | Q5-E2E-PUB-01 (Home → Contatos → Home → Notícias → Home) | ~13s | **PASS** (`+1: All tests passed!`) | `device` |
| **2** | Q5-E2E-PUB-01 (Home → Contatos → Home → Notícias → Home) | ~12s | **PASS** (`+1: All tests passed!`) | `device` |
| **3** | Q5-E2E-PUB-01 (Home → Contatos → Home → Notícias → Home) | ~13s | **PASS** (`+1: All tests passed!`) | `device` |
| **Smoke** | `integration_test/q5_smoke_home_e2e_test.dart` | ~5s | **PASS** (`+1: All tests passed!`) | `device` |

### 2. Diagnóstico de Estabilidade
- ADB permaneceu 100% online (`device`).
- Zero crashes, zero ANRs, zero SIGSEGV, zero PlatformException.

### 3. Veredito Oficial Q5 E2E
**JORNADA PÚBLICA PRINCIPAL E2E VALIDADA EM ANDROID FÍSICO — 3/3 PASS**.
**E2E PÚBLICO EXECUTÁVEL DA Q5 VALIDADO**.
