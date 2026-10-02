# Q13 — Evidência dos Portões de Regressão

**Data:** 02/10/2026  
**Fase:** Q13 — Mutation Testing, Property-Based Testing e Fuzz Testing  

---

## 1. Portão de Regressão: Frontend Flutter

### 1.1 Análise Estática (`flutter analyze`)
- **Comando:** `flutter analyze --no-pub`
- **Resultado:**
  ```text
  Analyzing app_mppb_flutter...
  No issues found! (ran in 29.3s)
  ```
- **Status:** **VERDE (0 issues)**

### 1.2 Suíte Completa de Testes (`flutter test`)
- **Comando:** `flutter test --no-pub`
- **Resultado:**
  ```text
  00:27 +242: All tests passed!
  ```
- **Total:** 242 testes executados (231 históricos + 11 novos testes determinísticos Q13)
- **Status:** **VERDE (242/242 testes aprovados)**

### 1.3 Portões de Segurança Institucional
- **Secret Scan:** `bash scripts/security/secret_scan.sh` $\implies$ Código de saída 0 (nenhum segredo ou chave detectada)
- **Security Regression:** `bash scripts/security/security_regression.sh` $\implies$ Código de saída 0 (regras de segurança validadas)
- **Status:** **VERDE**

### 1.4 Build do Pacote APK Homologação
- **Comando:**
  ```powershell
  flutter build apk --debug --flavor homolog -t lib/main.dart --dart-define=API_URL=https://aplicativo-mppb-homolog.mppb.mp.br
  ```
- **Resultado:**
  ```text
  Running Gradle task 'assembleHomologDebug'... 48,9s
  √ Built build\app\outputs\flutter-apk\app-homolog-debug.apk
  ```
- **Status:** **VERDE (APK gerado com sucesso)**

---

## 2. Portão de Regressão: Backend Spring Boot

### 2.1 Suíte Completa de Testes Maven
- **Comando:** `mvn -pl restapi-common,mobile-service test`
- **Resultado:**
  ```text
  [INFO] Reactor Summary:
  [INFO] restapi-common 1.0.0 ............................... SUCCESS [  8.965 s]
  [INFO] mobile-service 0.3.25 .............................. SUCCESS [ 15.080 s]
  [INFO] BUILD SUCCESS
  [INFO] Tests run: 169, Failures: 0, Errors: 0, Skipped: 0
  ```
- **Baseline Requerida:** $\ge 164$ testes
- **Total Executado:** 169 testes (164 históricos + 5 novas baterias Q13 com 2.500 iterações)
- **Status:** **VERDE (169/169 testes aprovados)**

### 2.2 Empacotamento Maven (`mvn package`)
- **Comando:** `mvn -q -pl restapi-common,mobile-service -DskipTests package`
- **Resultado:** Código de saída 0 (BUILD SUCCESS)
- **Status:** **VERDE**

### 2.3 Integridade de Testes Históricos Concorrentes
- **Verificação:** `git diff --stat -- mobile-service/src/test/java/mppb/restapi/mobile/quality/Q6ConcorrenciaIntegridadeTest.java`
- **Resultado:** 0 linhas alteradas (arquivo 100% idêntico à master original)
- **Status:** **VERDE (sem alterações)**

---

## 3. Estado dos Repositórios Git

### 3.1 Flutter (`app_mppb_flutter`)
- **Branch:** `qualidade/q13-mutation-property-fuzz`
- **Alteração preservada fora de commit:** `pubspec.yaml` (versão 4.0.0+69 $\to$ 4.0.0+72)
- **Worktrees temporários de mutação:** Removidos (`git worktree list` limpo)
- **Arquivos modificados de produção:** Nenhum residual
- **Commits / Pushes / Merges realizados:** **Nenhum**

### 3.2 Backend (`spring-boot/restapi`)
- **Branch:** `qualidade/q13-mutation-property-fuzz`
- **Worktrees temporários de mutação:** Removidos (`git worktree list` limpo)
- **Arquivos modificados de produção:** Nenhum residual
- **Commits / Pushes / Merges realizados:** **Nenhum**
