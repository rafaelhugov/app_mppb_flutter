# Evidência Q12 — Regressão Completa de Qualidade e Segurança

**Data de Execução:** 01/10/2026  
**Fase:** Q12 — Resiliência, Observabilidade e Recuperação  
**Reconciliação:** Q12-R01 — Reconciliação Metodológica e Validação Definitiva  
**Ambiente:** Flutter (App Mobile) + Spring Boot (`restapi-common` e `mobile-service`)  

---

## 1. Resumo dos Gates de Regressão

| Gate | Alvo / Escopo | Critério | Resultado | Status |
|---|---|---|---|---|
| **Flutter Analyze** | `app_mppb_flutter` | `0 issues` | `0 issues found` | **PASSOU** |
| **Flutter Tests** | `test/` (completo) | `>= 220 testes` | `231/231 testes aprovados` | **PASSOU** |
| **Security Secret Scan** | `scripts/security/secret_scan.sh` | `Exit code 0` | 0 segredos detectados | **PASSOU** |
| **Security Regression** | `scripts/security/security_regression.sh` | `Exit code 0` | 0 vulnerabilidades | **PASSOU** |
| **Flutter Build APK** | Flavor homolog debug | Compilação com `--dart-define` de homolog | APK gerado com sucesso | **PASSOU** |
| **Backend Tests** | `restapi-common,mobile-service` | `>= 153 testes` | `164/164 testes aprovados` (11 em `restapi-common`, 153 em `mobile-service`) | **PASSOU** |
| **Backend Package** | `restapi-common,mobile-service` | `Exit code 0` | Build e empacotamento com sucesso | **PASSOU** |

---

## 2. Detalhamento dos Resultados Reconciliados

### 2.1 Análise Estática Flutter (`flutter analyze`)
```text
Analyzing app_mppb_flutter...
No issues found! (ran in 5.6s)
```

### 2.2 Testes Automatizados Flutter (`flutter test`)
- Baseline Q11: 220 testes aprovados.
- Incremento Q12: +11 testes automatizados em `test/features/resiliencia/q12_resiliencia_test.dart` cobrindo T01 a T06, T20 e T21.
- Total Executado: **231/231 testes aprovados** (0 falhas).

### 2.3 Gates de Segurança
```bash
& "C:\Program Files\Git\bin\bash.exe" scripts/security/secret_scan.sh
& "C:\Program Files\Git\bin\bash.exe" scripts/security/security_regression.sh
# Exit code: 0
```

### 2.4 Testes e Empacotamento do Backend (Maven)
- **Reversão e Integridade da Q6:** `Q6ConcorrenciaIntegridadeTest.java` foi restaurado integralmente para a versão da `master` (`git restore --source=master`), mantendo a Q6 congelada e sem contaminações.
- Módulos auditados: `restapi-common` e `mobile-service`.
- Baseline anterior: 153 testes aprovados.
- Incremento Q12: +11 novos testes em `Q12ResilienciaObservabilidadeTest.java`.
- Total Executado: **164/164 testes aprovados** (11 em `restapi-common`, 153 em `mobile-service`).
- Empacotamento: `mvn -q -pl restapi-common,mobile-service -DskipTests package` concluído com exit code 0.
