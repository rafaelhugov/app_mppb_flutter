# Q1 - Relatorio final

Data de fechamento local: 2026-09-25 16:30:17 -03

## Respostas objetivas

1. Funcionalidades identificadas: 19.
2. Criticidade: 5 criticas, 9 altas, 4 medias, 1 baixa.
3. Testes Flutter: 20 arquivos; 114 casos no baseline, com 111 passados e 3 falhos.
4. Testes backend: 23 classes Surefire; 126 casos, todos passados.
5. Boa cobertura relativa: RF-015 Designacoes, RF-018 Notificacoes, RF-016/RF-017 Concessoes parcialmente, RF-009 Contatos.
6. Parcialmente cobertas: 13 funcionalidades.
7. Sem cobertura especifica: RF-003, RF-006, RF-007, RF-008, RF-011, RF-014.
8. Criticas que devem entrar obrigatoriamente no Q2: RF-010 Login/sessao, RF-012 Carteira, RF-013 Contracheque, RF-016/RF-017 Concessoes/Afastamentos.
9. Dependem de Q3/Q4/Q5: todos os fluxos com contrato Flutter-backend ou dependencia real, especialmente RF-004 a RF-018.
10. Baseline runtime esta parcialmente saudavel: publicos web carregaram e API publica respondeu; Android/APK/autenticado ficaram bloqueados por dependencia externa.
11. Regressao pre-existente: 3 falhas em testes Flutter de `ConcessaoAfastamentoCard`.
12. Bloqueios externos: sem device/emulador Android, sem credenciais/massa autenticada, sem validacao FCM real.
13. Escopo fechado recomendado para Q2: unit/widget/provider/service dos fluxos criticos e dos fluxos sem cobertura, sem iniciar contratos/integracao/E2E ainda.

## Sanity/baseline

| Verificacao | Flutter | Backend | Resultado |
| --- | --- | --- | --- |
| Branch Q1 | `qualidade/q1-rastreabilidade-funcional` | `qualidade/q1-rastreabilidade-funcional` | OK |
| Status inicial | `pubspec.yaml` ja estava modificado | limpo | OK, sem descarte |
| Analyze/compilacao estatica | `flutter analyze` passou | N/A | OK |
| Testes automatizados | `flutter test` falhou: 111/114 passaram | `mvn test` passou: 126/126 | Parcial |
| Scan segredo | passou | passou | OK |
| Regressao seguranca | passou | passou | OK |
| Build/package | APK debug homolog gerado | package Maven passou | OK |
| Runtime publico | Chrome web passou smoke basico | API publica `health` UP | Parcial |
| Runtime autenticado/mobile | bloqueado por ausencia de credenciais/device | bloqueado para fluxos autenticados reais | Bloqueado externo |

## Inventario

- Total de funcionalidades: 19.
- Criticas: 5.
- Altas: 9.
- Medias: 4.
- Baixas: 1.
- Total de testes: 240 casos executados no baseline automatizado, sendo 114 Flutter e 126 backend.
- Principais modulos: autenticacao, home publica, noticias, diario oficial, processos/captcha, certidao extrajudicial, ouvidoria, contatos, perfil, carteira funcional, contracheque, pagamentos, designacoes, concessoes/afastamentos, notificacoes.

## Cobertura

| Estado | Quantidade |
| --- | ---: |
| Coberto | 0 |
| Parcial | 13 |
| Ausente | 6 |
| Bloqueado | 0 |

Bloqueios aparecem no runtime, nao como cobertura consolidada, porque a cobertura foi classificada a partir dos testes existentes.

## Principais lacunas por fase futura

