# Q6 — Evidência de Regressão e Gates Finais

Data: 2026-09-29  
Branch: `qualidade/q6-concorrencia-integridade`  
Ciclo: Qualidade, Confiabilidade e Prontidão do App MPPB  

---

## 1. Tabela Consolidada de Gates de Regressão

| Gate | Requisito / Critério | Flutter | Backend | Resultado Final |
| :--- | :--- | :---: | :---: | :---: |
| **Análise Estática / Lint** | Zero erros e warnings | `flutter analyze` (0 issues) | Compilação limpa (JDK 21) | **VERDE** |
| **Suíte de Testes Automatizados** | `>= 157` Flutter / `>= 136` Backend | 168 / 168 PASS (+11 novos Q6) | 142 / 142 PASS (+6 novos Q6) | **VERDE** |
| **Determinismo e Flakiness** | Zero testes flaky, sincronizadores determinísticos | 11/11 determinísticos | 6/6 determinísticos | **VERDE** |
| **Cobertura de Código** | Execução de suíte com cobertura sem quebras | `flutter test --coverage` OK | JUnit 5 report OK | **VERDE** |
| **Security Gates** | Secret scan e security regression verdes | Scripts executados e limpos | Scripts executados e limpos | **VERDE** |
| **Build de Homologação** | APK e JARs empacotados com sucesso | APK homolog gerado | `package` gerado com sucesso | **VERDE** |
| **Integridade de Escopo** | Não iniciar Q7; preservar `pubspec.yaml` (+69 -> +72) | Preservado | Preservado | **VERDE** |

---

## 2. Detalhamento dos Testes Executados

### Flutter (168 Testes Totais)
- Baseline pré-Q6: 157 testes
- Novos testes Q6 (`test/features/concorrencia/q6_flutter_concurrency_test.dart`): 11 testes
  - Q6-T02: Duplo clique no login
  - Q6-T02/T11: Reutilização do identificador FCM
  - Q6-T03: Chamadas simultâneas de carteira
  - Q6-T04: Resposta tardia fora de ordem de Pagamentos
  - Q6-T05: Dispose do container durante requisição
  - Q6-T06: Logout durante operação assíncrona
  - Q6-T07: Troca de usuário e purga de cache
  - Q6-T11: Deduplicação de eventos de push
  - Q6-T12: Downloads concorrentes de PDF
  - Q6-T13: Filtro rápido de notícias
  - Q6-T16: Concorrência de leitura e isolamento de tokens
- **Total Flutter**: 168/168 PASS (100%)

### Backend (142 Testes Totais)
- Baseline pré-Q6: 136 testes
- Novos testes Q6 (`Q6ConcorrenciaIntegridadeTest.java`): 6 testes
  - Q6-T08/T09: Chamadas simultâneas de registro com mesmo identificador/token
  - Q6-T11: Desativação repetida de dispositivo FCM
  - Q6-T14: Validação e proteção transacional contra registros órfãos
  - Q6-T15: Constraints de unicidade e reativação por hash
  - Q6-T16: Concorrência de leitura simultânea em Perfil
  - Q6-T16: Concorrência de leitura simultânea em Pagamentos
- **Total Backend**: 142/142 PASS (100%)
