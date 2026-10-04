# Q14 — Plano de Testes de Aceitação do Usuário (UAT)

**Versão:** 1.0  
**Data:** 02/10/2026  
**Ciclo:** Qualidade, Confiabilidade e Prontidão do App MPPB  
**Fase:** Q14 — User Acceptance Testing (UAT) e Aceite Final

---

## 1. Objetivo

Estabelecer a estratégia, os critérios e os procedimentos formais para a validação das necessidades do usuário final e homologação negocial do App MPPB, assegurando que o produto no escopo funcional disponível no ambiente de homologação atenda aos objetivos institucionais e esteja apto para homologação formal.

---

## 2. Escopo de Jornadas (18 Jornadas Canônicas)

### 2.1 Escopo Incluído (Público — 8 Jornadas)
- **Q14-J01 — Inicialização, Splash e Primeira Abertura:** Inicialização sem travamentos, apresentação de identidade visual oficial do MPPB e transição para a Home.
- **Q14-J02 — Navegação na Home Pública e Serviços ao Cidadão:** Grade de 6 serviços ao cidadão, carrossel dinâmico de notícias e atalhos institucionais.
- **Q14-J03 — Consulta, Listagem e Leitura de Notícias:** Listagem via API, busca por título, tags de categorização, abertura em modal de detalhe com foto e texto, retorno suave.
- **Q14-J04 — Acesso ao Diário Oficial e Edições Recentes:** Lista de edições recentes, identificação da última edição e renderização de arquivo PDF no visualizador integrado.
- **Q14-J05 — Consulta Pública de Processos e Filtros:** Preenchimento de campos de busca (Processo, CNJ, CNMP, CPF, CNPJ, Interessado), filtros adicionais e validações amigáveis.
- **Q14-J06 — Consulta de Canais de Atendimento e Contatos:** Exibição dos canais oficiais (sede, promotorias, ouvidoria, horários de atendimento, mapas e discagem telefônica direta).
- **Q14-J07 — Solicitação e Validação de Certidão Extrajudicial:** Interface de emissão por CPF/CNPJ, alternância de documento, regras de obrigatoriedade e aba de validação por código.
- **Q14-J08 — Registro de Manifestação na Ouvidoria:** Interface em 5 passos (Identificação, Classificação, Relato, Anexos e Revisão), opção anônima e validação de formulário.

### 2.2 Escopo Incluído (Autenticado — 10 Jornadas — Sujeito a Credenciais)
- **Q14-J09 — Acesso Restrito / Autenticação Institucional (Login):** Interface de autenticação com credencial funcional institucional.
- **Q14-J10 — Home Autenticada, Dashboard Restrito e Logout:** Acesso à área restrita com sessão ativa e encerramento seguro.
- **Q14-J11 — Consulta e Visualização do Perfil Funcional:** Visualização de dados cadastrais e funcionais do servidor/membro.
- **Q14-J12 — Visualização da Carteira Funcional Digital:** Carteira digital com fotografia oficial e validação de autenticidade.
- **Q14-J13 — Consulta de Contracheques e Exportação PDF:** Histórico de contracheques por competência e exportação de demonstrativo em PDF.
- **Q14-J14 — Consulta de Informações de Pagamentos:** Histórico e detalhamento financeiro por exercício.
- **Q14-J15 — Consulta de Designações Funcionais Ativas:** Consulta às designações e portarias em vigor.
- **Q14-J16 — Consulta de Concessões de Folga e Ausências:** Consulta de saldo e histórico de concessões concedidas.
- **Q14-J17 — Operações de Solicitação de Concessões/Folgas:** Fluxo de requerimento e solicitação de concessões/folgas.
- **Q14-J18 — Diagnóstico e Registro de Notificações Push (FCM):** Registro seguro do token do dispositivo para recebimento de comunicações oficiais.

### 2.3 Escopo Excluído
- Testes destrutivos, fuzzing, injeção de falhas e pentest (concluídos e congelados nas fases Q1 a Q13).
- Alterações em massa de dados de produção ou acionamento de serviços reais de terceiros que gerem protocolo oficial externo desnecessário.

---

## 3. Ambiente e Dispositivos de Teste

