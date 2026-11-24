# Feature Spec: 015 - Alerta Global de Aviso Urgente

## Contexto
Quando um usuário autenticado possui avisos não lidos marcados com prioridade `URGENTE`, ele precisa ser alertado em qualquer página do aplicativo, ao abrir o app, ao retornar do segundo plano e ao receber push em primeiro plano.

## Requisitos
1. **Fonte de dados (`CaixaEntradaState`)**:
   - Expor getters para avisos urgentes não lidos (`urgentesNaoLidas`, `totalUrgentesNaoLidas`) filtrando `itens` por `prioridade == PrioridadeMensagem.urgente` e `status != StatusDestinatario.lida`.
2. **Comportamento híbrido global no `MainLayout` (`ShellRoute`)**:
   - **Modal/Dialog**: exibir um `AlertDialog` de destaque na primeira detecção da sessão (ou quando surgir novo aviso urgente não lido), permitindo ao usuário adiar temporariamente com `"Depois"` ou ir ler com `"Ler agora"`.
   - **Banner fixo global**: exibir um banner vermelho no topo do conteúdo em qualquer rota autenticada enquanto `totalUrgentesNaoLidas > 0` (ocultando automaticamente se já estiver em `/mensagens`), com ação para abrir o aviso/lista.
3. **Navegação ao tocar**:
   - Se houver **1** aviso urgente não lido, abrir direto `/mensagens/:id`.
   - Se houver **mais de 1** aviso urgente não lido, abrir a lista `/mensagens`.

