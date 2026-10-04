# Q14 — Matriz de Rastreabilidade UAT

**Data da Auditoria:** 02/10/2026 a 04/10/2026  
**Ciclo:** Qualidade, Confiabilidade e Prontidão do App MPPB  
**Fase:** Q14 — User Acceptance Testing (UAT) e Aceite Final  
**Escopo:** Mapeamento Requisitos (Q1) → Jornadas (Q14-J) → Cenários UAT (Q14-U) → Evidências → Pré-UAT Técnico → Resultado Humano → Apontamentos  
**Avaliador Institucional:** Rafael Vasconcelos (Analista de Desenvolvimento de Sistema — DITEC)  

---

## 1. Rastreabilidade Ponta a Ponta (18 Jornadas 1:1)

| Requisito (Q1) | Descrição do Requisito | Jornada | Cenário UAT | Evidência Coletada | Pré-UAT Técnico | Resultado Humano | Apontamento / Observação |
|---|---|---|---|---|---|---|---|
| **RF-001** | Inicialização, conectividade e Home pública | Q14-J01 / Q14-J02 | Q14-U01 / Q14-U02 | `android/q14-home.png` | **APROVADO** | **ACEITO** | Inicialização e navegação fluida |
| **RF-002** | Notícias e detalhe informativo | Q14-J03 | Q14-U03 | `android/q14-noticias.png`, `android/q14-noticia-detalhe.png` | **APROVADO** | **ACEITO** | Listagem e leitura de notícias |
| **RF-003** | Diário Oficial (atos, editais e edições) | Q14-J04 | Q14-U04 | `android/q14-diario.png`, `android/q14-diario-loaded.png` | **APROVADO** | **ACEITO COM RESSALVA** | Técnico: PDF renderizado in-app; Humano: OBSERVAÇÃO-HUMANA-Q14-001 (falha de conexão UAT) |
| **RF-004** | Consulta pública de processos | Q14-J05 | Q14-U05 | `android/q14-processos.png` | **APROVADO COM RESSALVA** | **ACEITO COM RESSALVA** | Validação de campos aferida; Humano: OBSERVAÇÃO-HUMANA-Q14-003 (filtros no UAT) |
| **RF-005** | Detalhe público de processo / filtros | Q14-J05 | Q14-U05 | `android/q14-processos.png` | **APROVADO COM RESSALVA** | **ACEITO COM RESSALVA** | Filtros adicionais verificados em tela física |
| **RF-006** | Certidão extrajudicial (emissão) | Q14-J07 | Q14-U07 | `android/q14-certidao.png` | **APROVADO COM RESSALVA** | **ACEITO** | Formulário e validação local aferidos |
| **RF-007** | Certidão extrajudicial (código/validação) | Q14-J07 | Q14-U07 | `android/q14-certidao.png` | **APROVADO COM RESSALVA** | **ACEITO** | Aba Validar presente e navegável |
| **RF-008** | Ouvidoria (manifestações públicas) | Q14-J08 | Q14-U08 | `android/q14-ouvidoria.png` | **APROVADO COM RESSALVA** | **ACEITO** | Formulário de 5 passos e validação aferidas |
| **RF-009** | Contatos e atendimento institucional | Q14-J06 | Q14-U06 | `android/q14-contatos.png` | **APROVADO COM RESSALVA** | **ACEITO** | Presença visual e acessibilidade das informações |
| **RF-010** | Autenticação institucional e sessão | Q14-J09 / Q14-J10 | Q14-U09 / Q14-U10 | `android/q14-uat-login-invalido.png`, `android/q14-uat-membro-dashboard.png`, `android/q14-uat-sessao-persistencia.png`, `android/q14-uat-logout-home.png` | **APROVADO** | **ACEITO** | Login institucional, rejeição de inválidos, persistência de token e logout validados |
| **RF-011** | Perfil funcional do servidor/membro | Q14-J11 | Q14-U11 | `android/q14-uat-membro-perfil.png`, `android/q14-uat-membro-perfil-detalhes.png`, `android/q14-uat-servidor-perfil.png` | **APROVADO** | **ACEITO** | Dados funcionais exibidos para Membro e Servidora |
| **RF-012** | Carteira funcional digital | Q14-J12 | Q14-U12 | `android/q14-uat-carteira-membro.png`, `android/q14-uat-carteira-membro-verso.png`, `android/q14-uat-carteira-servidor.png` | **APROVADO** | **ACEITO** | Layouts oficiais com brasão e monogramas; verso com marca d'água antifalsificação |
| **RF-013** | Contracheque e holerite | Q14-J13 | Q14-U13 | `android/q14-uat-contracheque.png`, `android/q14-uat-contracheque-valores.png`, `android/q14-uat-contracheque-pdf.png`, `android/q14-uat-contracheque-servidor.png` | **APROVADO** | **ACEITO** | Competências consultadas, alternador de privacidade e PDF gerado |
| **RF-014** | Informações financeiras de pagamentos | Q14-J14 | Q14-U14 | `android/q14-uat-pagamentos.png`, `android/q14-uat-pagamentos-2025.png`, `android/q14-uat-pagamentos-servidor.png`, `android/q14-uat-pagamentos-vazio.png` | **APROVADO** | **ACEITO** | Exercícios 2026/2025 e estado vazio para anos sem registro |
| **RF-015** | Designações funcionais ativas | Q14-J15 | Q14-U15 | `android/q14-uat-designacoes-membro.png`, `android/q14-uat-designacoes-vazio.png` | **APROVADO** | **ACEITO** | Portaria 101/2025 para Membro; estado vazio informativo para Servidora |
| **RF-016** | Concessões e afastamentos (consulta) | Q14-J16 | Q14-U16 | `android/q14-uat-concessoes-baseline.png`, `android/q14-uat-concessoes-saldos.png`, `android/q14-uat-concessoes-servidor.png` | **APROVADO** | **ACEITO** | Calendário e saldos de concessões consultados |
| **RF-017** | Concessões e afastamentos (operações) | Q14-J17 | Q14-U17 | `android/q14-uat-concessoes-solicitada.png`, `android/q14-uat-concessoes-detalhes-cancelada.png` | **APROVADO** | **ACEITO COM RESSALVA** | Técnico: agendamento, cancelamento e isolamento cross-object. Humano: OBSERVAÇÃO-HUMANA-Q14-002 (ações no sandbox) |
| **RF-018** | Dispositivo e notificações push | Q14-J18 | Q14-U18 | Log de auditoria backend (`mobile-service`) | **APROVADO COM RESSALVA** | **ACEITO** | Sandbox FCM com isolamento; status e permissões verificados |
| **RF-019** | Navegação complementar e layout | Q14-J02 | Q14-U02 | `android/q14-home.png` | **APROVADO** | **ACEITO** | Navegação por abas e botões inferiores íntegros |

