# Q14 — Evidências de Execução: Escopo Autenticado (10 Jornadas)

**Data da Auditoria:** 02/10/2026  
**Ciclo:** Qualidade, Confiabilidade e Prontidão do App MPPB  
**Fase:** Q14 — User Acceptance Testing (UAT) e Aceite Final  
**Dispositivo:** Samsung Galaxy A52 (`SM-A525M`, Android 14 / API 34, Serial `RX8RC09H70X`)  
**Pacote:** `br.mp.mppbapp.app.homolog` (v4.0.0+72, SHA-256: `E8568216B139C5DFE13FD17D40A5AE471708D19B4851BECE1D6E776D8FADC81A`)

---

## 1. Princípio Fundamental de UAT Autenticado

Conforme diretriz metodológica canônica da fase Q14:
> *Se não houver credencial autorizada para UAT no ambiente de homologação, o cenário deve ser classificado formalmente como `BLOQUEADO — AUSÊNCIA DE MASSA/CREDENCIAL DE UAT`. Nunca transformar testes automatizados, stubs ou mocks de desenvolvimento em 'login UAT aprovado'.*

---

## 2. Status dos Cenários Autenticados (Q14-U09 a Q14-U18)

| ID Cenário | Jornada Correspondente | Estado UAT | Justificativa Objetiva |
|---|---|---|---|
| **Q14-U09** | Q14-J09 — Acesso Restrito / Autenticação Institucional | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. A interface de login institucional foi inspecionada e validada visualmente no aparelho físico (`android/q14-login.png`), mas a submissão de credencial e obtenção de token real em homologação foram bloqueadas pela ausência de credenciais institucionais de teste previamente autorizadas. |
| **Q14-U10** | Q14-J10 — Home Autenticada, Dashboard Restrito e Logout | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Depende diretamente da conclusão bem-sucedida do login em Q14-U09 com token emitido pelo serviço de autorização. |
| **Q14-U11** | Q14-J11 — Consulta e Visualização do Perfil Funcional | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer usuário logado com dados cadastrais e funcionais ativos na base de homologação. |
| **Q14-U12** | Q14-J12 — Visualização da Carteira Funcional Digital | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer sessão válida, consulta aos dados funcionais, recuperação de foto oficial e renderização do cartão funcional. |
| **Q14-U13** | Q14-J13 — Consulta de Contracheques e Exportação PDF | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer usuário autenticado com competências de folha ativas em homologação para visualização e emissão do PDF. |
| **Q14-U14** | Q14-J14 — Consulta de Informações de Pagamentos | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer autenticação e histórico financeiro de exercícios disponível na base de testes. |
| **Q14-U15** | Q14-J15 — Consulta de Designações Funcionais Ativas | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer matrícula funcional vinculada a portarias/designações vigentes na base de homologação. |
| **Q14-U16** | Q14-J16 — Consulta de Concessões de Folga e Ausências | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer perfil funcional com saldo de concessões e histórico de ausências usufruídas. |
| **Q14-U17** | Q14-J17 — Operações de Solicitação de Concessões/Folgas | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer permissão e fluxo administrativo no RH/MPVirtual de homologação para submissão de requerimento. |
| **Q14-U18** | Q14-J18 — Diagnóstico e Registro de Notificações Push (FCM) | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer autenticação prévia para associação da matrícula do usuário ao identificador push institucional. |

---

## 3. Avaliação da Interface de Login (Q14-U09)

Durante a auditoria física no Samsung Galaxy A52, a interface de login foi acionada a partir do botão superior "-> Entrar" na Home pública:
- **Componentes Renderizados e Inspecionados:**
  - Botão de navegação superior para retornar (`<`);
  - Brasão oficial do Ministério Público da Paraíba;
  - Título `MPPB+` e subtítulo `ACESSO RESTRITO`;
  - Campo de entrada com ícone de usuário e rótulo `Usuário`;
  - Campo de entrada com ícone de cadeado, rótulo `Senha` e alternador de visibilidade (ícone de olho);
  - Botão de ação primária `ACESSAR` com identidade visual padronizada (vermelho institucional);
  - Botão de ação secundária `Cancelar` que retorna o usuário diretamente para a Home pública.
- **Evidência Registrada:** `qualidade/evidencias/Q14/android/q14-login.png`.
- **Ressalva Metodológica:**
  - O fluxo de apresentação da tela foi aprovado na camada de interface e estabilidade visual;
  - A submissão da requisição de autorização para o servidor institucional não foi executada por ausência de credencial de teste dedicada, classificando o cenário estritamente como **BLOQUEADO**.

---

## 4. Pré-requisito para Desbloqueio e Aceite de Negócio

Para que os cenários autenticados (Q14-U09 a Q14-U18) possam ser transicionados para o estado de avaliação humana ou aprovação negocial, faz-se estritamente necessária:
1. A disponibilização pelo MPPB de **duas credenciais de teste em ambiente de homologação** (ex.: uma com perfil de Membro/Promotor e uma com perfil de Servidor Técnico/Administrativo);
2. A concessão prévia de autorização de uso dessas contas em base não produtiva;
3. A execução do roteiro pelo respectivo avaliador de negócio designado institucionalmente.
