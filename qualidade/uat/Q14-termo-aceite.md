# Termo de Homologação e Aceite Final (UAT)

**Produto:** Aplicativo Móvel Institucional — MPPB+  
**Versão / Build:** 4.0.0 (versionCode 72, commit `87201fc`)  
**Backend:** Spring Boot REST API (`mobile-service-0.3.25.jar`, commit `2749415`)  
**Ambiente:** Homologação Oficial MPPB com UAT Sintético  
**Data da Avaliação:** 04 / 10 / 2026  

---

## 1. Escopo Avaliado no Aceite Final

O presente termo consolida o aceite formal realizado pelo responsável institucional após a execução integral das 18 jornadas canônicas no dispositivo móvel de referência (Samsung Galaxy A52, Android 14).

### 1.1 Escopo Técnico Homologado (Pré-UAT Técnico)
As seguintes dimensões foram previamente aferidas em bancada técnica e dispositivo físico com 100% de sucesso nos gates de qualidade:
- **Jornadas Públicas (8 Jornadas):**
  - Q14-J01: Inicialização, Splash e Primeira Abertura (Aprovado)
  - Q14-J02: Navegação na Home Pública e Serviços ao Cidadão (Aprovado)
  - Q14-J03: Consulta, Listagem e Leitura de Notícias (Aprovado)
  - Q14-J04: Acesso ao Diário Oficial com edições e visualização in-app de PDF (Aprovado)
  - Q14-J05: Consulta Pública de Processos com campos e filtros (Aprovado com Ressalva)
  - Q14-J06: Consulta de Canais de Atendimento e Contatos oficiais (Aprovado com Ressalva)
  - Q14-J07: Solicitação e Validação de Certidão Extrajudicial (Aprovado com Ressalva)
  - Q14-J08: Registro de Manifestação na Ouvidoria em 5 etapas e regras de validação (Aprovado com Ressalva)
- **Jornadas Autenticadas (10 Jornadas):**
  - Q14-J09: Acesso Restrito / Autenticação Institucional (Login) (Aprovado)
  - Q14-J10: Home Autenticada, Dashboard Restrito e Logout Seguro (Aprovado)
  - Q14-J11: Consulta e Visualização do Perfil Funcional (Aprovado)
  - Q14-J12: Visualização e Validação da Carteira Funcional Digital (Aprovado)
  - Q14-J13: Consulta de Contracheques e Exportação PDF (Aprovado)
  - Q14-J14: Consulta de Informações de Pagamentos (Aprovado)
  - Q14-J15: Consulta de Designações Funcionais Ativas (Aprovado)
  - Q14-J16: Consulta de Concessões de Folga e Ausências (Aprovado)
  - Q14-J17: Operações de Solicitação de Concessões/Folgas (Aprovado)
  - Q14-J18: Diagnóstico e Registro de Notificações Push (FCM) (Aprovado com Ressalva)
- **Conformidade Técnica e Gates de Regressão:**
  - Flutter: 244/244 testes aprovados (100%), analyze = 0 issues;
  - Backend: 202/202 testes aprovados (100%), Maven package = PASS;
  - Security gates: secret_scan = exit 0, security_regression = exit 0;
  - Regressões específicas: BUG-Q14-001, BUG-Q14-002 e BUG-Q14-003 corrigidos e validados.

---

## 2. Resultado da Avaliação Negocial

Decisão formal manifestada pelo responsável institucional após avaliação das 18 jornadas:

- [X] **ACEITO INTEGRALMENTE**
- [ ] **ACEITO COM RESSALVAS**
- [ ] **NÃO ACEITO**

**Resumo da Avaliação por Jornadas:**
- Total de Jornadas Avaliadas: 18 / 18
- ACEITO: 15
- ACEITO COM RESSALVA: 3 (Q14-J04, Q14-J05, Q14-J17)
- NÃO ACEITO: 0
- NÃO AVALIADO: 0
- BUGS CONFIRMADOS DURANTE O ACEITE: 0

---

## 3. Ressalvas Registradas (Observações Humanas Não Bloqueadoras)

As seguintes observações foram registradas durante a avaliação no ambiente UAT e classificadas como não impeditivas para o aceite final do produto:

1. **OBSERVAÇÃO-HUMANA-Q14-001 (Q14-J04 — Diário Oficial):** Durante o aceite humano no ambiente UAT, o Diário Oficial apresentou mensagem orientativa ("Não foi possível carregar os diários oficiais. Verifique sua conexão."). Trata-se de indisponibilidade de ambiente UAT externo, sem falha do código-fonte do aplicativo.
2. **OBSERVAÇÃO-HUMANA-Q14-002 (Q14-J17 — Concessões/Folgas):** Durante as operações no sandbox sintético, observou-se que o cancelamento exibiu mensagem de sucesso mas manteve a visualização da solicitação, e a ação "Interromper" permaneceu visível sem alteração perceptível imediata em tela. Classificado como comportamento pontual do sandbox/massa sintética, não constituindo regressão de código de produção.
3. **OBSERVAÇÃO-HUMANA-Q14-003 (Q14-J05 — Consulta Processual):** Ocorrência de lentidão/falha no carregamento de filtros adicionais no ambiente de testes UAT. Não confirmada como falha de produto em ambiente produtivo.

---

## 4. Pendências de Publicação (Store Review)

- **BLOQUEIO-Q14-REVIEW-001:** O processo de submissão e publicação nas lojas Google Play Store e Apple App Store segue isolado da validação funcional do aplicativo, aguardando:
  - Provisionamento operacional das contas de teste para revisores;
  - Disponibilização de endpoint de backend acessível externamente pelas equipes das lojas;
  - Preservação da desativação estrita do modo sintético em compilações de produção.

---

## 5. Responsável pelo Aceite

- **Responsável pela avaliação:** Rafael Vasconcelos  
- **Cargo/função:** Analista de Desenvolvimento de Sistema  
- **Unidade:** DITEC  
- **Lotação / Órgão:** Ministério Público do Estado da Paraíba (MPPB)  
- **Data:** 04/10/2026  
- **Assinatura:** PENDENTE DE FORMALIZAÇÃO, SE EXIGIDA PELO PROCESSO INSTITUCIONAL  