---

## 2. Análise de Cobertura de Requisitos e Decisão Negocial

- **Total de Requisitos Auditados:** 19 (RF-001 a RF-019)
- **Cobertura Geral:** 19 / 19 Requisitos Cobertos (100%)
- **Pré-UAT Técnico:** Aprovado com Ressalvas (13 aprovados, 5 aprovados com ressalva, 0 reprovados)
- **Avaliação Humana (18 Jornadas):** 15 Aceitas, 3 Aceitas com Ressalva, 0 Não Aceitas
- **Decisão do Avaliador Institucional:** **ACEITO INTEGRALMENTE**
- **Bugs Corrigidos e Validados no Pré-UAT:** 3 (BUG-Q14-001, BUG-Q14-002, BUG-Q14-003)
- **Bugs Confirmados Durante o Aceite Humano:** 0
- **Gates Canônicos Finais:**
  - Flutter: 244/244 testes aprovados (100%), analyze = 0 issues
  - Backend: 202/202 testes aprovados (100%), package = PASS
- **Status da Fase:** **Q14 CONCLUÍDA — PRÉ-UAT TÉCNICO CONSOLIDADO E ACEITE HUMANO INSTITUCIONAL REALIZADO**
- **Status do Ciclo:** **CICLO Q1–Q14 CONCLUÍDO**