- **Ambiente de Backend (Canônico):** Homologação MPPB (`https://aplicativo-mppb-homolog.mppb.mp.br`).
  - *Nota de Proveniência Canônica:* A base oficial de compilação do APK (`build_apk.sh`, `build_aab.sh`), os arquivos de configuração de ambiente e o cliente HTTP (`lib/core/network/api_client.dart`) utilizam exclusivamente o hostname canônico `https://aplicativo-mppb-homolog.mppb.mp.br`. A menção simplificada `https://app-homolog.mppb.mp.br` constitui mera abreviação textual coloquial.
- **Dispositivo Físico Canônico:** Samsung Galaxy A52 (`SM-A525M`), Android 14 / One UI 6.1 (API 34, Serial `RX8RC09H70X`).
- **Artefato sob Teste:** `br.mp.mppbapp.app.homolog` (v4.0.0+72, APK debug homolog, SHA-256: `E8568216B139C5DFE13FD17D40A5AE471708D19B4851BECE1D6E776D8FADC81A`).
- **Conectividade:** Rede Wi-Fi / Dados Móveis estável.

---

## 4. Participantes e Papéis

| Papel | Responsabilidade | Perfil Requerido |
|---|---|---|
| **Líder Técnico de Qualidade** | Coordenação técnica do UAT, auditoria de builds, coleta de evidências de runtime e elaboração do relatório técnico (Pré-UAT). | Engenharia de Software / QA |
| **Avaliador de Negócio (Usuário Real)** | Execução do roteiro de validação funcional sob ótica do usuário, preenchimento do questionário UAT e emissão do parecer negocial. | Membro ou Servidor indicado formalmente pelo MPPB |
| **Responsável Institucional pelo Aceite** | Análise do resultado global, avaliação de ressalvas e assinatura formal do Termo de Aceite Final. | Gestor de Negócio / Diretor de TI / Patrocinador do Projeto |

---

## 5. Massa de Dados e Credenciais

- **Escopo Público:** Dados reais disponíveis na base de homologação institucional (notícias públicas, edições públicas do Diário Oficial, endereços e telefones da sede).
- **Escopo Autenticado:** Necessita de credenciais institucionais de homologação atribuídas formalmente aos avaliadores com perfis de Servidor e Membro (ver `OBS-Q14-001`). Sem essas credenciais, as 10 jornadas restritas permanecem formalmente bloqueadas.

---

## 6. Pré-condições

1. APK de homologação instalado com sucesso no dispositivo físico autorizado.
2. Endpoint canônico de homologação ativo e responsivo (`https://aplicativo-mppb-homolog.mppb.mp.br`).
3. Gates técnicos de segurança e regressão devidamente aprovados (Flutter analyze 0, 244/244 testes Flutter, 202/202 testes Backend).
4. Dispositivo com carga de bateria superior a 20% e tela calibrada.

---

## 7. Critérios de Aceite Negocial

Um cenário UAT é considerado aceito se:
1. O objetivo da jornada for concluído pelo usuário sem interrupção técnica;
2. As informações exibidas forem claras, compreensíveis e coerentes com a realidade institucional;
3. As ações e navegação apresentarem resposta consistente e intuitiva;
4. Nenhuma mensagem técnica indecifrável (ex.: stack trace ou código HTTP cru) for exposta ao usuário.

---

## 8. Critérios de Suspensão do UAT

A execução do UAT será suspensa imediatamente se:
- Ocorrer crash recorrente ou fatal (ANR / encerramento forçado) que impeça a inicialização do aplicativo;
- O backend de homologação ficar permanentemente indisponível durante a sessão de teste;
- For detectada qualquer violação de segurança ou exposição inadvertida de dados sensíveis não mascarados.

---

## 9. Critérios de Encerramento e Aceite Final

O ciclo de UAT será considerado formalmente concluído quando:
1. Todas as 8 jornadas públicas tiverem sido executadas e aprovadas tecnicamente;
2. O escopo autenticado tiver sido validado com massa autorizada ou formalmente registrado como bloqueado para homologação;
3. O roteiro do avaliador tiver sido aplicado com usuário humano autorizado;
4. O Termo de Aceite estiver devidamente assinado e preenchido pela autoridade responsável pelo produto.
