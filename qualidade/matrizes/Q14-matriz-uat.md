# Q14 — Matriz de Execução UAT

**Data da Execução:** 02/10/2026 (Atualizado em 03/10/2026)  
**Ciclo:** Qualidade, Confiabilidade e Prontidão do App MPPB  
**Fase:** Q14 — User Acceptance Testing (UAT) e Aceite Final  
**Dispositivo de Referência:** Samsung Galaxy A52 (`SM-A525M`, Android 14 / One UI 6.1, API 34, Serial `RX8RC09H70X`)  
**Artefato Avaliado:** `br.mp.mppbapp.app.homolog` (v4.0.0+72, SHA-256: `E8568216B139C5DFE13FD17D40A5AE471708D19B4851BECE1D6E776D8FADC81A`)

---

## 1. Princípios Metodológicos da Matriz

1. **Separação Obrigatória:** Avaliação técnica objetiva (Pré-UAT) não se confunde com aceite negocial formal (Aceite Humano).
2. **Classificação Rigorosa:** Nenhuma jornada sem execução com dados reais/autorizados ou com handoff pendente pode ser marcada como aprovada irrestrita.
3. **Mapeamento 1:1 Canônico:** Exatamente 18 cenários UAT (`Q14-U01` a `Q14-U18`) correspondendo estritamente às 18 jornadas (`Q14-J01` a `Q14-J18`).
4. **Escopo Público:** Executado integralmente de forma técnica no aparelho físico Galaxy A52 e validado com sucesso ou ressalva metodológica.
5. **Escopo Autenticado:** Classificado formalmente como `BLOQUEADO — AUSÊNCIA DE MASSA/CREDENCIAL DE UAT` diante da ausência de credenciais institucionais autorizadas para teste em homologação.

---

## 2. Matriz de Cenários e Resultados (18 Jornadas 1:1)

| ID Cenário | Jornada Correspondente | Evidência Coletada | Executor | Resultado Técnico | Ressalva / Justificativa |
|---|---|---|---|---|---|
| **Q14-U01** | Q14-J01 — Inicialização, Splash e Primeira Abertura | `android/q14-home.png` | TÉCNICO | **APROVADO** | Inicialização sem falhas, splash institucional exibido, alcance imediato da Home pública. |
| **Q14-U02** | Q14-J02 — Navegação na Home Pública e Serviços ao Cidadão | `android/q14-home.png` | TÉCNICO | **APROVADO** | Grade de 6 serviços ao cidadão, carrossel de notícias, botão de login e badges funcionais. |
| **Q14-U03** | Q14-J03 — Consulta, Listagem e Leitura de Notícias | `android/q14-noticias.png`, `android/q14-noticia-detalhe.png` | TÉCNICO | **APROVADO** | Listagem via API, busca, tags de categoria, abertura de notícia em modal com foto e texto, retorno limpo à lista e à Home. |
| **Q14-U04** | Q14-J04 — Acesso ao Diário Oficial e Edições Recentes | `android/q14-diario.png`, `android/q14-diario-loaded.png` | TÉCNICO | **APROVADO** | Edições recentes listadas com destaque para Última Edição (Nº 3160); renderização completa do documento PDF no visualizador in-app. |
| **Q14-U05** | Q14-J05 — Consulta Pública de Processos e Filtros | `android/q14-processos.png` | TÉCNICO | **APROVADO COM RESSALVA** | Interface, filtros e validação de submissão aferidos (alerta orientativo e mensagem de campo obrigatório); consulta com processo conhecido e resultado positivo não aferida por ausência de massa UAT autorizada. |
| **Q14-U06** | Q14-J06 — Consulta de Canais de Atendimento e Contatos | `android/q14-contatos.png` | TÉCNICO | **APROVADO COM RESSALVA** | Presença visual e renderização dos botões 'Ligar' e 'Mapa', telefone, endereço, horários e ouvidoria aferidas na tela física; handoffs para discador e mapa não executados nesta rodada residual por indisponibilidade momentânea de conexão física do aparelho no host. Nenhuma chamada ou navegação real foi iniciada. |
| **Q14-U07** | Q14-J07 — Solicitação e Validação de Certidão Extrajudicial | `android/q14-certidao.png` | TÉCNICO | **APROVADO COM RESSALVA** | Interface e validações locais aferidas (alternância CPF/CNPJ, validações visuais de formato e obrigatoriedade); emissão/validação positiva contra registro real não executadas nesta bateria técnica. |
| **Q14-U08** | Q14-J08 — Registro de Manifestação na Ouvidoria | `android/q14-ouvidoria.png` | TÉCNICO | **APROVADO COM RESSALVA** | Interface, fluxo de identificação em 5 passos (Identif., Classif., Relato, Anexos, Revisão), alternância de manifestação anônima e validação local aferidas; submissão e geração de protocolo oficial deliberadamente omitidas por segurança operacional. |
| **Q14-U09** | Q14-J09 — Acesso Restrito / Autenticação Institucional (Login) | `android/q14-login.png` | TÉCNICO | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Interface de login validada visualmente (Usuário, Senha com toggle, Acessar, Cancelar), mas submissão bloqueada sem credencial institucional de homologação. |
| **Q14-U10** | Q14-J10 — Home Autenticada, Dashboard Restrito e Logout | EVIDÊNCIA HERDADA | TÉCNICO | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Dependente de autenticação ativa em Q14-U09. |
| **Q14-U11** | Q14-J11 — Consulta e Visualização do Perfil Funcional | EVIDÊNCIA HERDADA | TÉCNICO | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer usuário logado com dados cadastrais em homologação. |
| **Q14-U12** | Q14-J12 — Visualização da Carteira Funcional Digital | EVIDÊNCIA HERDADA | TÉCNICO | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer sessão autenticada para emissão de dados funcionais e foto. |
| **Q14-U13** | Q14-J13 — Consulta de Contracheques e Exportação PDF | EVIDÊNCIA HERDADA | TÉCNICO | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer perfil funcional com competências ativas de folha. |
| **Q14-U14** | Q14-J14 — Consulta de Informações de Pagamentos | EVIDÊNCIA HERDADA | TÉCNICO | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer histórico financeiro institucional atribuído ao usuário. |
| **Q14-U15** | Q14-J15 — Consulta de Designações Funcionais Ativas | EVIDÊNCIA HERDADA | TÉCNICO | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer vínculo com portarias/designações vigentes na base de homologação. |
| **Q14-U16** | Q14-J16 — Consulta de Concessões de Folga e Ausências | EVIDÊNCIA HERDADA | TÉCNICO | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer perfil com saldo de concessões e histórico funcional. |
| **Q14-U17** | Q14-J17 — Operações de Solicitação de Concessões/Folgas | EVIDÊNCIA HERDADA | TÉCNICO | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer permissão para abertura de requerimento administrativo no RH. |
| **Q14-U18** | Q14-J18 — Diagnóstico e Registro de Notificações Push (FCM) | EVIDÊNCIA HERDADA | TÉCNICO | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer autenticação para registro da matrícula no backend mobile. |

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
  - Executados: 1 (Q14-U09 com validação de interface em tela física)
  - Aprovados: 0
  - Aprovados com ressalva: 0
  - Reprovados: 0
  - Bloqueados: 10 (100% dos fluxos restritos, estritamente por ausência de credencial institucional autorizada para homologação)
