# Q5 - Runtime Android

Data: 2026-09-29

Atualizacao Q5-R01: estabilizacao do runtime Android e fechamento das jornadas E2E publicas.

## Devices usados

| AVD | Device id | Android | Resultado |
| --- | --- | --- | --- |
| Dispositivo fisico | N/A | N/A | Nao detectado por `adb devices`/`flutter devices`. |
| Pixel_8 | `emulator-5554` | Android 16/API 36 | Smoke minimo passou 3/3; jornada publica completa perdeu ADB com `device offline` e o emulador desapareceu. |
| Pixel_9 | `emulator-5554` | Android 17/API 37 | Smoke minimo passou 1/1; jornada publica completa perdeu ADB com `device offline` e o emulador desapareceu. |

## System images

| API | Imagem | Uso |
| --- | --- | --- |
| Android 36.1 | `google_apis_playstore/x86_64` | Priorizada por ser anterior a API 37. |
| Android 37.1 | `google_apis_playstore_ps16k/x86_64` | Tentativa comparativa. |

Nao foi instalada system image nova e nenhuma configuracao global do Android SDK foi alterada.

## Evidencias preservadas

| Arquivo | Conteudo |
| --- | --- |
| `runtime/tentativas-resumo.md` | Resumo Q5-R01 com ambiente, testes e classificacao. |
| `runtime/tentativa-01-smoke-logcat.txt` | Logcat do smoke minimo Pixel_8, execucao 1. |
| `runtime/tentativa-02-smoke-logcat.txt` | Logcat do smoke minimo Pixel_8, execucao 2. |
| `runtime/tentativa-03-smoke-logcat.txt` | Logcat do smoke minimo Pixel_8, execucao 3. |
| `runtime/tentativa-04-publica-logcat.txt` | Resumo da falha da jornada publica Pixel_8; logcat bruto nao recuperado por perda do device. |
| `runtime/tentativa-05-pixel9-smoke-logcat.txt` | Logcat do smoke minimo Pixel_9. |
| `runtime/tentativa-06-pixel9-publica-falha.txt` | Resumo da falha da jornada publica Pixel_9; logcat bruto nao recuperado por perda do device. |
| `android-adb-devices.txt` | Captura de `adb devices` durante tentativa com Pixel_8. |
| `android-flutter-devices.txt` | Captura de `flutter devices` durante tentativa com Pixel_8. |
| `android-logcat-primeira-execucao.txt` | Log da tentativa bloqueada por permissao nativa de notificacao. |
| `android-logcat-falha-contatos.txt` | Log da tentativa posterior com fluxo publico parcial. |
| `screenshots/q5-falha-primeira-execucao.png` | Screenshot da primeira falha. |
| `screenshots/q5-falha-contatos.png` | Screenshot da falha posterior. |

## Classificacao Q5-R01

O harness minimo ficou **ESTAVEL** no Pixel_8, com 3 execucoes consecutivas verdes, e tambem passou no Pixel_9.

A jornada publica completa permaneceu **BLOQUEADA POR INFRAESTRUTURA ANDROID/ADB**: Pixel_8 e Pixel_9 perderam o device durante a execucao/finalizacao com `adb: device offline`, seguidos de `adb devices` vazio e `adb get-state` sem devices.

Nao ha aprovacao Q5 E2E enquanto a jornada publica completa nao finalizar verde e reproduzivel em device/emulador estavel.

## Atualizacao Q5-R02: Execução em Dispositivo Físico Real (Windows + USB)

Data: 2026-09-29

### 1. Novo Ambiente Físico
- **Host**: Windows 11 Físico
- **Dispositivo**: Samsung Galaxy A52 (`SM-A525M`), ID: `RX8RC09H70X`
- **Versão Android**: Android 14 (API Level 34, `arm64-v8a`)
- **Conexão**: USB Físico com Depuração USB ativa

### 2. Contraste: AVD Linux vs Dispositivo Físico Real
| Dimensão | AVD Linux (VM) | Dispositivo Físico Real (Windows + USB) |
| :--- | :--- | :--- |
| **Estabilidade ADB** | Queda abrupta (`device offline`), desaparecimento do emulador (`exit 139`) | **100% estável** (5/5 ping pré-teste, mantido durante e após todas as baterias) |
| **Smoke E2E Mínimo** | 3/3 verdes no Pixel_8 (com instabilidade posterior) | **3/3 verdes consecutivos** no Samsung A52 sem qualquer instabilidade |
| **Jornada Pública E2E** | Interrompida por crash de qemu e perda do daemon ADB | Executada sem crash de app ou perda de ADB; falha isolada em asserção do harness |
| **Crashes da Aplicação** | Não diagnosticável devido ao crash do host QEMU | **0 crashes**, **0 ANRs**, logcat limpo de falhas nativas |

### 3. Evidências do Ambiente Windows Físico
- `windows/ambiente-windows.md`: Registro do setup e SDKs
- `windows/android-device.txt`: Propriedades e status do Galaxy A52
- `windows/flutter-devices.txt`: Listagem do Flutter detectando o dispositivo real
- `windows/smoke-e2e.md`: Registro das 3 execuções 100% verdes do smoke
- `windows/jornadas-publicas.md`: Análise da execução da jornada pública
- `windows/screenshots/`: Capturas de tela reais da Home, Contatos e Notícias

### 4. Classificação Consolidada de Runtime
A hipótese de incompatibilidade do harness ou de instabilidade geral do framework foi descartada. O hardware físico comprovou que o runtime Android e a comunicação ADB são plenamente viáveis e estáveis. O bloqueio verificado no Linux era puramente de infraestrutura da VM/QEMU.

### 5. Fechamento Q5-R02 — Correção e Gate 3/3 Verde
Com a correção da asserção de notícias (`Key('lista-noticias')`) e estabilização dos pumps no teste `q5_public_e2e_test.dart`, a bateria Gate 3/3 foi executada com 100% de sucesso (`3/3 PASS`), ADB 100% estável e zero falhas de runtime.

Classificação Formal: **BLOQUEIO LINUX/AVD/ADB SUPERADO**. O runtime Android e a suíte E2E pública estão plenamente validados em hardware físico real.
