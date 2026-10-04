# Q14 — Matriz de Rastreabilidade UAT

**Data da Auditoria:** 02/10/2026 a 04/10/2026  
**Ciclo:** Qualidade, Confiabilidade e Prontidão do App MPPB  
**Fase:** Q14 — User Acceptance Testing (UAT) e Aceite Final  
**Escopo:** Mapeamento Requisitos (Q1) → Jornadas (Q14-J) → Cenários UAT (Q14-U) → Evidências → Resultados → Apontamentos  
**Executor:** `TÉCNICO` (Avaliação objetiva de pré-requisito técnico; não substitui o Aceite Humano Institucional)

---

## 1. Rastreabilidade Ponta a Ponta (18 Jornadas 1:1)

| Requisito (Q1) | Descrição do Requisito | Jornada | Cenário UAT | Evidência Coletada | Resultado Técnico | Apontamento / Ressalva |
|---|---|---|---|---|---|---|
| **RF-001** | Inicialização, conectividade e Home pública | Q14-J01 / Q14-J02 | Q14-U01 / Q14-U02 | `android/q14-home.png` | **APROVADO** | Nenhum |
| **RF-002** | Notícias e detalhe informativo | Q14-J03 | Q14-U03 | `android/q14-noticias.png`, `android/q14-noticia-detalhe.png` | **APROVADO** | Nenhum |
| **RF-003** | Diário Oficial (atos, editais e edições) | Q14-J04 | Q14-U04 | `android/q14-diario.png`, `android/q14-diario-loaded.png` | **APROVADO** | Renderização in-app do PDF validada com sucesso |
| **RF-004** | Consulta pública de processos | Q14-J05 | Q14-U05 | `android/q14-processos.png` | **APROVADO COM RESSALVA** | Interface e validações aferidas; busca com processo real omitida por falta de processo de teste homologado |
| **RF-005** | Detalhe público de processo / filtros | Q14-J05 | Q14-U05 | `android/q14-processos.png` | **APROVADO COM RESSALVA** | Filtros adicionais verificados em tela física |
| **RF-006** | Certidão extrajudicial (emissão) | Q14-J07 | Q14-U07 | `android/q14-certidao.png` | **APROVADO COM RESSALVA** | Formulário e validação local aferidos; emissão real omitida por integridade |
| **RF-007** | Certidão extrajudicial (código/validação) | Q14-J07 | Q14-U07 | `android/q14-certidao.png` | **APROVADO COM RESSALVA** | Aba Validar presente e alternável |
| **RF-008** | Ouvidoria (manifestações públicas) | Q14-J08 | Q14-U08 | `android/q14-ouvidoria.png` | **APROVADO COM RESSALVA** | Interface de 5 passos e validação local aferidas; submissão real omitida por segurança |
| **RF-009** | Contatos e atendimento institucional | Q14-J06 | Q14-U06 | `android/q14-contatos.png` | **APROVADO COM RESSALVA** | Presença visual de botões e canais aferida; handoffs para discador/mapa não disparados para evitar ligações ou aberturas externas espúrias |
| **RF-010** | Autenticação institucional e sessão | Q14-J09 / Q14-J10 | Q14-U09 / Q14-U10 | `android/q14-uat-login-invalido.png`, `android/q14-uat-membro-dashboard.png`, `android/q14-uat-sessao-persistencia.png`, `android/q14-uat-logout-home.png` | **APROVADO** | Login institucional, rejeição de credenciais inválidas, persistência de token com force-stop e logout validados |
| **RF-011** | Perfil funcional do servidor/membro | Q14-J11 | Q14-U11 | `android/q14-uat-membro-perfil.png`, `android/q14-uat-membro-perfil-detalhes.png`, `android/q14-uat-servidor-perfil.png` | **APROVADO** | Exibição de dados funcionais completos para Membro e Servidora |
| **RF-012** | Carteira funcional digital | Q14-J12 | Q14-U12 | `android/q14-uat-carteira-membro.png`, `android/q14-uat-carteira-membro-verso.png`, `android/q14-uat-carteira-servidor.png` | **APROVADO** | Layouts oficiais com brasão e monogramas; verso com marca d'água de proteção |
| **RF-013** | Contracheque e holerite | Q14-J13 | Q14-U13 | `android/q14-uat-contracheque.png`, `android/q14-uat-contracheque-valores.png`, `android/q14-uat-contracheque-pdf.png`, `android/q14-uat-contracheque-servidor.png` | **APROVADO** | Competências consultadas, alternador de privacidade e PDF gerado com marca d'água sintética |
| **RF-014** | Informações financeiras de pagamentos | Q14-J14 | Q14-U14 | `android/q14-uat-pagamentos.png`, `android/q14-uat-pagamentos-2025.png`, `android/q14-uat-pagamentos-servidor.png`, `android/q14-uat-pagamentos-vazio.png` | **APROVADO** | Exercícios 2026/2025 e estado vazio para anos sem registro |
| **RF-015** | Designações funcionais ativas | Q14-J15 | Q14-U15 | `android/q14-uat-designacoes-membro.png`, `android/q14-uat-designacoes-vazio.png` | **APROVADO** | Portaria 101/2025 ativa para Membro; estado vazio informativo para Servidora |
| **RF-016** | Concessões e afastamentos (consulta) | Q14-J16 | Q14-U16 | `android/q14-uat-concessoes-baseline.png`, `android/q14-uat-concessoes-saldos.png`, `android/q14-uat-concessoes-servidor.png` | **APROVADO** | Calendário e saldos de concessões para ambos os perfis |
| **RF-017** | Concessões e afastamentos (operações) | Q14-J17 | Q14-U17 | `android/q14-uat-concessoes-solicitada.png`, `android/q14-uat-concessoes-detalhes-cancelada.png` | **APROVADO** | Seleção de data, submissão de gozo de 15 dias, cancelamento subsequente e isolamento de leitura e operação entre datasets comprovado (tentativa cruzada rejeitada com 403 Forbidden). Correção de BUG-Q14-001 validada. |
| **RF-018** | Dispositivo e notificações push | Q14-J18 | Q14-U18 | Log de auditoria backend (`mobile-service`) | **APROVADO COM RESSALVA** | registro e desativação FCM validados em sandbox; entrega de push real não aferida. |
| **RF-019** | Navegação complementar e layout | Q14-J02 | Q14-U02 | `android/q14-home.png` | **APROVADO** | Navegação por abas e botões inferiores íntegros |

