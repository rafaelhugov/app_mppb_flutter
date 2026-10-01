# Q11 — Evidência de Regressão e Portões de Qualidade (Regression Gate)

Data: 01/10/2026 (Reconciliado Q11-R01)  
Status: PASSOU (REGRESSION GATE VERDE)

---

## 1. Baseline Canônica e Contagem de Testes

- **Baseline Q10**: 187 testes passando.
- **Novos Testes Q11**: 33 testes automatizados específicos de acessibilidade criados em `test/features/acessibilidade/q11_acessibilidade_test.dart` (cobrindo labels semânticos, `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline`, text scaling 1.0x-2.0x, orientação landscape + 2.0x, formulários, foco e feedbacks de erro/loading).
- **Total Atual**: **220 testes** unitários/widgets/integração.
- **Meta Mínima Exigida**: `>= 217 testes`.

## 2. Execução dos Portões de Qualidade

### 2.1 Análise Estática (`flutter analyze`)
Comando:
```powershell
flutter analyze
```
Resultado:
```text
Analyzing app_mppb_flutter...
No issues found! (ran in 6.5s)
```
Status: **0 issues / VERDE**.

### 2.2 Suite Completa de Testes Automatizados (`flutter test`)
Comando:
```powershell
flutter test
```
Resultado:
```text
00:14 +220: All tests passed!
```
Status: **220/220 PASSOU / VERDE**.

### 2.3 Varredura de Segurança e Segredos
Comandos:
```bash
bash scripts/security/secret_scan.sh
bash scripts/security/security_regression.sh
```
Resultado:
```text
Exit code: 0 (sem segredos detectados, sem vazamentos de credenciais ou chaves)
```
Status: **VERDE**.

### 2.4 Compilação Android Homolog Debug
Comando:
```powershell
flutter build apk --debug --flavor homolog -t lib/main.dart --dart-define=API_URL=https://aplicativo-mppb-homolog.mppb.mp.br
```
Resultado:
```text
Running Gradle task 'assembleHomologDebug'...
√ Built build\app\outputs\flutter-apk\app-homolog-debug.apk
```
Status: **VERDE**.
