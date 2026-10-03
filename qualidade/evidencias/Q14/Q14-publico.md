# Q14 — Evidências de Execução: Escopo Público (8 Jornadas)

**Data da Execução:** 02/10/2026 (Atualizado em 03/10/2026)  
**Ciclo:** Qualidade, Confiabilidade e Prontidão do App MPPB  
**Fase:** Q14 — User Acceptance Testing (UAT) e Aceite Final  
**Dispositivo:** Samsung Galaxy A52 (`SM-A525M`, Android 14 / API 34, Serial `RX8RC09H70X`)  
**Pacote:** `br.mp.mppbapp.app.homolog` (v4.0.0+72, SHA-256: `E8568216B139C5DFE13FD17D40A5AE471708D19B4851BECE1D6E776D8FADC81A`)

---

## 1. Resumo do Escopo Público (Q14-U01 a Q14-U08)

| Cenário | Jornada | Descrição Resumida | Evidência Principal | Resultado Técnico | Ressalva Metodológica |
|---|---|---|---|---|---|
| **Q14-U01** | Q14-J01 | Inicialização, Splash e Primeira Abertura | `android/q14-home.png` | **APROVADO** | Nenhuma. Splash sem ANR/crash, transição imediata para Home pública. |
| **Q14-U02** | Q14-J02 | Home Pública e Serviços ao Cidadão | `android/q14-home.png` | **APROVADO** | Nenhuma. Grade com 6 serviços essenciais, carrossel de notícias, botão de login e badges íntegros. |
| **Q14-U03** | Q14-J03 | Notícias (Listagem, Leitura e Retorno) | `android/q14-noticias.png`, `android/q14-noticia-detalhe.png` | **APROVADO** | Nenhuma. Listagem dinâmica da API com categorias, modal de leitura com fotos e retorno limpo. |
| **Q14-U04** | Q14-J04 | Diário Oficial (Edições e Visualizador PDF) | `android/q14-diario.png`, `android/q14-diario-loaded.png` | **APROVADO** | Nenhuma. Edições listadas com destaque para Última Edição (Nº 3160); renderização completa do documento PDF no visualizador in-app sem travamentos. |
| **Q14-U05** | Q14-J05 | Consulta Processual (Campos e Filtros) | `android/q14-processos.png` | **APROVADO COM RESSALVA** | Interface, filtros e validação de submissão aferidos; consulta com processo conhecido e resultado positivo não aferida por ausência de massa UAT autorizada. |
| **Q14-U06** | Q14-J06 | Contatos e Canais de Atendimento | `android/q14-contatos.png` | **APROVADO COM RESSALVA** | Presença visual e renderização dos botões 'Ligar' e 'Mapa', telefone, endereço, horários e ouvidoria aferidas na tela física; handoff para discador externo e mapa não executados nesta rodada residual por indisponibilidade momentânea de conexão física do aparelho no host. Nenhuma chamada ou navegação real foi iniciada. |
| **Q14-U07** | Q14-J07 | Certidão Extrajudicial (Emissão e Validação) | `android/q14-certidao.png` | **APROVADO COM RESSALVA** | Interface e validações locais aferidas (mensagens visuais de CPF/Nome obrigatórios); emissão/validação positiva contra registro real não executadas nesta bateria técnica. |
| **Q14-U08** | Q14-J08 | Registro de Manifestação na Ouvidoria | `android/q14-ouvidoria.png` | **APROVADO COM RESSALVA** | Interface, fluxo de identificação em 5 passos (Identif., Classif., Relato, Anexos, Revisão), alternância de denúncia anônima e validação de formulário aferidos; submissão e geração de protocolo oficial deliberadamente omitidas por segurança operacional. |

---

## 2. Detalhamento Técnico das Evidências Coletadas

