# Q5 - Rastreabilidade E2E

Data: 2026-09-29  
Branch Flutter: `qualidade/q5-e2e`

## 1. Rastreabilidade por Jornada e Componente

| Jornada Q5 | Base Q3/Q4 relacionada | Arquivo/Área Flutter | Backend/Serviço | Classificação Q5 | Evidência / Fundamentação |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Home Pública Mínima** | Q4 runtime Android | `lib/main.dart` | N/A | **PASSOU** | `integration_test/q5_smoke_home_e2e_test.dart` (3/3 PASS em Android físico). |
| **Jornada Pública Principal** (Home → Contatos → Home → Notícias → Home) | Q2 componentes, Q3 contratos, Q4 runtime | `public_dashboard_page.dart`, `features/contatos`, `features/noticias` | `/api/public/noticias` (homologação) | **PASSOU** | `integration_test/q5_public_e2e_test.dart` (3/3 PASS em Android físico com asserção estrita de lista de notícias). |
| **Diário Oficial** | Q3 contrato público | `features/diario_oficial` | Endpoint público de diários | **NÃO EXECUTADA** | Não implementada no harness automatizado nesta rodada. |
| **Processos / Captcha** | Q3 contrato público, Q4 integração | `features/processos` | Captcha e consulta pública | **PARCIAL / E2E MANUAL CONTROLADO PENDENTE** | Captcha institucional não deve ser burlado por automação; requer execução manual assistida. |
| **Certidão Extrajudicial** | Q3 contrato público, Q4 integração | `features/certidao_extrajudicial` | Consulta / emissão PDF | **BLOQUEADA** | Bloqueada para prevenir emissão institucional sem massa descartável homolog autorizada. |
| **Ouvidoria** | Q2 formatters/componentes | `features/ouvidoria` | Serviço externo de manifestação | **BLOQUEADA** | Bloqueada para prevenir envio com efeito externo real institucional. |
| **Jornadas Autenticadas** (Login, Perfil, Carteira, Contracheque, Pagamentos, Designações, Concessões) | Q3 contratos autenticados, Q4 integração | Módulos restritos (`features/auth`, `perfil`, `carteira`, etc.) | Backend autenticado homolog | **BLOQUEADAS** | **BLOQUEADAS POR CREDENCIAL/MASSA HOMOLOG AUTORIZADA**. |
| **FCM / Notificação Real** | Q4 backend/Flutter notificação | `core/notifications` | Firebase Cloud Messaging | **BLOQUEADA** | Bloqueada por ausência de credenciais e infraestrutura Firebase institucional; isolada no E2E público via `--dart-define=Q5_E2E_DISABLE_FCM=true`. |

---

## 2. Síntese do Escopo Executável

- **JORNADA PÚBLICA PRINCIPAL E2E VALIDADA EM ANDROID FÍSICO** (Samsung Galaxy A52, Android 14 / API 34).
- O harness exige evidência positiva de carregamento (`Key('lista-noticias')` e `find.text('Abrir')`), não tolerando estados de erro da API nem telas vazias como falso positivo.
- Todas as pendências externas permanecem devidamente isoladas e registradas sem mascaramento.
