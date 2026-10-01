# Evidência Q10 — Regressão Final e Security Gates

Data: 01/10/2026  
Repositório: `app_mppb_flutter`  
Branch: `qualidade/q10-instalacao-atualizacao-migracao`

---

## 1. Verificação Estática de Código (`flutter analyze`)

Comando executado:
```powershell
flutter analyze
```

Saída oficial:
```text
Analyzing app_mppb_flutter...
No issues found! (ran in 9.5s)
```

Resultado: **VERDE (0 issues)**.

---

## 2. Bateria Completa de Testes Automatizados (`flutter test`)

Comando executado:
```powershell
flutter test
```

Saída oficial:
```text
00:11 +186: C:/Users/rafae/projetosMPPB/app_mppb_flutter/test/widget_test.dart: smoke test harness renders
00:11 +187: All tests passed!
```

Resultado: **VERDE (187/187 testes passando, 100% de sucesso)**.

### Cobertura de Testes Específicos Relevantes para Q10:
- `test/security/biometric_password_storage_test.dart`:
  - `biometria nao grava senha no secure storage`: **PASS**
  - `login biometrico legado nao reutiliza senha salva`: **PASS**
- `test/security/android_cleartext_manifest_test.dart`:
  - `manifest principal desabilita cleartext para release`: **PASS**
  - `cleartext fica isolado em debug e profile`: **PASS**
- `test/features/perfil/perfil_provider_test.dart`:
  - `PerfilNotifier usa cache quando a API falha para o mesmo usuario`: **PASS**
  - `PerfilNotifier descarta cache quando pertence a outro usuario`: **PASS**
- `test/features/rede/q7_rede_interrupcoes_test.dart`:
  - `CarteiraNotifier recupera dados locais offline sob erro de rede`: **PASS**
  - `PerfilNotifier recupera perfil local offline sob indisponibilidade`: **PASS**

---

## 3. Compilação de Artefato Executável

Comando executado:
```powershell
flutter build apk --debug --flavor homolog -t lib/main.dart --dart-define=API_URL=https://aplicativo-mppb-homolog.mppb.mp.br
```

Saída:
```text
Running Gradle task 'assembleHomologDebug'...
√ Built build\app\outputs\flutter-apk\app-homolog-debug.apk
```

Resultado: **VERDE (APK compilado com sucesso)**.

---

## 4. Estado do Backend (`spring-boot/restapi`)

- Repositório: `C:\Users\rafae\projetosMPPB\spring-boot\restapi`
- Branch: `master`
- HEAD: `508a1fc`
- Status: Working tree limpo (nenhuma alteração necessária para Q10, escopo mobile atendido).
