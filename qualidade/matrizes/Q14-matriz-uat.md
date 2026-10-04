# Q14 — Matriz de Execução UAT

**Data da Execução:** 02/10/2026 a 04/10/2026  
**Ciclo:** Qualidade, Confiabilidade e Prontidão do App MPPB  
**Fase:** Q14 — User Acceptance Testing (UAT) e Aceite Final  
**Dispositivo de Referência:** Samsung Galaxy A52 (`SM-A525M`, Android 14 / One UI 6.1, API 34, Serial `RX8RC09H70X`)  
**Artefato Avaliado:** `br.mp.mppbapp.app.homolog` (v4.0.0+72, APK SHA-256: `B23096118DFD80E3FC8A687B94B994B8622130E33485A786D0A3BFF674971FA7`)  
**Avaliador Institucional:** Rafael Vasconcelos (Analista de Desenvolvimento de Sistema — DITEC)  

---

## 1. Princípios Metodológicos da Matriz

1. **Separação Obrigatória:** Avaliação técnica objetiva (Pré-UAT Técnico) distingue-se claramente da validação negocial institucional (Resultado Humano).
2. **Classificação Rigorosa:** A matriz preserva integralmente os apontamentos e resultados técnicos, incorporando o registro formal da avaliação humana realizada pelo responsável institucional.
3. **Mapeamento 1:1 Canônico:** Exatamente 18 cenários UAT (`Q14-U01` a `Q14-U18`) correspondendo estritamente às 18 jornadas (`Q14-J01` a `Q14-J18`).
4. **Escopo Público (Q14-U01 a Q14-U08):** Executado e validado em bancada física Android e homologado negocialmente.
5. **Escopo Autenticado (Q14-U09 a Q14-U18):** Executado e validado com perfil sintético seguro (`UAT_SYNTHETIC_USERS_ENABLED=true`), cobrindo perfis de Membro (`uat.membro`) e Servidor (`uat.servidor`), e homologado negocialmente.

---

## 2. Matriz Consolidada de Execução (Técnico e Humano)

| ID Cenário | Jornada Correspondente | Evidência Coletada | Resultado Técnico | Resultado Humano | Observação / Ressalva Consolidada |
|---|---|---|---|---|---|
| **Q14-U01** | Q14-J01 — Inicialização, Splash e Primeira Abertura | `android/q14-home.png` | **APROVADO** | **ACEITO** | Inicialização sem falhas, splash institucional exibido, alcance imediato da Home pública. |
| **Q14-U02** | Q14-J02 — Navegação na Home Pública e Serviços ao Cidadão | `android/q14-home.png` | **APROVADO** | **ACEITO** | Grade de 6 serviços ao cidadão, carrossel de notícias, botão de login e badges funcionais. |
| **Q14-U03** | Q14-J03 — Consulta, Listagem e Leitura de Notícias | `android/q14-noticias.png`, `android/q14-noticia-detalhe.png` | **APROVADO** | **ACEITO** | Listagem via API, busca, tags de categoria, abertura de notícia em modal com foto e texto, retorno limpo. |
| **Q14-U04** | Q14-J04 — Acesso ao Diário Oficial e Edições Recentes | `android/q14-diario.png`, `android/q14-diario-loaded.png` | **APROVADO** | **ACEITO COM RESSALVA** | Técnico: PDF renderizado. Humano: OBSERVAÇÃO-HUMANA-Q14-001 (mensagem de erro de conexão ao carregar no ambiente UAT). |
| **Q14-U05** | Q14-J05 — Consulta Pública de Processos e Filtros | `android/q14-processos.png` | **APROVADO COM RESSALVA** | **ACEITO COM RESSALVA** | Técnico: validação de campos. Humano: OBSERVAÇÃO-HUMANA-Q14-003 (falha/lentidão no carregamento de filtros no ambiente UAT). |
| **Q14-U06** | Q14-J06 — Consulta de Canais de Atendimento e Contatos | `android/q14-contatos.png` | **APROVADO COM RESSALVA** | **ACEITO** | Técnico: handoffs externos preservados. Humano: contatos e canais claros e plenamente acessíveis. |
| **Q14-U07** | Q14-J07 — Solicitação e Validação de Certidão Extrajudicial | `android/q14-certidao.png` | **APROVADO COM RESSALVA** | **ACEITO** | Técnico: formulário e validações aferidas. Humano: fluxo claro e interface satisfatória. |
| **Q14-U08** | Q14-J08 — Registro de Manifestação na Ouvidoria | `android/q14-ouvidoria.png` | **APROVADO COM RESSALVA** | **ACEITO** | Técnico: 5 passos validados. Humano: etapas de manifestação bem estruturadas e intuitivas. |
| **Q14-U09** | Q14-J09 — Acesso Restrito / Autenticação Institucional (Login) | `android/q14-uat-login-invalido.png`, `android/q14-uat-membro-dashboard.png`, `android/q14-uat-servidor-dashboard.png` | **APROVADO** | **ACEITO** | Rejeição de credencial inválida e login seguro com transição imediata para dashboards. |
| **Q14-U10** | Q14-J10 — Home Autenticada, Dashboard Restrito e Logout | `android/q14-uat-sessao-persistencia.png`, `android/q14-uat-membro-dashboard.png`, `android/q14-uat-logout-home.png` | **APROVADO** | **ACEITO** | Persistência de sessão validada após reinício do app; logout encerra sessão e retorna à Home pública. |
| **Q14-U11** | Q14-J11 — Consulta e Visualização do Perfil Funcional | `android/q14-uat-membro-perfil.png`, `android/q14-uat-membro-perfil-detalhes.png`, `android/q14-uat-servidor-perfil.png` | **APROVADO** | **ACEITO** | Exibição íntegra dos dados cadastrais e funcionais para Membro e Servidora. |
| **Q14-U12** | Q14-J12 — Visualização da Carteira Funcional Digital | `android/q14-uat-carteira-membro.png`, `android/q14-uat-carteira-membro-verso.png`, `android/q14-uat-carteira-servidor.png` | **APROVADO** | **ACEITO** | Renderização oficial dos cartões e verso com marca d'água antifalsificação. |
| **Q14-U13** | Q14-J13 — Consulta de Contracheques e Exportação PDF | `android/q14-uat-contracheque.png`, `android/q14-uat-contracheque-valores.png`, `android/q14-uat-contracheque-pdf.png`, `android/q14-uat-contracheque-servidor.png` | **APROVADO** | **ACEITO** | Listagem de competências, controle de privacidade de valores e geração de PDF. |
| **Q14-U14** | Q14-J14 — Consulta de Informações de Pagamentos | `android/q14-uat-pagamentos.png`, `android/q14-uat-pagamentos-2025.png`, `android/q14-uat-pagamentos-servidor.png`, `android/q14-uat-pagamentos-vazio.png` | **APROVADO** | **ACEITO** | Consulta por exercícios fiscais e tratamento informativo de anos sem lançamento. |
| **Q14-U15** | Q14-J15 — Consulta de Designações Funcionais Ativas | `android/q14-uat-designacoes-membro.png`, `android/q14-uat-designacoes-vazio.png` | **APROVADO** | **ACEITO** | Designações listadas para Membro e estado vazio amigável para Servidora. |
| **Q14-U16** | Q14-J16 — Consulta de Concessões de Folga e Ausências | `android/q14-uat-concessoes-baseline.png`, `android/q14-uat-concessoes-saldos.png`, `android/q14-uat-concessoes-servidor.png` | **APROVADO** | **ACEITO** | Calendário de gozo e aba de saldos de concessões apurados com clareza. |
| **Q14-U17** | Q14-J17 — Operações de Solicitação de Concessões/Folgas | `android/q14-uat-concessoes-solicitada.png`, `android/q14-uat-concessoes-detalhes-cancelada.png` | **APROVADO** | **ACEITO COM RESSALVA** | Técnico: fluxo operacional e autorização por objeto comprovados. Humano: OBSERVAÇÃO-HUMANA-Q14-002 (comportamento de ações no sandbox sintético). |
| **Q14-U18** | Q14-J18 — Diagnóstico e Registro de Notificações Push (FCM) | Log de auditoria backend (`mobile-service`) | **APROVADO COM RESSALVA** | **ACEITO** | Técnico: sandbox FCM com isolamento. Humano: diagnóstico funcional e status aceitos. |

