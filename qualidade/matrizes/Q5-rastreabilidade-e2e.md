# Q5 - Rastreabilidade E2E

Data: 2026-09-29

| Jornada Q5 | Base Q3/Q4 relacionada | Arquivo/area Flutter | Backend/servico | Resultado Q5 |
| --- | --- | --- | --- | --- |
| Home publica minima | Q4 runtime Android | `lib/main.dart` | N/A | ESTAVEL no smoke Q5-R01, 3/3 Pixel_8. |
| Home publica completa | Q4 runtime Android | `lib/main.dart`, `public_dashboard_page.dart` | N/A | BLOQUEADO por perda de ADB na jornada completa. |
| Contatos | Q2 widget/componentes, Q4 runtime | `features/contatos`, `public_dashboard_page.dart` | Links institucionais/externos | BLOQUEADO por perda de ADB na jornada completa. |
| Noticias | Q3 contrato publico, Q4 integracao | `features/noticias` | `/api/public/noticias` | BLOQUEADO por perda de ADB na jornada completa. |
| Diario Oficial | Q3 contrato publico | `features/diario_oficial` | endpoint publico de diarios | BLOQUEADO por runtime Android. |
| Processos/Captcha | Q3 contrato publico, Q4 integracao | `features/processos` | captcha e consulta publica | BLOQUEADO por captcha/massa/runtime. |
| Certidao Extrajudicial | Q3 contrato publico, Q4 integracao | `features/certidao_extrajudicial` | consulta/emissao PDF | BLOQUEADO por massa/runtime. |
| Ouvidoria | Q2 formatters/componentes | `features/ouvidoria` | servico externo de manifestacao | BLOQUEADO por efeito externo. |
| Login | Q3 contrato Auth | `features/auth` | auth-api/backend | BLOQUEADO por credencial. |
| Perfil | Q3 contrato autenticado | `features/perfil` | `/api/perfil/dados` | BLOQUEADO por credencial/massa. |
| Carteira | Q3 contrato autenticado | `features/carteira` | dados e foto funcional | BLOQUEADO por credencial/massa. |
| Contracheque | Q3 contrato autenticado | `features/contra_cheque` | competencias/PDF | BLOQUEADO por credencial/massa. |
| Pagamentos | Q3 contrato autenticado, Q4 integracao | `features/pagamentos` | exercicios/pagamentos | BLOQUEADO por credencial/massa. |
| Designacoes | Q3 contrato autenticado | `features/designacoes` | designacoes autenticadas | BLOQUEADO por credencial/massa. |
| Concessoes/Afastamentos | Q3 contrato autenticado, Q4 integracao | `features/concessao_afastamento` | leitura/operacoes | BLOQUEADO por credencial/massa/efeito externo. |
| FCM real | Q4 backend/Flutter notificacao | `core/notifications`, backend notificacao | Firebase/FCM | BLOQUEADO por Firebase real e device instavel. |

## Observacao

O flag `Q5_E2E_DISABLE_FCM=true` foi adicionado exclusivamente para permitir E2E publico sem dialogo/permissao nativa de notificacao. Ele nao aprova FCM real em Q5; a jornada FCM permanece bloqueada.

Q5-R01 adicionou `q5_smoke_home_e2e_test.dart` para distinguir harness minimo de instabilidade do runtime Android. O smoke passou de forma reproduzivel; a jornada publica completa permanece bloqueada por infraestrutura Android/ADB.