### 2.1 Q14-U01 — Inicialização e Splash Screen
- **Execução:** Lançamento limpo via launcher Android (`am monkey -p br.mp.mppbapp.app.homolog -c android.intent.category.LAUNCHER 1`).
- **Comportamento Observado:**
  - Splash screen institucional exibida com o brasão oficial do MPPB;
  - Ausência total de crash, congelamento ou encerramento anômalo;
  - Resolução de janela aferida: `mCurrentFocus=Window{... br.mp.mppbapp.app.homolog/br.mp.mppbapp.app.MainActivity}`.
- **Evidência:** Conforme captura consolidada em `qualidade/evidencias/Q14/android/q14-home.png`.
- **Resultado:** **APROVADO**.

### 2.2 Q14-U02 — Home Pública e Acessos ao Cidadão
- **Execução:** Inspeção de todos os elementos da tela principal sem autenticação prévia.
- **Comportamento Observado:**
  - Saudação institucional "Bem-vindo — Acesse os principais serviços do Ministério Público da Paraíba";
  - Grade de 6 serviços ao cidadão: Certidão Extrajudicial, Diário Oficial, Notícias, Ouvidoria, Processos, Contatos;
  - Botão superior "-> Entrar" para login restrito;
  - Carrossel inferior com notícias de destaque e botão "Todas as notícias".
- **Evidência:** Registrada em `qualidade/evidencias/Q14/android/q14-home.png`.
- **Resultado:** **APROVADO**.

### 2.3 Q14-U03 — Notícias Institucionais
- **Execução:** Toque no atalho de Notícias na Home e navegação em profundidade.
- **Comportamento Observado:**
  - Carregamento da listagem da API de homologação com campo de busca ("Buscar notícias..."), badges de categoria (Eleitoral, Patrimônio Público, Cidadania, Saúde), data de publicação e tempo estimado de leitura;
  - Toque no primeiro card: abertura em modal da matéria "MPPB atuará na fiscalização do 1º turno da eleição 2026, neste final de semana", exibindo imagem principal e corpo de texto formatado;
  - Retorno suave à listagem via botão fechar (`X`) e retorno à Home via botão voltar (`<`).
- **Evidências:** Registradas em `qualidade/evidencias/Q14/android/q14-noticias.png` e `qualidade/evidencias/Q14/android/q14-noticia-detalhe.png`.
- **Resultado:** **APROVADO**.

### 2.4 Q14-U04 — Diário Oficial e Visualizador de PDF
- **Execução:** Acesso à listagem de publicações oficiais e acionamento da visualização in-app.
- **Comportamento Observado:**
  - Lista de edições recentes exibida com destaque para "ÚLTIMA EDIÇÃO" (Nº 3160, publicado em 12/05/2026) e edições anteriores (Nº 3159 a 3154);
  - Ao tocar no botão de ação **Abrir** da edição Nº 3160, o visualizador integrado de PDF abre em modal sheet ("Diário Oficial Nº 3160"), apresentando o cabeçalho institucional, atos da Procuradoria-Geral de Justiça, resenhas e portarias com nitidez e rolagem íntegra;
  - Fechamento do visualizador sem vazamento de memória ou travamento de interface.
- **Evidências:** Registradas em `qualidade/evidencias/Q14/android/q14-diario.png` e `qualidade/evidencias/Q14/android/q14-diario-loaded.png`.
- **Resultado:** **APROVADO**.

### 2.5 Q14-U05 — Consulta Pública Processual
- **Execução:** Acesso ao módulo de processos, leitura das instruções e acionamento da busca sem dados para teste de validação.
- **Comportamento Observado:**
  - Banner informativo orientando os campos preferenciais para busca (Processo, Origem CNJ, CNMP, CPF, CNPJ, Interessado);
  - Filtros adicionais expansíveis (Comarca, Classe, Nome do Promotor, Tipo de Atividade e Status Ativo/Inativo);
  - Ao acionar o botão "Pesquisar processo" com campos vazios, a aplicação apresenta alerta inferior (toast/snackbar) notificando: *"Informe pelo menos um campo para realizar a busca."*, impedindo requisições desnecessárias;
  - *Ressalva Metodológica:* A consulta com número de processo conhecido e retorno de resultado positivo na base de homologação não foi executada nesta bateria por ausência de processo de teste homologado para UAT.
