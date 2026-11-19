# Especificação de Funcionalidade: Mensagens e Avisos Institucionais (`app_mppb_flutter`)

**Branch da Feature**: `feat/mensagens-avisos`  
**Criado em**: 2026-11-18  
**Status**: Rascunho (Draft)  
**Backend Relacionado**: `spring-boot/restapi/mobile-service/specs/001-mensagens-avisos/spec.md`  
**Constituição Aplicável**: `app_mppb_flutter/.specify/memory/constitution.md`

## Cenários de Usuário e Testes *(obrigatório)*

### História de Usuário 1 - Caixa de Entrada e Leitura de Mensagens/Avisos (Destinatário) (Priority: P1)

Como servidor ou membro do MPPB utilizando o aplicativo MPPB+, quero acessar uma página própria de **Mensagens e Avisos**, visualizar avisos recebidos (com indicador de não lidas), abrir o conteúdo completo com anexos e ter minha entrega e leitura confirmadas automaticamente.

**Por que esta prioridade**: É a experiência principal de consumo para todos os usuários do aplicativo, integrada ao recebimento de notificações push (FCM).

**Teste Independente**: Pode ser testado com testes de widget/provider simulando a listagem de mensagens (não lidas, lidas, expiradas/arquivadas), abertura do detalhe, disparo da confirmação de entrega/leitura e visualização/download de anexos.

**Critérios de Aceitação**:

1. **Dado** um usuário autenticado com mensagens pendentes, **Quando** ele abre o aplicativo ou a página de Mensagens/Avisos, **Então** o app sincroniza a caixa de entrada e confirma a entrega (`ENTREGUE`) das mensagens recebidas.
2. **Dado** uma mensagem não lida na lista, **Quando** o usuário toca para abrir o detalhe da mensagem, **Então** o app exibe título, remetente, data/hora, corpo, prazo de expiração (se houver) e anexos, e registra a leitura (`LIDO`) no backend.
3. **Dado** uma notificação push (FCM) recebida com o aplicativo em primeiro plano, segundo plano ou encerrado, **Quando** o usuário toca na notificação, **Então** o `go_router` navega diretamente para o detalhe da mensagem correspondente e confirma entrega/leitura.
4. **Dado** mensagens com mídias e anexos (fotos, vídeos, mensagens de áudio/voz e documentos como PDF, Word, Excel, PowerPoint, TXT e Markdown), **Quando** o usuário visualiza a conversa/canal de avisos, **Então** o app apresenta as mensagens em layout de conversa unilateral estilo WhatsApp e executa/visualiza os anexos diretamente dentro da conversa: imagens com miniatura e zoom em tela cheia, player de áudio inline (play/pause, barra de progresso, duração e velocidade 1x/1.5x/2x), vídeo com miniatura/botão de play e reprodução direta, e cartões de documento com visualização inline (PDF, Markdown, TXT) ou abertura/compartilhamento autenticado (Word, Excel, PowerPoint).
5. **Dado** mensagens na caixa de entrada, **Quando** o usuário arquiva uma mensagem ou filtra por *Não lidas* / *Todas* / *Arquivadas*, **Então** a lista reflete o filtro escolhido mantendo suporte a atualização (*pull-to-refresh*).

---

### História de Usuário 2 - Painel Próprio do Remetente no Aplicativo (PGJ / Autoridade Designada) (Priority: P1)

Como PGJ ou autoridade designada (com permissão retornada na sessão autenticada), quero acessar uma página própria no aplicativo para redigir e enviar mensagens/avisos em modo **Broadcast**, **Multicast** ou **Unicast**, anexar arquivos e definir prazo de expiração.

**Por que esta prioridade**: O usuário solicitou explicitamente que o remetente tenha uma página própria dentro do próprio aplicativo (não apenas em um sistema web separado).

