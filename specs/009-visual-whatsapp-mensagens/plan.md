# Plan 009 — Visual Estilo WhatsApp na Caixa de Mensagens

## Arquitetura
1. Criar o widget `MensagemConversaTile` em `lib/features/mensagens/ui/widgets/mensagem_conversa_tile.dart` para renderizar cada linha compacta da lista estilo WhatsApp (avatar, título, horário, prévia limpa de Markdown/mídia, checkmarks e indicadores de não lida/ciência).
2. Atualizar `CaixaMensagensPage` (`lib/features/mensagens/ui/pages/caixa_mensagens_page.dart`) para usar `MensagemConversaTile` com `Divider` recuado e `Dismissible` opcional para arquivar/desarquivar rapidamente, mantendo o `HeroHeaderPublico`, `MensagensSegmentedPillBar` e `_PainelAdminBanner`.
3. Atualizar `MensagemDetalhePage` (`lib/features/mensagens/ui/pages/mensagem_detalhe_page.dart`) para apresentar cabeçalho estilo conversa do WhatsApp (avatar, remetente, prioridade, ação de arquivar) e fundo de conversa `#EFEAE2` envolvendo o `MensagemBolhaCard` completo.
4. Atualizar/adicionar testes em `test/features/mensagens/caixa_mensagens_test.dart`.
