# Plan: 014 - Confirmação de Exclusão de Grupo, Push em Primeiro Plano, Entrega e Badge na Home

- `grupos_personalizados_page.dart`: diálogo `AlertDialog` de confirmação antes de chamar `remover(g.id)`.
- `grupo_editor_page.dart`: tratamento `catch` em `_salvar()` com `AppFeedback.showError`.
- `push_notification_service.dart` & `push_navigation_service.dart` & `app.dart`: confirmação de entrega em segundo/primeiro plano e banner flutuante in-app no topo quando chegar push em primeiro plano.
- `dashboard_page.dart`: badge contador `1`..`99+` no card `Avisos`.