**Teste Independente**: Pode ser testado verificando que o atalho/rota do painel de envio só aparece quando o usuário possui a permissão adequada, e validando o fluxo do formulário (título, corpo, modalidade, seleção de público/grupos/usuários, anexo, expiração e envio).

**Critérios de Aceitação**:

1. **Dado** um usuário comum (sem permissão administrativa/de envio), **Quando** ele navega no aplicativo, **Então** o botão/menu para o Painel de Envio de Mensagens não é exibido e a rota é protegida.
2. **Dado** um usuário autorizado no Painel de Envio, **Quando** ele escolhe a modalidade:
   - `Broadcast`: exibe resumo informando envio para todos os ativos;
   - `Multicast`: permite selecionar grupos predefinidos de RH (Membros, Servidores, Órgão/Setor, Cargo/Função) e/ou grupos personalizados;
   - `Unicast`: permite buscar e selecionar um ou mais servidores/membros específicos por nome ou matrícula.
3. **Dado** um formulário preenchido com texto e/ou mídia/anexo (podendo ser um aviso somente de texto, somente de imagem da câmera/galeria, somente de vídeo, somente de mensagem de áudio gravada no app ou somente de documento, ou combinados) e data de expiração opcional, **Quando** o remetente confirma o envio, **Então** o app valida que existe ao menos texto ou um anexo, envia e atualiza a lista de mensagens enviadas.

---

### História de Usuário 3 - Acompanhamento de Entrega e Leitura pelo Remetente (Priority: P2)

Como PGJ ou autoridade designada, quero visualizar no painel do remetente as mensagens já enviadas com barras/contadores de **Entregues**, **Lidos** e **Pendentes**, e abrir a lista detalhada mostrando **quem** recebeu/leu e **quando**.

**Por que esta prioridade**: Garante transparência e auditoria diretamente no celular da autoridade remetente.

**Teste Independente**: Pode ser testado com dados mockados no provider/repository verificando os contadores consolidados, filtros por status (`Todos`, `Lidos`, `Entregues`, `Pendentes`) e busca por nome/matrícula na lista de destinatários.

**Critérios de Aceitação**:

1. **Dado** uma mensagem enviada, **Quando** o remetente abre o detalhe de acompanhamento, **Então** visualiza os totais (enviados, entregues, lidos, pendentes) e a lista de destinatários com nome, lotação/setor, status e datas/horas de entrega e leitura.
2. **Dado** a lista de destinatários, **Quando** o remetente filtra por `Pendentes`, `Entregues` ou `Lidos`, ou pesquisa por nome, **Então** a listagem é atualizada via API paginada.

---

### História de Usuário 4 - Gestão de Grupos Personalizados no Aplicativo (Priority: P2)

Como PGJ ou autoridade designada, quero criar, editar e gerenciar grupos personalizados de destinatários diretamente no aplicativo, para reutilizá-los em envios `MULTICAST` futuros.

**Por que esta prioridade**: Complementa o fluxo `MULTICAST` no app sem depender de ferramentas externas.

**Teste Independente**: Pode ser testado validando a tela de listagem e edição de grupos personalizados (criar grupo, buscar e adicionar/remover servidores/membros, salvar e selecionar no envio).

**Critérios de Aceitação**:

1. **Dado** o painel de mensagens do remetente, **Quando** ele acessa "Gerenciar Grupos", **Então** pode listar grupos personalizados existentes, criar um novo grupo e adicionar/remover participantes pela busca de RH.

### Casos de Borda (Edge Cases)

- **App sem conectividade**: Exibir estado informativo claro com opção de tentar novamente sem travar a navegação; não perder rascunho de mensagem em preenchimento em caso de erro temporário de rede.
- **Permissão revogada em sessão ativa**: Caso o backend retorne HTTP 403 durante uma ação administrativa, o app exibe mensagem amigável informando falta de autorização e redireciona/atualiza o estado.
- **Anexo muito grande ou formato não suportado**: Validar tamanho/extensão antes do upload quando possível e exibir claramente a mensagem de erro retornada pelo backend.
- **Acesso exclusivo a usuários autenticados (sem público/anônimo)**: Usuários sem login (área pública) **nunca** recebem notificações de avisos nem acessam a caixa de mensagens. Ao fazer logout, o app deve desativar o token FCM do dispositivo no backend. Se uma notificação chegar por atraso de rede após a sessão expirar, o app **não** exibe conteúdo; exige login e só abre a mensagem se a matrícula autenticada for destinatária válida.

