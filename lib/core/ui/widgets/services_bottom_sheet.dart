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
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.start,
                    children: isAuthenticated
                        ? [
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.newspaper,
                                'Notícias',
                                '/noticias',
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.description,
                                'Diário',
                                '/diario_oficial',
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.verified_outlined,
                                'Certidão',
                                '/certidao-extrajudicial',
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.assignment,
                                'Pagamentos',
                                '/pagamentos',
                              ),
                            ),

                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.assignment_ind,
                                'Designações',
                                '/designacoes',
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.gavel,
                                'Processos',
                                '/processos',
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 70) / 4,
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
                              width:
                                  (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.record_voice_over,
                                'Ouvidoria',
                                '/ouvidoria',
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 70) / 4,
                              child: _buildMenuShortcut(
                                ctx,
                                Icons.verified_outlined,
                                'Certidão',
                                '/certidao-extrajudicial',
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 70) / 4,
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
                child: Icon(
                  icon,
                  color: const Color(0x1A343A40),
                  size: 52,
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
