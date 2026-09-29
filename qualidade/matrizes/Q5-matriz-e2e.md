# Q5 - Matriz de Testes E2E

Data: 2026-09-29  
Branch Flutter: `qualidade/q5-e2e`

| ID | Jornada | Automacao | Ambiente | Resultado | Evidencia | Bloqueio |
| --- | --- | --- | --- | --- | --- | --- |
| Q5-R01-SMOKE | Home publica minima | `integration_test/q5_smoke_home_e2e_test.dart` | Pixel_8/API 36 e Pixel_9/API 37, flavor homolog | ESTAVEL/PASSOU | `runtime/tentativas-resumo.md` | Pixel_8: 3/3 verde; Pixel_9: 1/1 verde. |
| Q5-E2E-PUB-01 | Home publica | `integration_test/q5_public_e2e_test.dart` | Android emulator, flavor homolog | BLOQUEADO | `Q5-execucao-e2e.md`, `runtime/tentativas-resumo.md` | Jornada completa perdeu ADB em Pixel_8 e Pixel_9 com `device offline`. |
| Q5-E2E-PUB-02 | Contatos | `integration_test/q5_public_e2e_test.dart` | Android emulator, flavor homolog | BLOQUEADO | `Q5-execucao-e2e.md` | Mesmo bloqueio na jornada completa antes de conclusao reproduzivel. |
| Q5-E2E-PUB-03 | Noticias | `integration_test/q5_public_e2e_test.dart` | Android emulator, flavor homolog, API homolog | BLOQUEADO | `Q5-execucao-e2e.md` | Mesmo bloqueio na jornada completa antes de conclusao reproduzivel. |
| Q5-E2E-PUB-04 | Diario Oficial | Nao implementada nesta rodada | Android homolog | BLOQUEADO | Inventario Q5 | Runtime Android instavel. |
| Q5-E2E-PUB-05 | Processos/Captcha | Nao implementada nesta rodada | Android homolog | BLOQUEADO | Inventario Q5 | Captcha/massa segura e runtime estavel ausentes. |
| Q5-E2E-PUB-06 | Certidao Extrajudicial | Nao implementada nesta rodada | Android homolog | BLOQUEADO | Inventario Q5 | Massa segura e runtime estavel ausentes. |
| Q5-E2E-PUB-07 | Ouvidoria | Nao implementada nesta rodada | Android homolog | BLOQUEADO | Inventario Q5 | Efeito externo nao autorizado. |
| Q5-E2E-AUTH-01 | Login real | Nao executada | Android homolog | BLOQUEADO | Inventario Q5 | Credencial homolog autorizada ausente. |
| Q5-E2E-AUTH-02 | Home autenticada | Nao executada | Android homolog | BLOQUEADO | Inventario Q5 | Depende de login real. |
| Q5-E2E-AUTH-03 | Perfil | Nao executada | Android homolog | BLOQUEADO | Inventario Q5 | Credencial/massa ausente. |
| Q5-E2E-AUTH-04 | Carteira funcional | Nao executada | Android homolog | BLOQUEADO | Inventario Q5 | Credencial/massa ausente. |
| Q5-E2E-AUTH-05 | Contracheque/PDF | Nao executada | Android homolog | BLOQUEADO | Inventario Q5 | Credencial/massa ausente. |
| Q5-E2E-AUTH-06 | Pagamentos | Nao executada | Android homolog | BLOQUEADO | Inventario Q5 | Credencial/massa ausente. |
| Q5-E2E-AUTH-07 | Designacoes | Nao executada | Android homolog | BLOQUEADO | Inventario Q5 | Credencial/massa ausente. |
| Q5-E2E-AUTH-08 | Concessoes/Afastamentos leitura | Nao executada | Android homolog | BLOQUEADO | Inventario Q5 | Credencial/massa ausente. |
| Q5-E2E-AUTH-09 | Concessoes/Afastamentos operacoes | Nao executada | Android homolog | BLOQUEADO | Inventario Q5 | Efeito externo nao autorizado. |
| Q5-E2E-AUTH-10 | FCM real | Nao executada | Android homolog + Firebase | BLOQUEADO | Inventario Q5 | Firebase/FCM real, credencial e device estavel ausentes. |

## Decisao

Q5-R01 comprovou que o harness minimo executa o app em Android valido, mas a jornada publica completa nao ficou reproduzivel porque Pixel_8 e Pixel_9 perderam ADB durante a execucao. Q5 permanece bloqueada por infraestrutura Android/ADB para aprovacao E2E publica completa.