## Requisitos *(obrigatório)*

### Requisitos Funcionais

- **FR-001**: O app **DEVE** adicionar a feature sob `lib/features/mensagens/` seguindo a arquitetura do projeto (`data/`, `models/`, `providers/`, `ui/`), usando `flutter_riverpod`, `go_router` e `dio`.
- **FR-002**: O app **DEVE** disponibilizar uma página dedicada para o destinatário (Caixa de Entrada + Detalhe da Mensagem + Arquivadas + Anexos/Mídias) com badge/indicador de mensagens não lidas, destaque visual por prioridade (`NORMAL`, `IMPORTANTE`, `URGENTE`), botão **"Confirmar Ciência"** quando `exigeCiencia = true`, e sem opção de resposta/chat (comunicação unilateral).
- **FR-003**: O app **DEVE** confirmar entrega (`ENTREGUE`) ao sincronizar mensagens/receber push, confirmar leitura (`LIDO`) ao abrir o detalhe da mensagem e registrar `dataCiencia` ao acionar a confirmação explícita quando exigida.
- **FR-004**: O app **DEVE** disponibilizar uma página dedicada para o remetente autorizado (visível apenas mediante permissão de sessão), contemplando: envio (`Broadcast`, `Multicast`, `Unicast`), escolha de prioridade, opção de exigir ciência, prévia da quantidade estimada de destinatários antes do envio, agendamento opcional (`dataAgendamento`), gravação de áudio/anexo de mídias (respeitando limites por categoria), definição de expiração, acompanhamento de entrega/leitura/ciência e gestão de grupos personalizados.
- **FR-005**: O app **DEVE** integrar o clique em notificações push FCM (`firebase_messaging`) com rotas do `go_router` para abrir diretamente a mensagem recebida.

### Entidades / Modelos Principais (Dart)

- **MensagemAvisoModel**: Dados da mensagem recebida/enviada (`id`, `titulo`, `conteudo`, `remetenteNome`, `prioridade`, `modalidade`, `exigeCiencia`, `statusPublicacao`, `dataAgendamento`, `dataEnvio`, `dataExpiracao`, `statusUsuario`, `dataEntrega`, `dataLeitura`, `dataCiencia`, `anexos`).
- **AcompanhamentoMensagemModel / DestinatarioStatusModel**: Totais consolidados (enviados, entregues, lidos, cientes, pendentes) e lista paginada de destinatários com `nome`, `matricula`, `setor`, `status`, `dataEntrega`, `dataLeitura`, `dataCiencia`.
- **GrupoMensagemModel**: Grupos predefinidos de RH e grupos personalizados selecionáveis no envio `MULTICAST`.

## Critérios de Sucesso *(obrigatório)*

### Resultados Mensuráveis

- **SC-001**: Usuários sem permissão administrativa não visualizam nem conseguem acessar rotas de envio/gestão na UI.
- **SC-002**: Tocar em uma notificação push de aviso abre o detalhe da mensagem correta e registra leitura automaticamente.
- **SC-003**: Todos os novos providers, modelos e telas principais possuem testes automatizados em `test/features/mensagens/` aprovados com `flutter test` e zero erros no `flutter analyze`.

## Premissas

- O `auth` atual do `app_mppb_flutter` expõe (ou será estendido para expor) as permissões/funcionalidades do usuário autenticado retornadas pelo `mobile-service`.
- O aplicativo já possui configuração ativa de `firebase_core` e `firebase_messaging` (`pubspec.yaml`).

