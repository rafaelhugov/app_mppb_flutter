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
                      decoration: BoxDecoration(
                        color: MensagensColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: MensagensColors.border),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D101828),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: MensagensColors.brandDark,
                          foregroundColor: Colors.white,
                          child: Icon(Icons.groups_rounded),
                        ),
                        title: Text(
                          g.nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: MensagensColors.ink,
                          ),
                        ),
                        subtitle: Text(
                          '${g.quantidadeMembros} participante(s)'
                          '${g.descricao != null && g.descricao!.isNotEmpty ? " • ${g.descricao}" : ""}',
                          style: const TextStyle(color: MensagensColors.muted),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Editar grupo',
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: MensagensColors.ink,
                              ),
                              onPressed: () =>
                                  _abrirEditorGrupo(context, existente: g),
                            ),
                            IconButton(
                              tooltip: 'Remover grupo',
                              icon: const Icon(
                                Icons.delete_outline,
                                color: MensagensColors.red,
                              ),
                              onPressed: () => ref
                                  .read(gruposMensagemProvider.notifier)
                                  .remover(g.id),
                            ),
                          ],
                        ),
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
