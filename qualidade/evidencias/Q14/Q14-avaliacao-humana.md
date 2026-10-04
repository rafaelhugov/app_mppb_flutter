# Q14 — Registro de Avaliação Humana e Aceite Negocial

**Data da Avaliação:** 04/10/2026  
**Ciclo:** Qualidade, Confiabilidade e Prontidão do App MPPB  
**Fase:** Q14 — User Acceptance Testing (UAT) e Aceite Final  

---

## 1. Situação da Avaliação Humana e do Aceite

```text
STATUS DA AVALIAÇÃO HUMANA: EXECUTADA
STATUS DO ACEITE DE NEGÓCIO: ACEITO INTEGRALMENTE
```

---

## 2. Dados Formais do Avaliador

- **Nome:** Rafael Vasconcelos
- **Cargo/função:** Analista de Desenvolvimento de Sistema
- **Unidade:** DITEC
- **Data da avaliação:** 04/10/2026
- **Assinatura:** PENDENTE DE FORMALIZAÇÃO, SE EXIGIDA PELO PROCESSO INSTITUCIONAL

---

## 3. Resumo da Avaliação Humana

- **Jornadas avaliadas:** 18/18
- **ACEITO:** 15
- **ACEITO COM RESSALVA:** 3
- **NÃO ACEITO:** 0
- **NÃO AVALIADO:** 0
- **BUGS CONFIRMADOS DURANTE O ACEITE HUMANO:** 0

---

## 4. Resultado por Jornada (18/18)

| ID Jornada | Descrição da Jornada | Decisão do Avaliador | Observações do Avaliador |
|---|---|---|---|
| **Q14-J01** | Inicialização, Splash e Primeira Abertura | **ACEITO** | Abertura fluida, tela inicial carregada sem intercorrências. |
| **Q14-J02** | Navegação na Home Pública e Serviços ao Cidadão | **ACEITO** | Serviços acessíveis, carrossel de notícias e botões funcionais. |
| **Q14-J03** | Consulta, Listagem e Leitura de Notícias | **ACEITO** | Leitura e detalhes de notícias íntegros. |
| **Q14-J04** | Acesso ao Diário Oficial e Edições Recentes | **ACEITO COM RESSALVA** | Ver OBSERVAÇÃO-HUMANA-Q14-001 (falha de carregamento no ambiente UAT). |
| **Q14-J05** | Consulta Pública de Processos e Filtros | **ACEITO COM RESSALVA** | Ver OBSERVAÇÃO-HUMANA-Q14-003 (falha no carregamento dos filtros adicionais). |
| **Q14-J06** | Consulta de Canais de Atendimento e Contatos | **ACEITO** | Informações de contato e atendimento disponíveis e legíveis. |
| **Q14-J07** | Solicitação e Validação de Certidão Extrajudicial | **ACEITO** | Telas de solicitação e validação compreensíveis e consistentes. |
| **Q14-J08** | Registro de Manifestação na Ouvidoria | **ACEITO** | Formulário em 5 etapas claro e navegável. |
| **Q14-J09** | Acesso Restrito / Autenticação Institucional (Login) | **ACEITO** | Autenticação funcional com credenciais sintéticas autorizadas. |
| **Q14-J10** | Home Autenticada, Dashboard Restrito e Logout | **ACEITO** | Dashboard restrito exibido e logout realizado com retorno à tela pública. |
| **Q14-J11** | Consulta e Visualização do Perfil Funcional | **ACEITO** | Dados funcionais exibidos de acordo com o perfil. |
| **Q14-J12** | Visualização da Carteira Funcional Digital | **ACEITO** | Carteira funcional digital e verso com dados e layout corretos. |
| **Q14-J13** | Consulta de Contracheques e Exportação PDF | **ACEITO** | Consulta de contracheques, alternância de visualização e exportação PDF. |
| **Q14-J14** | Consulta de Informações de Pagamentos | **ACEITO** | Histórico e parcelas de pagamentos acessíveis. |
| **Q14-J15** | Consulta de Designações Funcionais Ativas | **ACEITO** | Consulta de designações ativas exibida de forma clara. |
| **Q14-J16** | Consulta de Concessões de Folga e Ausências | **ACEITO** | Calendário e saldos de concessões consultados com clareza. |
| **Q14-J17** | Operações de Solicitação de Concessões/Folgas | **ACEITO COM RESSALVA** | Ver OBSERVAÇÃO-HUMANA-Q14-002 (comportamento de cancelamento/interrupção no sandbox). |
| **Q14-J18** | Diagnóstico e Registro de Notificações Push (FCM) | **ACEITO** | Diagnóstico de dispositivo e permissões verificados. |

---

## 5. Observações Humanas Registradas

### OBSERVAÇÃO-HUMANA-Q14-001
- **Jornada:** Q14-J04 — Diário Oficial
- **Descrição:** Durante o aceite humano no ambiente UAT, o Diário Oficial apresentou:
  > *"Não foi possível carregar os diários oficiais. Verifique sua conexão."*
- **Decisão da jornada:** ACEITO COM RESSALVA
- **Classificação:** observação do ambiente/UAT; não confirmada como bug de produção; não bloqueadora para o aceite final.

### OBSERVAÇÃO-HUMANA-Q14-002
- **Jornada:** Q14-J17 — Solicitação e operações de Concessões/Folgas
- **Observado:**
  - cancelamento apresentou mensagem de sucesso;
  - solicitação continuou visível/ativa após a operação;
  - alteração de data funcionou corretamente;
  - ação "Interromper" permaneceu disponível;
  - ao executar "Interromper", não houve alteração perceptível;
  - comportamento das ações foi considerado confuso pelo avaliador;
  - solicitação exibia situação não informada no ambiente sintético.
- **Evidência técnica complementar:** o backend sandbox recebeu efetivamente operações de cancelar, adiar e interromper.
- **Classificação:** comportamento inconsistente no sandbox/massa sintética; não confirmado como regressão de produção; não bloqueador para o aceite final.
- **Decisão da jornada:** ACEITO COM RESSALVA

### OBSERVAÇÃO-HUMANA-Q14-003
- **Jornada:** Q14-J05 — Consulta Processual
- **Descrição:** falha no carregamento dos filtros adicionais no ambiente UAT.
- **Decisão da jornada:** ACEITO COM RESSALVA
- **Classificação:** observação do ambiente/UAT; não confirmada como bug de produção; não bloqueadora para o aceite final.

---

## 6. Bugs Durante o Aceite Humano

```text
BUGS CONFIRMADOS DURANTE O ACEITE HUMANO = 0
```

*Nota:* BUG-Q14-001, BUG-Q14-002 e BUG-Q14-003 permanecem estritamente como bugs técnicos identificados no pré-UAT, devidamente corrigidos e validados nos gates automatizados. Nenhum bug adicional foi identificado ou confirmado durante a homologação humana.

---

## 7. Checagem Complementar de Perfil Servidor

Evidência complementar sem criação de nova jornada:
```text
uat.servidor:
login = SUCESSO
perfil de servidor = CORRETO
```
Essa checagem confirma a adequada segregação e representação entre os datasets sintéticos de Membro e Servidor.

---

## 8. Decisão Final Humana

```text
DECISÃO DO AVALIADOR:
ACEITO INTEGRALMENTE
```

Embora as jornadas individuais Q14-J04, Q14-J05 e Q14-J17 apresentem ressalvas relacionadas ao ambiente de homologação/sandbox UAT, o avaliador institucional manifestou formal e expressamente a decisão de **ACEITE INTEGRALMENTE** do produto, considerando-o apto para atendimento às finalidades institucionais.
