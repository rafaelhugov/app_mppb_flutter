# Q14 — Diretrizes e Credenciais para Store Review (Google Play & Apple App Store)

- **Fase:** Q14 — Qualidade e Homologação
- **Atividade:** Q14-R03-R03 — Hardening Final da Infraestrutura Sintética
- **Data:** 03/10/2026
- **Status:** **NÃO PRONTO — BLOQUEIO-Q14-REVIEW-001**

---

## 1. Separação Formal: UAT Interno ≠ Store Review

É mandatório separar formalmente os dois escopos:

| Escopo | Contas | Propósito | Ambiente Alvo | Status Atual |
|---|---|---|---|---|
| **UAT Interno** | `uat.membro`<br>`uat.servidor` | Homologação interna das jornadas Q14-U09 a Q14-U18 | Backend de homologação controlado (`homolog`/`uat`) | **PRONTO PARA EXECUÇÃO COMPLETA Q14-U09 A Q14-U18** |
| **Store Review** | `review.google.*`<br>`review.apple.*` | Avaliação externa por revisores da Google Play e Apple Store | Build de Loja / Produção vs Review dedicada | **NÃO PRONTO — BLOQUEIO-Q14-REVIEW-001** |

---

## 2. Bloqueio Arquitetural: Contradição Store Review / Produção

A infraestrutura de segurança estabelece que:
> `uat.synthetic-users.enabled=true` em profiles `prod`, `production` ou `prd` **recusa o startup fatalmente** (`ValidadorConfiguracaoSegura.java`).

Diante disso, surge a questão arquitetural:
**Se a build oficial da Google Play e Apple App Store apontar para o backend de PRODUÇÃO, como as contas `review.google.*` e `review.apple.*` autenticarão?**

### Decisão desta Rodada (R01):
1. **STORE REVIEW = CLASSIFICADO FORMALMENTE COMO NÃO PRONTO.**
2. É **terminantemente proibido** enfraquecer ou desativar o fail-fast de produção para acomodar store review.
3. É **terminantemente proibido** alterar o endpoint de release do Flutter nesta etapa.
4. As opções arquiteturais para Store Review serão avaliadas **após a conclusão do UAT interno**, entre:
   - *Opção A:* Build de loja enviada para review apontando para tenant/instância pública de homologação (`review.mppb.mp.br`);
   - *Opção B:* Proxy corporativo de autenticação em produção que reconheça exclusivamente os logins `review.*` e faça roteamento condicional seguro para o cluster de sandbox.

---

## 3. Requisitos de Infraestrutura para Store Review (Quando Habilitado)

A revisão externa conduzida pelas equipes de avaliação da Google Play e da Apple App Store possui requisitos operacionais distintos do ambiente de homologação interno:

1. **Acessibilidade Externa via TLS Válido:**
   O backend de revisão (`mobile-service`) deve estar hospedado em infraestrutura acessível publicamente via HTTPS, com certificado TLS válido e emitido por autoridade certificadora reconhecida (sem certificados autoassinados).
2. **Independência de Redes Internas:**
   Os avaliadores da Apple e Google **não utilizam VPN**, rede corporativa nem IPs estáticos dedicados.
3. **Ausência de Autenticação Multifator Real (MFA):**
   As contas de revisão não exigem confirmação via SMS real, WhatsApp ou e-mail corporativo institucional.
4. **Disponibilidade Contínua:**
   As contas devem permanecer ativas e com credenciais estáveis durante todo o ciclo de avaliação e eventuais revisões de versão subsequentes.

---

## 2. Google Play Store Review

### 2.1. Credenciais a Fornecer no Google Play Console

No formulário **"Acesso ao aplicativo" (App Content > App Access)** da Google Play Console:

