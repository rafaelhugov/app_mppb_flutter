# Q14 — Matriz de Execução UAT

**Data da Execução:** 02/10/2026 a 04/10/2026  
**Ciclo:** Qualidade, Confiabilidade e Prontidão do App MPPB  
**Fase:** Q14 — User Acceptance Testing (UAT) e Aceite Final  
**Dispositivo de Referência:** Samsung Galaxy A52 (`SM-A525M`, Android 14 / One UI 6.1, API 34, Serial `RX8RC09H70X`)  
**Artefato Avaliado:** `br.mp.mppbapp.app.homolog` (v4.0.0+72, APK SHA-256: `B23096118DFD80E3FC8A687B94B994B8622130E33485A786D0A3BFF674971FA7`)  
**Executor:** `TÉCNICO` (Avaliação objetiva de pré-requisito técnico; não substitui o Aceite Humano Institucional)

---

## 1. Princípios Metodológicos da Matriz

1. **Separação Obrigatória:** Avaliação técnica objetiva (Pré-UAT) não se confunde com aceite negocial formal (Aceite Humano).
2. **Classificação Rigorosa:** Nenhuma jornada pode ser marcada como aceite humano enquanto a homologação com usuários reais estiver pendente.
3. **Mapeamento 1:1 Canônico:** Exatamente 18 cenários UAT (`Q14-U01` a `Q14-U18`) correspondendo estritamente às 18 jornadas (`Q14-J01` a `Q14-J18`).
4. **Escopo Público (Q14-U01 a Q14-U08):** Executado integralmente de forma técnica no aparelho físico Galaxy A52 e validado com sucesso ou ressalva metodológica/operacional.
5. **Escopo Autenticado (Q14-U09 a Q14-U18):** Executado integralmente de forma técnica no aparelho físico Galaxy A52 utilizando backend com perfil sintético seguro (`UAT_SYNTHETIC_USERS_ENABLED=true`), com perfis de Membro (`uat.membro`) e Servidor (`uat.servidor`).

---

## 2. Matriz de Cenários e Resultados (18 Jornadas 1:1)

