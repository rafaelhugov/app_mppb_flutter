# Q5 - Inventario de Jornadas E2E

Data: 2026-09-29  
Escopo: Flutter Android homologacao, sem inicio de Q6.

## Criterio Q5

Uma jornada E2E valida UI real, estado local, provider/repository/service, HTTP real e resposta observavel na UI. Mocks e fakes nao aprovam Q5.

## Resumo

| Grupo | Total | Criticas | Executadas em E2E real | Aprovadas | Bloqueadas |
| --- | ---: | ---: | ---: | ---: | ---: |
| Publicas | 7 | 5 | 3 tentadas | 0 | 7 |
| Autenticadas | 10 | 10 | 0 | 0 | 10 |
| Total | 17 | 15 | 3 tentadas | 0 | 17 |

## Jornadas publicas

| ID | Jornada | Criticidade | Estado Q5 | Motivo |
| --- | --- | --- | --- | --- |
| Q5-E2E-PUB-01 | Inicializar app e validar Home publica | Alta | PARCIAL/BLOQUEADA | App alcancou Home em tentativa posterior, mas execucao final foi interrompida por `emulator`/ADB instavel. |
| Q5-E2E-PUB-02 | Abrir Contatos a partir da Home | Alta | PARCIAL/BLOQUEADA | Fluxo automatizado criado e exercitado parcialmente; sem execucao verde por `exit 139`/device offline. |
| Q5-E2E-PUB-03 | Abrir Noticias e detalhe/lista real | Alta | PARCIAL/BLOQUEADA | Jornada cobre API homolog via app real; nao concluiu por queda do emulador. |
| Q5-E2E-PUB-04 | Abrir Diario Oficial | Media | BLOQUEADA | Nao executada apos instabilidade do runtime Android. |
| Q5-E2E-PUB-05 | Consultar Processos/Captcha | Alta | BLOQUEADA | Exige captcha/massa segura e runtime Android estavel. |
| Q5-E2E-PUB-06 | Consultar/emitir Certidao Extrajudicial | Alta | BLOQUEADA | Exige massa segura e criterio de efeito externo; nao executada no runtime instavel. |
| Q5-E2E-PUB-07 | Registrar manifestacao na Ouvidoria | Alta | BLOQUEADA | Efeito externo nao autorizado para execucao real em homologacao. |

## Jornadas autenticadas

| ID | Jornada | Criticidade | Estado Q5 | Motivo |
| --- | --- | --- | --- | --- |
| Q5-E2E-AUTH-01 | Login real homologacao | Alta | BLOQUEADA | Sem credencial institucional autorizada para E2E. |
| Q5-E2E-AUTH-02 | Home autenticada e menu principal | Alta | BLOQUEADA | Depende de login real. |
| Q5-E2E-AUTH-03 | Perfil/Dados funcionais | Alta | BLOQUEADA | Depende de login e massa com dados conhecidos. |
| Q5-E2E-AUTH-04 | Carteira funcional | Alta | BLOQUEADA | Depende de login e massa autorizada. |
| Q5-E2E-AUTH-05 | Contracheque e PDF | Alta | BLOQUEADA | Depende de login e massa com competencia disponivel. |
| Q5-E2E-AUTH-06 | Pagamentos por exercicio | Alta | BLOQUEADA | Depende de login e massa com pagamentos. |
| Q5-E2E-AUTH-07 | Designacoes ativas | Alta | BLOQUEADA | Depende de login e massa com designacoes. |
| Q5-E2E-AUTH-08 | Concessoes/Afastamentos leitura | Alta | BLOQUEADA | Depende de login e massa segura. |
| Q5-E2E-AUTH-09 | Concessoes/Afastamentos operacoes | Alta | BLOQUEADA | Efeito externo nao autorizado sem massa descartavel. |
| Q5-E2E-AUTH-10 | Registro e navegacao por FCM real | Alta | BLOQUEADA | Exige Firebase/FCM real, credencial e dispositivo estavel. |

