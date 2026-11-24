# Implementation Plan: 019 - Badges de Contagem por Módulo na Home e Menu `+`

1. Adicionar `notificationCenterItemsProvider`, `unreadCountForType` e `markTypeAsRead` em `lib/core/notifications/notification_center_provider.dart`.
2. Atualizar `DashboardPage` (`lib/features/dashboard/ui/dashboard_page.dart`) para exibir badges nos cards de `Serviços internos` e zerar ao abrir.
3. Atualizar `ServicesBottomSheet` (`lib/core/ui/widgets/services_bottom_sheet.dart`) para exibir badges nos atalhos e zerar ao abrir.
4. Adicionar testes e validar com `flutter analyze` e `flutter test`.
