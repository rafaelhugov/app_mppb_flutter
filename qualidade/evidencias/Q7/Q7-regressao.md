# Evidência Q7 — Regressão Completa de Qualidade e Segurança

Data: 2026-09-30  
Branch: `qualidade/q7-rede-offline-interrupcoes`  

---

## 1. Quadro Comparativo de Regressão

| Gate de Qualidade | Repositório | Baseline Anterior (Q6) | Resultado Q7 | Status |
| :--- | :--- | :---: | :---: | :---: |
| **Testes Automatizados** | Flutter (`app_mppb_flutter`) | 169/169 PASS | **187/187 PASS** (+18 testes determinísticos) | **VERDE** |
| **Análise Estática (`flutter analyze`)** | Flutter (`app_mppb_flutter`) | 0 issues | **0 issues** | **VERDE** |
| **Cobertura (`test --coverage`)** | Flutter (`app_mppb_flutter`) | Cobertura preservada | **187/187 PASS (LCOV gerado)** | **VERDE** |
| **Compilação APK Homolog Debug** | Flutter (`app_mppb_flutter`) | Sucesso | **Sucesso (`app-homolog-debug.apk`)** | **VERDE** |
| **Secret Scan Script** | Flutter (`app_mppb_flutter`) | 0 leaks | **0 leaks** | **VERDE** |
| **Security Regression Script** | Flutter (`app_mppb_flutter`) | Conforme | **Conforme** | **VERDE** |
| **Testes Unitários / Integração** | Backend (`spring-boot/restapi`) | 142/142 PASS | **148/148 PASS** (+6 testes determinísticos) | **VERDE** |
| **Empacotamento Maven (`package`)** | Backend (`spring-boot/restapi`) | BUILD SUCCESS | **BUILD SUCCESS (`restapi-common`, `mobile-service`)** | **VERDE** |
| **Security Gates Backend** | Backend (`spring-boot/restapi`) | Conforme | **Conforme** | **VERDE** |

---

## 2. Inventário de Alterações no Ciclo Q7

### Flutter (`app_mppb_flutter`)
- `lib/features/carteira/providers/carteira_provider.dart`: Adicionados guards `ref.mounted` no `fetchCarteira` e `_loadFromCache` (`BUG-Q7-001`).
- `lib/features/noticias/providers/noticia_provider.dart`: Adicionado guard `ref.mounted` no início de `fetchNoticias` (`BUG-Q7-002`).
- `test/features/rede/q7_rede_interrupcoes_test.dart`: Criada nova suíte com 18 testes determinísticos cobrindo offline, timeouts, quedas de conexão, retry seguro de leitura, preservação de dados prévios, HTTP 401/403/503 e download de streams.
- `pubspec.yaml`: Preservada alteração preexistente `version: 4.0.0+69 → 4.0.0+72` estritamente fora do escopo de commit.

### Backend (`spring-boot/restapi`)
- `mobile-service/src/test/java/mppb/restapi/mobile/quality/Q7RedeInterrupcoesTest.java`: Criada nova suíte com 6 testes determinísticos cobrindo indisponibilidade de clientes Feign externos (503), timeouts de leitura, erros 5xx de dependências (502), token inválido (401) e autorização negada (403).

---

## 3. Conclusão dos Gates

Nenhuma regressão funcional, de integridade ou de segurança foi introduzida. Todos os portões automatizados de Flutter e Backend foram executados e concluídos com sucesso.
