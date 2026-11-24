# Feature Spec: 016 - Voltar em Detalhes de Mensagem e Cores do Modal Urgente

## Problemas
1. Ao abrir `/mensagens/:id` via notificação push, central de notificações ou banner/modal urgente (`context.go`), `Navigator.of(context).maybePop()` em `MensagemDetalhePage` não retorna para `/mensagens` porque não há rota anterior na pilha.
2. O modal de aviso urgente herdava o `surfaceTintColor` rosado do Material 3 em vez das cores padrão do projeto (`MensagensColors`).

## Requisitos
1. Garantir que o botão Voltar (e o retorno após arquivar) em `MensagemDetalhePage` navegue para `/mensagens` quando não houver rota anterior para `pop()`.
2. Aplicar as cores padrão do projeto (`surface` branco, `surfaceTintColor: Colors.transparent`, `ink`, `muted`, `brandDark`) no modal de aviso urgente.
