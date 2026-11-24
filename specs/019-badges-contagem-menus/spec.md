# Feature Spec: 019 - Badges de Contagem por Módulo na Home e Menu `+`

## Requisito
1. Exibir selo de contagem (`1`..`99+`) nos cards da Home (`DashboardPage`) e do menu `+` (`ServicesBottomSheet`) sempre que houver itens não lidos na `NotificationCenterProvider` para o respectivo módulo (`afastamento`, `contracheque`, `designacao`, `pagamento`, `noticia`, `live`, além de `Avisos` via `caixaEntradaProvider.totalNaoLidas`).
2. Ao tocar no card e abrir a tela do serviço, marcar automaticamente os itens daquele módulo como lidos (`markTypeAsRead`) para zerar o badge.