| ID Cenário | Jornada Correspondente | Evidência Coletada | Executor | Resultado Técnico | Ressalva / Justificativa |
|---|---|---|---|---|---|
| **Q14-U01** | Q14-J01 — Inicialização, Splash e Primeira Abertura | `android/q14-home.png` | TÉCNICO | **APROVADO** | Inicialização sem falhas, splash institucional exibido, alcance imediato da Home pública. |
| **Q14-U02** | Q14-J02 — Navegação na Home Pública e Serviços ao Cidadão | `android/q14-home.png` | TÉCNICO | **APROVADO** | Grade de 6 serviços ao cidadão, carrossel de notícias, botão de login e badges funcionais. |
| **Q14-U03** | Q14-J03 — Consulta, Listagem e Leitura de Notícias | `android/q14-noticias.png`, `android/q14-noticia-detalhe.png` | TÉCNICO | **APROVADO** | Listagem via API, busca, tags de categoria, abertura de notícia em modal com foto e texto, retorno limpo à lista e à Home. |
| **Q14-U04** | Q14-J04 — Acesso ao Diário Oficial e Edições Recentes | `android/q14-diario.png`, `android/q14-diario-loaded.png` | TÉCNICO | **APROVADO** | Edições recentes listadas com destaque para Última Edição (Nº 3160); renderização completa do documento PDF no visualizador in-app. |
| **Q14-U05** | Q14-J05 — Consulta Pública de Processos e Filtros | `android/q14-processos.png` | TÉCNICO | **APROVADO COM RESSALVA** | Interface, filtros e validação de submissão aferidos (alerta orientativo e mensagem de campo obrigatório); consulta com processo conhecido e resultado positivo não aferida por ausência de processo de teste homologado. |
| **Q14-U06** | Q14-J06 — Consulta de Canais de Atendimento e Contatos | `android/q14-contatos.png` | TÉCNICO | **APROVADO COM RESSALVA** | Presença visual e renderização dos botões 'Ligar' e 'Mapa', telefone, endereço, horários e ouvidoria aferidas na tela física; handoffs reais para discador e mapa não disparados para evitar ligações ou aberturas externas espúrias. |
| **Q14-U07** | Q14-J07 — Solicitação e Validação de Certidão Extrajudicial | `android/q14-certidao.png` | TÉCNICO | **APROVADO COM RESSALVA** | Interface e validações locais aferidas (alternância CPF/CNPJ, validações visuais de formato e obrigatoriedade); emissão/validação positiva contra base extrajudicial real não executada por integridade de registros públicos. |
| **Q14-U08** | Q14-J08 — Registro de Manifestação na Ouvidoria | `android/q14-ouvidoria.png` | TÉCNICO | **APROVADO COM RESSALVA** | Interface, fluxo de identificação em 5 passos (Identif., Classif., Relato, Anexos, Revisão), alternância de manifestação anônima e validação local aferidas; submissão e geração de protocolo oficial deliberadamente omitidas por segurança operacional. |
| **Q14-U09** | Q14-J09 — Acesso Restrito / Autenticação Institucional (Login) | `android/q14-uat-login-invalido.png`, `android/q14-uat-membro-dashboard.png`, `android/q14-uat-servidor-dashboard.png` | TÉCNICO | **APROVADO** | Credencial inválida rejeitada com HTTP 401 e mensagem amigável; autenticação institucional efetuada com sucesso para Membro e Servidor com perfil sintético seguro, emissão de JWT e direcionamento aos dashboards. |
| **Q14-U10** | Q14-J10 — Home Autenticada, Dashboard Restrito e Logout | `android/q14-uat-sessao-persistencia.png`, `android/q14-uat-membro-dashboard.png`, `android/q14-uat-logout-home.png` | TÉCNICO | **APROVADO** | Persistência de token validada via reinicialização do app sem perda de sessão; logout executado com sucesso e retorno à Home pública desautenticada. |
| **Q14-U11** | Q14-J11 — Consulta e Visualização do Perfil Funcional | `android/q14-uat-membro-perfil.png`, `android/q14-uat-membro-perfil-detalhes.png`, `android/q14-uat-servidor-perfil.png` | TÉCNICO | **APROVADO** | Exibição íntegra dos dados cadastrais e funcionais para Membro (Lucas Almeida Monteiro) e Servidora (Mariana Costa Ribeiro). |
| **Q14-U12** | Q14-J12 — Visualização da Carteira Funcional Digital | `android/q14-uat-carteira-membro.png`, `android/q14-uat-carteira-membro-verso.png`, `android/q14-uat-carteira-servidor.png` | TÉCNICO | **APROVADO** | Renderização dos cartões nos modelos oficiais com brasão do MPPB e monogramas; verso verificado com marca d'água de proteção contra falsificação funcional. |
| **Q14-U13** | Q14-J13 — Consulta de Contracheques e Exportação PDF | `android/q14-uat-contracheque.png`, `android/q14-uat-contracheque-valores.png`, `android/q14-uat-contracheque-pdf.png`, `android/q14-uat-contracheque-servidor.png` | TÉCNICO | **APROVADO** | Competências consultadas, alternador de privacidade validado e documento PDF gerado com marca d'água indelével. |
| **Q14-U14** | Q14-J14 — Consulta de Informações de Pagamentos | `android/q14-uat-pagamentos.png`, `android/q14-uat-pagamentos-2025.png`, `android/q14-uat-pagamentos-servidor.png`, `android/q14-uat-pagamentos-vazio.png` | TÉCNICO | **APROVADO** | Consulta por exercício fiscal (2026 e 2025), exibição de parcelas e tratamento de anos sem histórico com estado vazio amigável. |
| **Q14-U15** | Q14-J15 — Consulta de Designações Funcionais Ativas | `android/q14-uat-designacoes-membro.png`, `android/q14-uat-designacoes-vazio.png` | TÉCNICO | **APROVADO** | Designação ativa listada para Membro (Portaria 101/2025) e estado vazio amigável exibido para Servidora sem designações vigentes. |
| **Q14-U16** | Q14-J16 — Consulta de Concessões de Folga e Ausências | `android/q14-uat-concessoes-baseline.png`, `android/q14-uat-concessoes-saldos.png`, `android/q14-uat-concessoes-servidor.png` | TÉCNICO | **APROVADO** | Calendário de gozo e saldos de Férias/Folgas exibidos perfeitamente para Membro e Servidora. |
| **Q14-U17** | Q14-J17 — Operações de Solicitação de Concessões/Folgas | `android/q14-uat-concessoes-solicitada.png`, `android/q14-uat-concessoes-detalhes-cancelada.png` | TÉCNICO | **APROVADO** | Fluxo completo operacionalizado: agendamento de gozo (15 dias a partir de 05/10/2026), submissão com sucesso, cancelamento subsequente e isolamento de leitura e operação entre datasets comprovado (tentativa cruzada rejeitada com 403 Forbidden). |
| **Q14-U18** | Q14-J18 — Diagnóstico e Registro de Notificações Push (FCM) | Log de auditoria backend (`mobile-service`) | TÉCNICO | **APROVADO COM RESSALVA** | registro e desativação FCM validados em sandbox; entrega de push real não aferida. |