| Campo | Valor / Instrução |
|---|---|
| **Opção Selecionada** | *Todas ou algumas funcionalidades são restritas (ex: login)* |
| **Nome da Credencial** | Conta de Teste de Promotor de Justiça (Membro) |
| **Nome de Usuário (Login)** | `review.google.membro` |
| **Senha** | *(Senha definida externamente na variável `GOOGLE_REVIEW_MEMBER_PASSWORD`)* |
| **Campos Adicionais** | N/A |
| **Instruções para o Avaliador** | Utilize as credenciais acima para acessar a área restrita do aplicativo. Esta conta possui perfil de Membro (Promotor de Justiça) com dados e contracheques sintéticos para fins de avaliação técnica das funcionalidades restritas. |

*(Opcional - Credencial secundária de Servidor Técnica)*:
- **Login:** `review.google.servidor`
- **Senha:** *(Definida na variável `GOOGLE_REVIEW_SERVER_PASSWORD`)*
- **Perfil:** Analista Ministerial (Servidor)

### 2.2. Funcionalidades e Telas Exercitadas
- **Carteira Funcional Digital:** Frente, verso, foto sintética, QR Code de validação;
- **Contracheques:** Listagem das competências 07/2026, 08/2026, 09/2026, visualização de proventos/descontos e visualização do PDF sintético;
- **Pagamentos / Diárias:** Exercícios 2025 e 2026 com detalhamento de processos;
- **Designações:** Portaria ativa de Promotoria de Justiça e histórico;
- **Concessões e Folgas:** Consulta de saldo de férias e solicitação de folga compensatória em sandbox;
- **Notificações Push / Dispositivo:** Registro e desativação de dispositivo no sandbox.

---

## 3. Apple App Store Review

### 3.1. Credenciais a Fornecer no App Store Connect

No formulário **"Informações para Revisão do App" (App Review Information)** do App Store Connect:

| Campo | Valor / Instrução |
|---|---|
| **Sign-in Required** | *(Marcado)* |
| **User Name** | `review.apple.membro` |
| **Password** | *(Senha definida externamente na variável `APPLE_REVIEW_MEMBER_PASSWORD`)* |
| **Notes (Notas de Revisão)** | This account has Member/Prosecutor privileges and uses synthetic, non-PII test data to demonstrate authenticated features: digital functional ID card, pay slips (contracheques), expense reimbursements (pagamentos), ministerial appointments, and leave management sandbox. |

*(Opcional - Credencial secundária de Servidor)*:
- **User Name:** `review.apple.servidor`
- **Password:** *(Definida na variável `APPLE_REVIEW_SERVER_PASSWORD`)*
- **Notes:** Staff role (Analista Ministerial) with synthetic data.

### 3.2. Observações Especiais para a Apple
- **Não Violação de Guideline 5.1.1 (Privacidade):**
  Todos os dados visualizados na aplicação sob esta conta são gerados sinteticamente pelo backend e não correspondem a informações privadas de cidadãos ou servidores reais.
- **Operações Não Destrutivas:**
  Qualquer operação de solicitação ou cancelamento de folga realizada pelo revisor da Apple opera em sandbox volátil e não tem efeito sobre sistemas governamentais externos.

---

## 4. Instruções Passo a Passo de Login para o Avaliador

1. Ao abrir o aplicativo, aguarde a tela inicial carregar;
2. Toque no ícone de perfil no canto superior direito ou no banner de login para acessar a tela de autenticação;
3. No campo **Usuário / CPF / Matrícula**, digite o login fornecido (`review.google.membro` ou `review.apple.membro`);
4. No campo **Senha**, insira a senha fornecida;
5. Toque no botão **Entrar**;
6. A tela inicial autenticada será exibida com o nome "Lucas Almeida Monteiro" e o cargo "Promotor de Justiça";
7. Navegue pelas seções:
   - **Carteira Funcional:** Toque no card da carteira digital para ver frente e verso;
   - **Contracheque:** Acesse a lista de competências e toque em "Ver Detalhes" ou "Baixar PDF";
   - **Pagamentos:** Consulte os pagamentos de 2026 e altere o exercício para 2025;
   - **Designações:** Visualize a portaria ativa de titularidade da Promotoria de Homologação;
   - **Folgas / Concessões:** Verifique o saldo de férias regulamentares.