---

## 2. Análise de Cobertura de Requisitos

- **Total de Requisitos Auditados:** 19 (RF-001 a RF-019)
- **Requisitos do Escopo Público:** 10 requisitos (RF-001, RF-002, RF-003, RF-004, RF-005, RF-006, RF-007, RF-008, RF-009, RF-019)
  - Aprovados sem ressalva: 4 (RF-001, RF-002, RF-003, RF-019)
  - Aprovados com ressalva: 6 (RF-004, RF-005, RF-006, RF-007, RF-008, RF-009 — ressalvas operacionais sem falha de código)
  - Reprovados: 0
  - Bloqueados: 0
- **Requisitos do Escopo Autenticado:** 9 requisitos (RF-010, RF-011, RF-012, RF-013, RF-014, RF-015, RF-016, RF-017, RF-018)
  - Aprovados sem ressalva: 8 (RF-010, RF-011, RF-012, RF-013, RF-014, RF-015, RF-016, RF-017)
  - Aprovados com ressalva: 1 (RF-018 — registro e desativação FCM validados em sandbox; entrega de push real não aferida)
  - Reprovados: 0
  - Bloqueados: 0
- **Total Geral de Cobertura:** 19 / 19 Requisitos Atendidos (100% dos requisitos cobertos no Pré-UAT Técnico).
- **Bugs Corrigidos na Rodada:** 2 (BUG-Q14-001 e BUG-Q14-002), revalidados no aparelho físico com êxito.
