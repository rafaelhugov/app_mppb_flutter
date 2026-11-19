import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mensagens_repository.dart';
import '../../models/grupo_mensagem_model.dart';
import '../../providers/grupos_mensagem_provider.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: const Text('Grupos Personalizados'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF15803D),
        foregroundColor: Colors.white,
        onPressed: () => _abrirDialogGrupo(context, ref),
        icon: const Icon(Icons.group_add),
        label: const Text('Novo Grupo'),
      ),
      body: asyncGrupos.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: ElevatedButton(
            onPressed: () =>
                ref.read(gruposMensagemProvider.notifier).recarregar(),
            child: const Text('Tentar novamente'),
          ),
        ),
        data: (grupos) {
          if (grupos.isEmpty) {
            return const Center(
              child: Text('Nenhum grupo personalizado cadastrado.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 88),
            itemCount: grupos.length,
            itemBuilder: (context, index) {
              final g = grupos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    child: Icon(Icons.groups),
                  ),
                  title: Text(
                    g.nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${g.quantidadeMembros} participante(s)'
                    '${g.descricao != null && g.descricao!.isNotEmpty ? " • ${g.descricao}" : ""}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Editar grupo',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () =>
                            _abrirDialogGrupo(context, ref, existente: g),
                      ),
                      IconButton(
                        tooltip: 'Remover grupo',
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
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
      title: Text(
        widget.existente == null ? 'Novo Grupo' : 'Editar Grupo',
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
                decoration: const InputDecoration(
                  labelText: 'Nome do grupo *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _buscaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Adicionar membro/servidor (nome ou matrícula)',
                  prefixIcon: Icon(Icons.person_search),
                  border: OutlineInputBorder(),
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
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
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
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _salvando ? null : _salvar,
          child: const Text('Salvar Grupo'),
        ),
      ],
    );
  }
}

