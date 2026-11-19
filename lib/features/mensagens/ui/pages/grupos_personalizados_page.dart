import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/main_layout.dart';
import '../../../../core/ui/widgets/hero_header_publico.dart';
import '../../data/mensagens_repository.dart';
import '../../models/grupo_mensagem_model.dart';
import '../../providers/grupos_mensagem_provider.dart';
import '../widgets/mensagens_theme.dart';

class GruposPersonalizadosPage extends ConsumerWidget {
  const GruposPersonalizadosPage({super.key});

  Future<void> _abrirDialogGrupo(
    BuildContext context,
    WidgetRef ref, {
    GrupoPersonalizadoModel? existente,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _EditorGrupoDialog(existente: existente),
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
                onPressed: () => _abrirDialogGrupo(context, ref),
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
                                  _abrirDialogGrupo(context, ref, existente: g),
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

class _EditorGrupoDialog extends ConsumerStatefulWidget {
  const _EditorGrupoDialog({this.existente});

  final GrupoPersonalizadoModel? existente;

  @override
  ConsumerState<_EditorGrupoDialog> createState() => _EditorGrupoDialogState();
}

class _EditorGrupoDialogState extends ConsumerState<_EditorGrupoDialog> {
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _descCtrl;
  final TextEditingController _buscaCtrl = TextEditingController();
  late final List<String> _matriculas;
  List<DestinatarioRhModel> _resultados = const [];
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.existente?.nome ?? '');
    _descCtrl = TextEditingController(text: widget.existente?.descricao ?? '');
    _matriculas = [...(widget.existente?.matriculas ?? const [])];
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descCtrl.dispose();
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _buscar(String termo) async {
    if (termo.trim().length < 2) {
      setState(() => _resultados = const []);
      return;
    }
    try {
      final res = await ref
          .read(mensagensRepositoryProvider)
          .buscarDestinatarios(termo.trim());
      if (mounted) setState(() => _resultados = res);
    } catch (_) {}
  }

  Future<void> _salvar() async {
    final nome = _nomeCtrl.text.trim();
    if (nome.isEmpty) return;
    setState(() => _salvando = true);
    try {
      final notifier = ref.read(gruposMensagemProvider.notifier);
      if (widget.existente == null) {
        await notifier.criar(
          nome: nome,
          descricao: _descCtrl.text.trim(),
          matriculas: _matriculas,
        );
      } else {
        await notifier.atualizar(
          widget.existente!.id,
          nome: nome,
          descricao: _descCtrl.text.trim(),
          matriculas: _matriculas,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: MensagensColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        widget.existente == null ? 'Novo Grupo' : 'Editar Grupo',
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: MensagensColors.ink,
        ),
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nomeCtrl,
                decoration: InputDecoration(
                  labelText: 'Nome do grupo *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _buscaCtrl,
                decoration: InputDecoration(
                  labelText: 'Adicionar membro/servidor (nome ou matrícula)',
                  prefixIcon: const Icon(Icons.person_search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _buscar,
              ),
              if (_resultados.isNotEmpty) ...[
                const SizedBox(height: 6),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    itemCount: _resultados.length,
                    itemBuilder: (_, idx) {
                      final r = _resultados[idx];
                      final jaTem = _matriculas.contains(r.matricula);
                      return ListTile(
                        dense: true,
                        title: Text('${r.nome} (${r.matricula})'),
                        trailing: Icon(
                          jaTem ? Icons.check : Icons.add,
                          color: jaTem
                              ? MensagensColors.green
                              : MensagensColors.ink,
                        ),
                        onTap: () {
                          if (!jaTem) {
                            setState(() => _matriculas.add(r.matricula));
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                'Matrículas no grupo (${_matriculas.length}):',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  color: MensagensColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: _matriculas.map((m) {
                  return InputChip(
                    label: Text(m),
                    onDeleted: () => setState(() => _matriculas.remove(m)),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _salvando ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: MensagensColors.muted),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: MensagensColors.green,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _salvando ? null : _salvar,
          child: const Text(
            'Salvar Grupo',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
