# Feature Spec: 014 - Confirmação de Exclusão de Grupo, Push em Primeiro Plano, Entrega e Badge na Home

## Requisitos
1. Exibir diálogo de confirmação antes de excluir um grupo personalizado em `GruposPersonalizadosPage`.
2. Exibir feedback de erro claro em `GrupoEditorPage` caso o salvamento falhe.
3. Confirmar entrega de push `MENSAGEM_AVISO` em segundo plano (com headers do app) e em primeiro plano.
4. Exibir banner flutuante no topo do app quando uma notificação push chegar com o app em primeiro plano (tocável para abrir).
5. Exibir badge contador (`1`..`99+`) no card `Avisos` da página inicial (`DashboardPage`).