---

## 3. Consolidação Estatística

### 3.1 Pré-UAT Técnico
- **Total de Cenários Avaliados:** 18 / 18 (100%)
- **APROVADO (sem ressalva):** 13 / 18 (72,2%)
- **APROVADO COM RESSALVA:** 5 / 18 (27,8%) (Q14-U05, Q14-U06, Q14-U07, Q14-U08, Q14-U18)
- **REPROVADO:** 0 / 18 (0%)
- **BLOQUEADO:** 0 / 18 (0%)

### 3.2 Avaliação Humana Institucional
- **Total de Jornadas Avaliadas:** 18 / 18 (100%)
- **ACEITO (sem ressalva):** 15 / 18 (83,3%)
- **ACEITO COM RESSALVA:** 3 / 18 (16,7%) (Q14-J04, Q14-J05, Q14-J17)
- **NÃO ACEITO:** 0 / 18 (0%)
- **NÃO AVALIADO:** 0 / 18 (0%)
- **Bugs Confirmados Durante o Aceite:** 0

---

## 4. Estado das Deliberações Institucionais

- **PRÉ-UAT TÉCNICO:** **APROVADO COM RESSALVAS**
- **AVALIAÇÃO HUMANA:** **EXECUTADA** (Avaliador: Rafael Vasconcelos — DITEC)
- **ACEITE HUMANO:** **ACEITO INTEGRALMENTE**
- **GOOGLE/APPLE STORE REVIEW:** **NÃO PRONTO — BLOQUEIO-Q14-REVIEW-001**
  - Contas REVIEW ainda não provisionadas operacionalmente;
  - Backend externo acessível aos revisores ainda não definido/implantado;
  - Modo sintético permanece bloqueado em produção;
  - Estratégia de Store Review será tratada de forma separada e posterior ao aceite funcional.
- **Status Canônico da Fase:** **Q14 CONCLUÍDA — PRÉ-UAT TÉCNICO CONSOLIDADO E ACEITE HUMANO INSTITUCIONAL REALIZADO**.
- **Status do Ciclo:** **CICLO Q1–Q14 CONCLUÍDO**.
