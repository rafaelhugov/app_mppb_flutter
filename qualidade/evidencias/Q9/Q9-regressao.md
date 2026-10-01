# Q9 — Evidência dos Portões de Regressão e Build

**Fase:** Q9 — Compatibilidade  
**Data:** 01/10/2026  
**Status:** Portões Verdes / Regressão Aprovada  

---

## 1. Portão 1: Análise Estática (`flutter analyze`)

- **Comando:** `flutter analyze`
- **Diretório:** `c:\Users\rafae\projetosMPPB\app_mppb_flutter`
- **Ambiente:** Flutter 3.44.3 • Dart 3.12.2 • DevTools 2.57.0
- **Duração:** 117,7 segundos
- **Resultado:**
  ```text
  Analyzing app_mppb_flutter...                                   
  No issues found! (ran in 117.7s)
  ```
- **Status:** **PASSOU (0 issues)**

---

## 2. Portão 2: Testes Automatizados (`flutter test`)

- **Comando:** `flutter test`
- **Diretório:** `c:\Users\rafae\projetosMPPB\app_mppb_flutter`
- **Total de Testes:** 187 testes
- **Duração:** 13 segundos
- **Cobertura Testada:**
  - Testes de unidades de Auth, Carteira, Pagamentos, Diário Oficial, Certidão, Ouvidoria, Contracheque, Perfil, Designações, Notícias e Processos.
  - Testes determinísticos de concorrência Q6 (11 testes).
  - Testes determinísticos de rede e resiliência offline Q7 (18 testes).
  - Testes de layout responsivo e breakpoints (`test/core/ui/responsive_layout_test.dart`).
  - Testes de segurança de armazenamento biométrico e cleartext manifest.
- **Resultado:**
  ```text
  00:13 +187: All tests passed!
  ```
- **Status:** **PASSOU (187/187 verde)**

---

## 3. Portão 3: Compilação de Artefato Android (APK)

- **Comando:** `flutter build apk --debug --flavor homolog -t lib/main.dart`
- **Flavor:** `homolog`
- **Modo:** `debug`
- **Target:** `lib/main.dart`
- **Dart Defines:** Padrão do projeto
- **Duração da Tarefa Gradle (`assembleHomologDebug`):** 43,8 segundos
- **Artefato Produzido:**
  - Caminho: `build\app\outputs\flutter-apk\app-homolog-debug.apk`
  - Tamanho: `220.343.957 bytes` (~210 MB)
  - Data/Hora: `01/10/2026 11:38:34`
- **Resultado:**
  ```text
  Running Gradle task 'assembleHomologDebug'...                      43,8s
  √ Built build\app\outputs\flutter-apk\app-homolog-debug.apk
  ```
- **Status:** **PASSOU**

---

## 4. Portão 4: Neutralidade dos Contratos Backend

A avaliação de compatibilidade dos contratos do cliente com o backend `mobile-service` comprovou:
- **Formato:** Comunicação baseada em JSON padronizado UTF-8 (RFC 8259).
- **Cabeçalhos:** `Authorization: Bearer <jwt>`, `Accept: application/json`, `Content-Type: application/json`.
- **Independência de Plataforma:** O cliente Flutter utiliza o motor HTTP `dio`, que abstrai o socket nativo (OkHttp no Android / NSURLSession no iOS) mantendo payload e headers idênticos.
- **Status:** **PASSOU**
