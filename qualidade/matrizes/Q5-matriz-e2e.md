# Q5 - Matriz de Testes E2E

Data: 2026-09-29  
Branch Flutter: `qualidade/q5-e2e`

## 1. Histórico de Tentativas no Linux VM (Q5-R01)

| ID | Jornada | Automação | Ambiente | Resultado | Evidência | Observações |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Q5-R01-SMOKE | Home pública mínima | `integration_test/q5_smoke_home_e2e_test.dart` | Pixel_8/API 36 e Pixel_9/API 37, flavor homolog | PASSOU | `runtime/tentativas-resumo.md` | Pixel_8: 3/3 verde; Pixel_9: 1/1 verde. |
| Q5-E2E-PUB-01 | Home pública | `integration_test/q5_public_e2e_test.dart` | Android emulator, flavor homolog | BLOQUEADA | `Q5-execucao-e2e.md`, `runtime/tentativas-resumo.md` | Perda de ADB em Pixel_8 e Pixel_9 com `device offline`. |
| Q5-E2E-PUB-02 | Contatos | `integration_test/q5_public_e2e_test.dart` | Android emulator, flavor homolog | BLOQUEADA | `Q5-execucao-e2e.md` | Mesmo bloqueio na jornada completa antes de conclusão reproduzível. |
| Q5-E2E-PUB-03 | Notícias | `integration_test/q5_public_e2e_test.dart` | Android emulator, flavor homolog, API homolog | BLOQUEADA | `Q5-execucao-e2e.md` | Mesmo bloqueio na jornada completa antes de conclusão reproduzível. |
| Q5-E2E-PUB-04 | Diário Oficial | Não implementada nesta rodada | Android homolog | NÃO EXECUTADA | Inventário Q5 | Não implementada nesta rodada. |
| Q5-E2E-PUB-05 | Processos/Captcha | Não implementada nesta rodada | Android homolog | BLOQUEADA | Inventário Q5 | Captcha institucional sem bypass/massa automatizável nesta rodada. |
| Q5-E2E-PUB-06 | Certidão Extrajudicial | Não implementada nesta rodada | Android homolog | BLOQUEADA | Inventário Q5 | Restrição contra geração/emissão com efeito externo sem massa descartável. |
| Q5-E2E-PUB-07 | Ouvidoria | Não implementada nesta rodada | Android homolog | BLOQUEADA | Inventário Q5 | Restrição contra envio com efeito institucional externo real. |
| Q5-E2E-AUTH-01 a 09 | Jornadas Autenticadas | Não executadas nesta rodada | Android homolog | BLOQUEADAS | Inventário Q5 | BLOQUEADAS POR CREDENCIAL/MASSA HOMOLOG AUTORIZADA. |
| Q5-E2E-AUTH-10 | FCM real | Não executada | Android homolog + Firebase | BLOQUEADA | Inventário Q5 | Firebase/FCM real, credencial e infraestrutura institucional ausentes. |

---

## 2. Consolidação em Dispositivo Físico Real (Windows + USB - Samsung Galaxy A52)

Ambiente: Windows 11 Físico + Samsung Galaxy A52 (`SM-A525M`, Android 14 / API 34), conexão USB física via ADB.

| ID | Jornada / Escopo | Automação | Resultado | ADB | Detalhamento |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Q5-R02-SMOKE** | Home pública mínima | `integration_test/q5_smoke_home_e2e_test.dart` | **PASSOU** | `device` | 3/3 execuções consecutivas verdes (~5s). App inicializa e renderiza Home. |
| **Q5-R02-PUB-PRINCIPAL** | **Jornada Pública Principal** (Home → Contatos → Home → Notícias → Home) | `integration_test/q5_public_e2e_test.dart` | **PASSOU (3/3)** | `device` | 3 execuções consecutivas verdes com asserção estrita positiva da listagem de Notícias (`Key('lista-noticias')` e `find.text('Abrir')`). |
| **Q5-E2E-PUB-DIARIO** | Diário Oficial | N/A | **NÃO EXECUTADA** | N/A | Jornada não implementada no harness nesta rodada. |
| **Q5-E2E-PUB-PROC** | Processos / Consulta Pública | N/A | **PARCIAL / E2E MANUAL CONTROLADO PENDENTE** | N/A | Exige validação de Captcha que não deve ser burlado na automação. |
| **Q5-E2E-PUB-CERT** | Certidão Extrajudicial | N/A | **BLOQUEADA** | N/A | Bloqueio institucional para evitar emissão com efeito real sem massa descartável. |
| **Q5-E2E-PUB-OUV** | Ouvidoria | N/A | **BLOQUEADA** | N/A | Bloqueio institucional para evitar envio com efeito externo real. |
| **Q5-E2E-AUTH** | Jornadas Autenticadas (Login, Perfil, Carteira, Contracheque, etc.) | N/A | **BLOQUEADAS** | N/A | **BLOQUEADAS POR CREDENCIAL/MASSA HOMOLOG AUTORIZADA**. |
| **Q5-E2E-FCM** | Push Notification / FCM Real | N/A | **BLOQUEADA** | N/A | Isolada via `Q5_E2E_DISABLE_FCM=true`; bloqueada institucionalmente sem credenciais Firebase. |

---

## 3. Decisão e Síntese de Validação

1. **JORNADA PÚBLICA PRINCIPAL E2E VALIDADA EM ANDROID FÍSICO — 3/3 PASS**:
   - Execução 1: PASS (~13s) | ADB: `device`
   - Execução 2: PASS (~12s) | ADB: `device`
   - Execução 3: PASS (~13s) | ADB: `device`
2. **Estabilidade de Hardware**:
   - Zero crashes, zero ANRs, zero SIGSEGV, zero PlatformException.
   - Conexão ADB física permaneceu em estado `device` ininterruptamente.
3. **Escopo Executável Local/Público**:
   - **E2E PÚBLICO EXECUTÁVEL DA Q5 VALIDADO**.
   - Pendências externas (autenticadas, FCM real, operações institucionais com efeito externo, captcha) devidamente classificadas e preservadas.
