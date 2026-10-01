# Evidência Q8 — Regressão Completa de Qualidade, Estabilidade e Segurança (Q8-R01)

Data: 2026-09-30  
Branch: `qualidade/q8-performance-carga`  

---

## 1. Quadro Comparativo de Regressão

| Gate de Qualidade | Repositório | Baseline Anterior (Q7) | Resultado Q8-R01 | Status |
| :--- | :--- | :---: | :---: | :---: |
| **Testes Automatizados Flutter** | Flutter (`app_mppb_flutter`) | 187/187 PASS | **187/187 PASS** | **VERDE** |
| **Análise Estática (`flutter analyze`)** | Flutter (`app_mppb_flutter`) | 0 issues | **0 issues (No issues found!)** | **VERDE** |
| **Execução em Dispositivo Físico** | Flutter (`app_mppb_flutter`) | Galaxy A52 / Android 14 | **Galaxy A52 / Android 14 (`RX8RC09H70X`)** | **VERDE** |
| **Instalação APK Homolog Profile** | Flutter (`app_mppb_flutter`) | N/A | **Sucesso (`app-homolog-profile.apk`, 96,4 MB)** | **VERDE** |
| **Testes Automatizados Backend** | Backend (`spring-boot/restapi`) | 148/148 PASS | **153/153 PASS** (11 common + 142 mobile) | **VERDE** |
| **Empacotamento Maven (`package`)** | Backend (`spring-boot/restapi`) | BUILD SUCCESS | **BUILD SUCCESS** | **VERDE** |
| **Segurança e Isolamento de Produção** | Ambos os repositórios | Conforme | **Conforme (0 carga em produção)** | **VERDE** |

---

## 2. Verificação de Integridade de Branches e Repositórios

### Flutter (`app_mppb_flutter`)
- **Branch Ativa**: `qualidade/q8-performance-carga`
- **Alteração Preservada**: `pubspec.yaml` com `version: 4.0.0+69 → 4.0.0+72` mantida intacta e não commitada no working tree.
- **Commit / Push**: Nenhum commit realizado; nenhum push executado; nenhum merge.

### Backend (`spring-boot/restapi`)
- **Branch Ativa**: `qualidade/q8-performance-carga`
- **Componentes do Harness de Carga**:
  - `mobile-service/src/test/java/mppb/restapi/mobile/quality/Q8PerformanceServer.java` (Servidor sintético e probe de métricas JVM)
  - `mobile-service/src/test/java/mppb/restapi/mobile/quality/Q8PerformanceServerTest.java` (5 testes unitários de validação de rotas locais)
- **Commit / Push**: Nenhum commit realizado; nenhum push executado; nenhum merge.

---

## 3. Conclusão dos Gates de Regressão

Todos os testes de regressão automatizados de Flutter (187/187) e Backend (153/153) foram validados com 100% de sucesso. A análise estática não apontou qualquer advertência ou erro (0 issues), o APK Profile foi instalado com sucesso no Samsung Galaxy A52 físico, e a integridade do código foi estritamente preservada.