- **Evidência:** Registrada em `qualidade/evidencias/Q14/android/q14-processos.png`.
- **Resultado:** **APROVADO COM RESSALVA**.

### 2.6 Q14-U06 — Contatos e Atendimento Institucional
- **Execução:** Acesso à tela de contatos e canais institucionais.
- **Comportamento Observado:**
  - Seção "Sede do MPPB" com telefone geral `(83) 2107-6000` acompanhado do botão "Ligar";
  - Endereço da sede (Rua Rodrigues de Aquino, s/n, Centro, João Pessoa/PB) com botão "Mapa";
  - Horário oficial de atendimento nas Promotorias de Justiça: "7h às 13h";
  - Canal de Ouvidoria com telefone institucional `(83) 2107-6150`.
- **Ressalva Metodológica:**
  - A presença visual e correta renderização dos botões "Ligar" e "Mapa", do telefone oficial, do endereço da sede, dos horários e da Ouvidoria foram plenamente aferidas na tela física do Galaxy A52 ([q14-contatos.png](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q14/android/q14-contatos.png));
  - Os handoffs para acionamento do discador externo (`tel:(83)2107-6000`) e do aplicativo de mapas (`https://www.google.com/maps/search/...`) não foram executados nesta rodada residual por indisponibilidade momentânea de conexão física do aparelho no host. Nenhuma chamada ou navegação real foi iniciada;
  - Em conformidade com a regra canônica de que a presença visual isolada dos botões não sustenta aprovação irrestrita, o cenário é classificado formalmente como **APROVADO COM RESSALVA**.
- **Evidência:** Registrada em `qualidade/evidencias/Q14/android/q14-contatos.png`.
- **Resultado:** **APROVADO COM RESSALVA**.

### 2.7 Q14-U07 — Certidão Extrajudicial
- **Execução:** Acesso ao módulo de emissão/validação de certidão negativa e teste de validação de formulário.
- **Comportamento Observado:**
  - Abas "Emitir" e "Validar";
  - Seletor alternável entre "CPF" e "CNPJ";
  - Campos de entrada "CPF" e "Nome";
  - Ao acionar "Emitir PDF" sem preenchimento, o formulário aciona validação local em tempo real, destacando os campos com borda vermelha e mensagens claras: *"Informe um CPF válido."* e *"Informe pelo menos 3 caracteres."*;
  - *Ressalva Metodológica:* A emissão com CPF real e verificação de certidão válida foi preservada fora do teste técnico para evitar geração de registros na base institucional.
- **Evidência:** Registrada em `qualidade/evidencias/Q14/android/q14-certidao.png`.
- **Resultado:** **APROVADO COM RESSALVA**.

### 2.8 Q14-U08 — Registro de Manifestação na Ouvidoria
- **Execução:** Acesso ao formulário de ouvidoria na Home e teste de navegação nas etapas.
- **Comportamento Observado:**
  - Assistente guiado (wizard) em 5 etapas: Identif., Classif., Relato, Anexos, Revisão;
  - Opção alternável de manifestação anônima ("Desejo fazer uma manifestação anônima");
  - Ao acionar o botão "Próximo" mantendo os campos de identificação vazios, a aplicação exibe banner vermelho de aviso no topo da tela: *"O CPF/CNPJ é obrigatório."*, bloqueando avanço indevido;
  - *Ressalva Metodológica:* A submissão com criação de protocolo real foi deliberadamente omitida para assegurar a integridade do sistema da Ouvidoria do MPPB.
- **Evidência:** Registrada em `qualidade/evidencias/Q14/android/q14-ouvidoria.png`.
- **Resultado:** **APROVADO COM RESSALVA**.
