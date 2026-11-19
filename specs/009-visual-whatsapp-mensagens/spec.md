# Spec 009 — Visual Estilo WhatsApp na Caixa de Mensagens e Página Dedicada

## Contexto
Atualmente `CaixaMensagensPage` exibe cards completos (`MensagemBolhaCard`) diretamente na lista principal, tornando cada aviso muito alto (especialmente quando há Markdown extenso, imagens, áudios, PDFs e botão de ciência).

## Requisitos Funcionais
- **RF-01**: A tela `CaixaMensagensPage` deve exibir uma **lista compacta de conversas estilo WhatsApp** (`MensagemConversaTile`), separada por divisores sutis com recuo após o avatar:
  - Avatar circular à esquerda com iniciais do remetente e destaque visual discreto conforme a prioridade (`URGENTE`, `IMPORTANTE`, `NORMAL`).
  - Linha superior: título do aviso em negrito (1 linha com reticências) + horário/data estilo WhatsApp à direita (verde quando não lida).
  - Linha inferior: checkmarks de status (`✓`/`✓✓`), ícone de mídia quando houver anexo (foto, áudio, vídeo, documento) ou prévia limpa em 1 linha do conteúdo Markdown, além de indicador verde de não lida / badge discreto de ciência pendente à direita.
  - Suporte a arquivar/desarquivar diretamente por gesto (swipe) ou ação na tela de detalhe, mantendo o visual limpo.
- **RF-02**: Ao tocar em qualquer item da lista, o app navega para a página dedicada `MensagemDetalhePage` (`/mensagens/:id`), que registra a leitura e exibe a mensagem em layout de conversa estilo WhatsApp:
  - Cabeçalho com botão voltar, avatar e nome do remetente, prioridade e ação de arquivar/desarquivar.
  - Fundo de conversa suave (`#EFEAE2`) com a bolha completa da mensagem (título, conteúdo Markdown formatado, mídias inline, horário, checkmarks e confirmação de ciência).

## Critérios de Aceitação
- Nenhum card expandido com mídias/botões deve poluir a lista principal de `CaixaMensagensPage`.
- Todos os testes existentes e novos em `test/features/mensagens/` passam sem falhas e `flutter analyze` retorna 0 issues.

