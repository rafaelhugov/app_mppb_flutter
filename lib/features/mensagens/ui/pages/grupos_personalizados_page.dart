import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/main_layout.dart';
import '../../../../core/ui/widgets/hero_header_publico.dart';
import '../../models/grupo_mensagem_model.dart';
import '../../providers/grupos_mensagem_provider.dart';
import '../widgets/mensagens_theme.dart';
import 'grupo_editor_page.dart';

class GruposPersonalizadosPage extends ConsumerWidget {
  const GruposPersonalizadosPage({super.key});

  Future<void> _abrirEditorGrupo(
    BuildContext context, {
    GrupoPersonalizadoModel? existente,
  }) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => GrupoEditorPage(existente: existente),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGrupos = ref.watch(gruposMensagemProvider);
    final horizontalPadding = MainLayout.horizontalPadding(context);
    final bottomPadding = MainLayout.contentBottomPadding(context);

    return Scaffold(
      backgroundColor: MensagensColors.background,
      body: Column(
        children: [
          const HeroHeaderPublico(
            label: '',
            title: 'Grupos Personalizados',
            subtitle: '',
            icon: Icons.groups_rounded,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              4,
              horizontalPadding,
              8,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MensagensColors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => _abrirEditorGrupo(context),
                icon: const Icon(Icons.group_add_rounded, size: 18),
                label: const Text(
                  'Novo Grupo',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          Expanded(
            child: asyncGrupos.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: MensagensColors.green),
              ),
              error: (_, _) => MensagensErrorState(
                message: 'Não foi possível carregar os grupos personalizados.',
                onRetry: () =>
                    ref.read(gruposMensagemProvider.notifier).recarregar(),
              ),
              data: (grupos) {
                if (grupos.isEmpty) {
                  return const MensagensEmptyState(
                    message: 'Nenhum grupo personalizado cadastrado.',
                    icon: Icons.groups_outlined,
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    8,
                    horizontalPadding,
                    bottomPadding,
                  ),
                  itemCount: grupos.length,
                  itemBuilder: (context, index) {
                    final g = grupos[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: MensagensColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: MensagensColors.border),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A101828),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: MensagensColors.green.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.groups_rounded,
                                  color: MensagensColors.green,
                                  size: 21,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      g.nome,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: MensagensColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: MensagensColors.surfaceMuted,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${g.quantidadeMembros} participante(s)',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: MensagensColors.muted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Editar grupo',
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: MensagensColors.ink,
                                ),
                                onPressed: () =>
                                    _abrirEditorGrupo(context, existente: g),
                              ),
                              IconButton(
                                tooltip: 'Remover grupo',
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: MensagensColors.red,
                                ),
                                onPressed: () => ref
                                    .read(gruposMensagemProvider.notifier)
                                    .remover(g.id),
                              ),
                            ],
                          ),
                          if (g.descricao != null &&
                              g.descricao!.trim().isNotEmpty) ...[
                            const SizedBox(height: 10),
                            const Divider(
                              height: 1,
                              color: MensagensColors.border,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              g.descricao!.trim(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                height: 1.35,
                                color: MensagensColors.muted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
