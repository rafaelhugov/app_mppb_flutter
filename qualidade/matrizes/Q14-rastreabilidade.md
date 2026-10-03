# Q14 — Matriz de Rastreabilidade UAT

**Data da Auditoria:** 02/10/2026  
**Ciclo:** Qualidade, Confiabilidade e Prontidão do App MPPB  
**Fase:** Q14 — User Acceptance Testing (UAT) e Aceite Final  
**Escopo:** Mapeamento Requisitos (Q1) → Jornadas (Q14-J) → Cenários UAT (Q14-U) → Evidências → Resultados → Apontamentos

---

## 1. Rastreabilidade Ponta a Ponta (18 Jornadas 1:1)

| Requisito (Q1) | Descrição do Requisito | Jornada | Cenário UAT | Evidência Coletada | Resultado Técnico | Apontamento / Ressalva |
|---|---|---|---|---|---|---|
| **RF-001** | Inicialização, conectividade e Home pública | Q14-J01 / Q14-J02 | Q14-U01 / Q14-U02 | `android/q14-home.png` | **APROVADO** | Nenhum |
| **RF-002** | Notícias e detalhe informativo | Q14-J03 | Q14-U03 | `android/q14-noticias.png`, `android/q14-noticia-detalhe.png` | **APROVADO** | Nenhum |
| **RF-003** | Diário Oficial (atos, editais e edições) | Q14-J04 | Q14-U04 | `android/q14-diario.png`, `android/q14-diario-loaded.png` | **APROVADO** | Renderização in-app do PDF validada com sucesso |
| **RF-004** | Consulta pública de processos | Q14-J05 | Q14-U05 | `android/q14-processos.png` | **APROVADO COM RESSALVA** | Interface e validações aferidas; busca com processo real omitida por falta de massa UAT |
| **RF-005** | Detalhe público de processo / filtros | Q14-J05 | Q14-U05 | `android/q14-processos.png` | **APROVADO COM RESSALVA** | Filtros adicionais verificados em tela física |
| **RF-006** | Certidão extrajudicial (emissão) | Q14-J07 | Q14-U07 | `android/q14-certidao.png` | **APROVADO COM RESSALVA** | Formulário e validação local aferidos; emissão real omitida por integridade |
| **RF-007** | Certidão extrajudicial (código/validação) | Q14-J07 | Q14-U07 | `android/q14-certidao.png` | **APROVADO COM RESSALVA** | Aba Validar presente e alternável |
| **RF-008** | Ouvidoria (manifestações públicas) | Q14-J08 | Q14-U08 | `android/q14-ouvidoria.png` | **APROVADO COM RESSALVA** | Interface de 5 passos e validação local aferidas; submissão real omitida por segurança |
| **RF-009** | Contatos e atendimento institucional | Q14-J06 | Q14-U06 | `android/q14-contatos.png` | **APROVADO** | Telefones, endereços, horários e ouvidoria exibidos |
| **RF-010** | Autenticação institucional e sessão | Q14-J09 / Q14-J10 | Q14-U09 / Q14-U10 | `android/q14-login.png` | **BLOQUEADO** | OBS-Q14-001 (Ausência de credencial institucional autorizada) |
| **RF-011** | Perfil funcional do servidor | Q14-J11 | Q14-U11 | EVIDÊNCIA HERDADA | **BLOQUEADO** | OBS-Q14-001 |
| **RF-012** | Carteira funcional digital | Q14-J12 | Q14-U12 | EVIDÊNCIA HERDADA | **BLOQUEADO** | OBS-Q14-001 |
| **RF-013** | Contracheque e holerite | Q14-J13 | Q14-U13 | EVIDÊNCIA HERDADA | **BLOQUEADO** | OBS-Q14-001 |
| **RF-014** | Informações financeiras de pagamentos | Q14-J14 | Q14-U14 | EVIDÊNCIA HERDADA | **BLOQUEADO** | OBS-Q14-001 |
| **RF-015** | Designações funcionais ativas | Q14-J15 | Q14-U15 | EVIDÊNCIA HERDADA | **BLOQUEADO** | OBS-Q14-001 |
| **RF-016** | Concessões e afastamentos (consulta) | Q14-J16 | Q14-U16 | EVIDÊNCIA HERDADA | **BLOQUEADO** | OBS-Q14-001 |
| **RF-017** | Concessões e afastamentos (operações) | Q14-J17 | Q14-U17 | EVIDÊNCIA HERDADA | **BLOQUEADO** | OBS-Q14-001 |
| **RF-018** | Dispositivo e notificações push | Q14-J18 | Q14-U18 | EVIDÊNCIA HERDADA | **BLOQUEADO** | OBS-Q14-001 |
| **RF-019** | Navegação complementar e layout | Q14-J02 | Q14-U02 | `android/q14-home.png` | **APROVADO** | Nenhum |

---

## 2. Análise de Cobertura de Requisitos

- **Total de Requisitos Auditados:** 19 (RF-001 a RF-019)
- **Requisitos do Escopo Público:** 9 requisitos (RF-001, RF-002, RF-003, RF-004, RF-005, RF-006, RF-007, RF-008, RF-009, RF-019)
  - Aprovados sem ressalva: 5 (RF-001, RF-002, RF-003, RF-009, RF-019)
  - Aprovados com ressalva: 4 (RF-004, RF-005, RF-006, RF-007, RF-008 — ressalvas operacionais de integridade sem falha técnica)
  - Reprovados: 0
- **Requisitos do Escopo Autenticado:** 9 requisitos (RF-010, RF-011, RF-012, RF-013, RF-014, RF-015, RF-016, RF-017, RF-018)
  - Bloqueados: 9 (100% dos autenticados, decorrente estritamente de `OBS-Q14-001`)
- **Bugs Funcionais Detectados:** Zero.