| Fase | Lacunas principais |
| --- | --- |
| Q2 | Unit/widget/provider/service para RF-003, RF-006, RF-007, RF-008, RF-011, RF-014; reforco dos criticos RF-010, RF-012, RF-013, RF-016/RF-017. |
| Q3 | Contratos Flutter-backend para processos, certidao, perfil, carteira, contracheque, pagamentos, designacoes, concessoes e notificacoes. |
| Q4 | Integracao com banco/contexto real e servicos externos: auth, MPVirtual, JCR, folha/RH, processos, captcha. |
| Q5 | Fluxos completos publico e autenticado, incluindo navegacao principal e documentos/PDF. |
| Q6 | Idempotencia/concorrencia em operacoes de concessao, registro de dispositivo e possiveis duplos envios. |
| Q7 | Offline, timeout, latencia, cache e interrupcoes para carteira, processos, contracheque, pagamentos, concessoes e notificacoes. |
| Q8 | Carga/tempo de resposta para consultas de processos, contracheque, pagamentos e concessoes. |
| Q9 | Matriz Android/iOS/web, resolucoes, orientacao, PDF/compartilhamento nativo. |
| Q10 | Instalacao/upgrade/cache seguro/migracao de dados locais. |
| Q11 | Acessibilidade de formularios, bottom sheets, PDFs e navegacao. |
| Q12 | Observabilidade/resiliencia para Auth API, FCM, MPVirtual, JCR, captcha e dependencias publicas. |
| Q13 | Fuzz/property para parsers, DTOs, datas, filtros e payloads externos. |
| Q14 | UAT com massa institucional e criterios de aceite humano. |

## Bugs encontrados

| ID | Modulo | Pre-condicao | Passos | Esperado | Observado | Evidencia | Impacto | Severidade | Origem provavel |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| BUG-Q1-001 | Concessoes/Afastamentos | Rodar `flutter test` em 2026-09-25 | Executar suite Flutter | Teste `afastamento eleitoral informa numero de dias sem buscar intervalos` passar | `showDatePicker` falha porque `initialDate 2026-09-26` nao satisfaz `selectableDayPredicate`; depois `Bad state: No element` | `Q1-baseline-automatizado.md` | Suite Flutter falha | Alta | Data inicial fixa/dinamica cai em fim de semana ou dia bloqueado |
| BUG-Q1-002 | Concessoes/Afastamentos | Rodar `flutter test` em 2026-09-25 | Executar suite Flutter | Teste `afastamento eleitoral bloqueia periodo com final de semana` passar | Mesma falha de date picker | `Q1-baseline-automatizado.md` | Suite Flutter falha | Alta | Mesmo componente/helper de data |
| BUG-Q1-003 | Concessoes/Afastamentos | Rodar `flutter test` em 2026-09-25 | Executar suite Flutter | Teste `erro da api ao marcar gozo aparece dentro do modal` passar | Mesma falha de date picker | `Q1-baseline-automatizado.md` | Suite Flutter falha | Alta | Mesmo componente/helper de data |

## Bloqueios externos

- Sem dispositivo/emulador Android conectado; `adb devices` retornou lista vazia.
- Sem credenciais/massa autorizada para login valido e area autenticada.
- Sem validacao FCM real/device nativo.
- Smoke web nao substitui instalacao APK nem recursos nativos.

## Recomendacao objetiva para Q2

Escopo recomendado e fechado para Q2:

1. Corrigir ou isolar a instabilidade dos testes existentes de concessoes como primeira tarefa de qualidade, registrando o bug Q1 como origem.
2. Criar testes unitarios/provider/widget para os criticos RF-010, RF-012, RF-013, RF-016 e RF-017.
3. Criar testes iniciais para funcionalidades sem cobertura: RF-003, RF-006, RF-007, RF-008, RF-011 e RF-014.
4. Manter Q2 sem contrato/integracao/E2E amplo; esses itens ficam para Q3/Q4/Q5.

## Arquivos criados/modificados

Criados:

- `qualidade/inventarios/Q1-inventario-funcional.md`
- `qualidade/inventarios/Q1-inventario-testes-existentes.md`
- `qualidade/matrizes/Q1-matriz-cobertura-funcional.md`
- `qualidade/matrizes/Q1-rastreabilidade-funcional.md`
- `qualidade/evidencias/Q1/Q1-baseline-automatizado.md`
- `qualidade/evidencias/Q1/Q1-baseline-runtime.md`
- `qualidade/evidencias/Q1/home-web.png`
- `qualidade/evidencias/Q1/noticias-web.png`
- `qualidade/evidencias/Q1/diario-oficial-web.png`
- `qualidade/evidencias/Q1/processos-web.png`
- `qualidade/evidencias/Q1/certidao-extrajudicial-web.png`
- `qualidade/evidencias/Q1/login-web.png`
- `qualidade/relatorios/Q1-relatorio-final.md`

Modificado pre-existente e nao tocado por esta Q1:

- `pubspec.yaml`
