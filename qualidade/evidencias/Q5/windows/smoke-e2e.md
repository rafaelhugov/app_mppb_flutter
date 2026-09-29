# Execução do Smoke E2E Mínimo — Q5 (Windows + Android Físico)

## 1. Identificação do Teste
- **Arquivo**: `integration_test/q5_smoke_home_e2e_test.dart`
- **Dispositivo**: Samsung Galaxy A52 (`RX8RC09H70X`)
- **Comando de Execução**:
  ```bash
  flutter test integration_test/q5_smoke_home_e2e_test.dart -d RX8RC09H70X --flavor homolog --dart-define=API_URL=https://aplicativo-mppb-homolog.mppb.mp.br --dart-define=Q5_E2E_DISABLE_FCM=true
  ```

## 2. Bateria de Estabilidade (3 Execuções Consecutivas)
| Execução | Status | Tempo de Execução | Resultado do Runner | Estado ADB Pós-Teste |
| :--- | :--- | :--- | :--- | :--- |
| **Execução 1** | **PASS** | ~39s | `+1: All tests passed!` | `device` (estável) |
| **Execução 2** | **PASS** | ~39s | `+1: All tests passed!` | `device` (estável) |
| **Execução 3** | **PASS** | ~39s | `+1: All tests passed!` | `device` (estável) |

## 3. Diagnóstico e Conclusão Técnica
1. **Infraestrutura**: A infraestrutura de testes ponta a ponta (`integration_test` oficial do Flutter) é plenamente suportada e executável no dispositivo físico Android 14 sob Windows.
2. **Causa Raiz no Linux**: A instabilidade observada no Linux decorria do emulador Android (QEMU/AVD) em ambiente de máquina virtual sem aceleração de hardware KVM aninhada estável, que causava crash do qemu e desligamento do adb daemon. No dispositivo físico conectado via USB, o ADB manteve estabilidade de 100% em todas as execuções.

## 4. Reexecução de Fechamento Q5-R02
- **Data**: 2026-09-29
- **Comando**: `flutter test integration_test/q5_smoke_home_e2e_test.dart --flavor homolog -d RX8RC09H70X`
- **Resultado**: `+1: All tests passed!` (~5s)
- **Estado ADB**: `device` (100% online)
- **Conclusão**: O smoke mínimo permanece 100% verde e íntegro após os ajustes do harness público.
