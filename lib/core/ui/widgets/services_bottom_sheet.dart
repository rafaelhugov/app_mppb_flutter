import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/mensagens/providers/caixa_entrada_provider.dart';
import '../../../features/mensagens/providers/permissao_mensagens_provider.dart';
import '../../notifications/notification_center_provider.dart';

class ServicesBottomSheet {
  static void show(BuildContext context, bool isAuthenticated) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F8F6),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x14101828),
                blurRadius: 40,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Serviços',
                        style: TextStyle(
                          color: Color(0xFF202322),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(ctx),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0x1A343A40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Color(0xFF697370),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Consumer(
                    builder: (context, ref, _) {
                      final items = ref.watch(notificationCenterItemsProvider);
                      final avisosNaoLidos = ref
                          .watch(caixaEntradaProvider)
                          .totalNaoLidas;
                      final podeEnviar =
                          ref
                              .watch(podeEnviarMensagensProvider)
                              .asData
                              ?.value ??
                          false;
                      final itemWidth =
                          (MediaQuery.of(context).size.width - 70) / 4;

                      Widget shortcut({
                        required IconData icon,
                        required String label,
                        required String route,
                        NotificationCenterItemType? notificationType,
                        int? badgeOverride,
                      }) {
                        final badgeCount =
                            badgeOverride ??
                            (notificationType == null
                                ? 0
                                : unreadCountForType(items, notificationType));
                        return SizedBox(
                          width: itemWidth,
                          child: _buildMenuShortcut(
                            ctx,
                            icon,
                            label,
                            route,
                            badgeCount: badgeCount,
                            onBeforeNavigate: notificationType == null
                                ? null
                                : () => unawaited(
                                    ref
                                        .read(
                                          notificationCenterProvider.notifier,
                                        )
                                        .markTypeAsRead(
                                          notificationType,
                                          items,
                                        ),
                                  ),
                          ),
                        );
                      }

                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.start,
                        children: isAuthenticated
                            ? [
                                shortcut(
                                  icon: Icons.newspaper,
                                  label: 'Notícias',
                                  route: '/noticias',
                                  notificationType:
                                      NotificationCenterItemType.noticia,
                                ),
                                shortcut(
                                  icon: Icons.live_tv_rounded,
                                  label: 'TV MPPB',
                                  route: '/videos',
                                  notificationType:
                                      NotificationCenterItemType.live,
                                ),
                                shortcut(
                                  icon: Icons.description,
                                  label: 'Diário',
                                  route: '/diario_oficial',
                                ),
                                shortcut(
                                  icon: Icons.verified_outlined,
                                  label: 'Certidão',
                                  route: '/certidao-extrajudicial',
                                ),
                                shortcut(
                                  icon: Icons.assignment,
                                  label: 'Pagamentos',
                                  route: '/pagamentos',
                                  notificationType:
                                      NotificationCenterItemType.pagamento,
                                ),
                                shortcut(
                                  icon: Icons.assignment_ind,
                                  label: 'Designações',
                                  route: '/designacoes',
                                  notificationType:
                                      NotificationCenterItemType.designacao,
                                ),
                                shortcut(
                                  icon: Icons.gavel,
                                  label: 'Processos',
                                  route: '/processos',
                                ),
                                shortcut(
                                  icon: Icons.account_circle_rounded,
                                  label: 'Perfil',
                                  route: '/perfil',
                                ),
                                shortcut(
                                  icon: Icons.record_voice_over,
                                  label: 'Ouvidoria',
                                  route: '/ouvidoria',
                                ),
                                shortcut(
                                  icon: Icons.campaign_rounded,
                                  label: 'Avisos',
                                  route: '/mensagens',
                                  badgeOverride: avisosNaoLidos,
                                ),
                                if (podeEnviar)
                                  shortcut(
                                    icon: Icons.edit_notifications_rounded,
                                    label: 'Painel Avisos',
                                    route: '/mensagens/painel',
                                  ),
                              ]
                            : [
                                shortcut(
                                  icon: Icons.record_voice_over,
                                  label: 'Ouvidoria',
                                  route: '/ouvidoria',
                                ),
                                shortcut(
                                  icon: Icons.verified_outlined,
                                  label: 'Certidão',
                                  route: '/certidao-extrajudicial',
                                ),
                                shortcut(
                                  icon: Icons.live_tv_rounded,
                                  label: 'TV MPPB',
                                  route: '/videos',
                                  notificationType:
                                      NotificationCenterItemType.live,
                                ),
                                shortcut(
                                  icon: Icons.lock,
                                  label: 'Área Restrita',
                                  route: '/login',
                                ),
                              ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildMenuShortcut(
    BuildContext context,
    IconData icon,
    String label,
    String route, {
    int badgeCount = 0,
    VoidCallback? onBeforeNavigate,
  }) {
    return GestureDetector(
      onTap: () {
        onBeforeNavigate?.call();
        Navigator.pop(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(route);
        });
      },
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x26343A40)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10101828),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -12,
                child: Icon(icon, color: const Color(0x1A343A40), size: 52),
              ),
              if (badgeCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 16,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD62828),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 10, right: 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Color(0xFF202322),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