---

## 3. Consolidação Estatística

- **Total de Jornadas Mapeadas:** 18
- **Total de Cenários UAT Avaliados:** 18 (1:1 com as jornadas)
- **Escopo Público (Q14-U01 a Q14-U08):**
  - Executados: 8 (100% dos públicos)
  - Aprovados sem ressalva: 4 (Q14-U01, Q14-U02, Q14-U03, Q14-U04)
  - Aprovados com ressalva: 4 (Q14-U05, Q14-U06, Q14-U07, Q14-U08 — ressalvas operacionais de integridade e handoff sem falha de código)
  - Reprovados: 0
  - Bloqueados: 0
- **Escopo Autenticado (Q14-U09 a Q14-U18):**
  - Executados: 10 (100% dos autenticados)
  - Aprovados sem ressalva: 9 (Q14-U09, Q14-U10, Q14-U11, Q14-U12, Q14-U13, Q14-U14, Q14-U15, Q14-U16, Q14-U17)
  - Aprovados com ressalva: 1 (Q14-U18 — registro e desativação FCM validados em sandbox; entrega de push real não aferida)
  - Reprovados: 0
  - Bloqueados: 0
- **Total Geral Consolidado:**
  - Cenários Executados: 18 / 18 (100%)
  - Aprovados sem ressalva: 13 / 18 (72,2%)
  - Aprovados com ressalva: 5 / 18 (27,8%)
  - Reprovados: 0 / 18 (0%)
  - Bloqueados: 0 / 18 (0%)

---

## 4. Estado das Deliberações Institucionais

- **PRÉ-UAT TÉCNICO:** **APROVADO COM RESSALVAS**
- **AVALIAÇÃO HUMANA:** **NÃO EXECUTADA**
- **ACEITE HUMANO:** **PENDENTE**
- **GOOGLE/APPLE STORE REVIEW:** **NÃO PRONTO — BLOQUEIO-Q14-REVIEW-001**
  - contas REVIEW ainda não provisionadas operacionalmente;
  - backend externo acessível aos revisores ainda não definido/implantado;
  - modo sintético permanece bloqueado em produção;
  - estratégia de Store Review será definida após o aceite institucional.
  Não enfraquecer a proteção de produção.
- **Status Canônico da Fase:** **Q14 NÃO CONCLUÍDA — PRÉ-UAT TÉCNICO PÚBLICO E AUTENTICADO CONSOLIDADO COM RESSALVAS, ACEITE HUMANO PENDENTE**.
