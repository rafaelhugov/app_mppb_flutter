import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServicesBottomSheet {
  static void show(BuildContext context, bool isAuthenticated) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFDF7EF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x29432B1D),
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
                          color: Color(0xFF2F2923),
                          fontSize: 15,
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
                            color: const Color(0xFF9C7A54).withAlpha(36),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Color(0xFF73543E),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.start,
                    children: isAuthenticated
                        ? [
                            SizedBox(
                              width: (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.newspaper,
                                'Notícias',
                                '/noticias',
                              ),
                            ),
                            SizedBox(
                              width: (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.description,
                                'Diário',
                                '/diario_oficial',
                              ),
                            ),
                            SizedBox(
                              width: (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.assignment,
                                'Pagamentos',
                                '/pagamentos',
                              ),
                            ),
                            SizedBox(
                              width: (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.event_available,
                                'Concessões',
                                '/concessao-folga',
                              ),
                            ),
                            SizedBox(
                              width: (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.assignment_ind,
                                'Designações',
                                '/designacoes',
                              ),
                            ),
                            SizedBox(
                              width: (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.gavel,
                                'Processos',
                                '/processos',
                              ),
                            ),
                            SizedBox(
                              width: (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.record_voice_over,
                                'Ouvidoria',
                                '/ouvidoria',
                              ),
                            ),
                          ]
                        : [
                            SizedBox(
                              width: (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.record_voice_over,
                                'Ouvidoria',
                                '/ouvidoria',
                              ),
                            ),
                            SizedBox(
                              width: (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.lock,
                                'Área Restrita',
                                '/login',
                              ),
                            ),
                          ],
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
    String route,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(route);
        });
      },
      child: Container(
        padding: const EdgeInsets.only(top: 16, bottom: 12, left: 8, right: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF9C7A54).withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF8F2A1D).withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF8F2A1D), size: 22),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: const TextStyle(
                  color: Color(0xFF3A2416),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
