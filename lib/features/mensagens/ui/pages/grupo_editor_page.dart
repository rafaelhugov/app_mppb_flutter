import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/app_feedback.dart';
import '../../../../core/ui/main_layout.dart';
import '../../../../core/ui/widgets/hero_header_publico.dart';
import '../../data/mensagens_repository.dart';
import '../../models/grupo_mensagem_model.dart';
import '../../providers/grupos_mensagem_provider.dart';
import '../widgets/mensagens_theme.dart';
import '../widgets/remetente_avatar.dart';

class GrupoEditorPage extends ConsumerStatefulWidget {
  const GrupoEditorPage({super.key, this.existente});

  final GrupoPersonalizadoModel? existente;

  @override
  ConsumerState<GrupoEditorPage> createState() => _GrupoEditorPageState();
}

class _GrupoEditorPageState extends ConsumerState<GrupoEditorPage> {
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _descCtrl;
  final TextEditingController _buscaCtrl = TextEditingController();
  late final List<String> _matriculas;
  final Map<String, String> _nomesPorMatricula = {};
  List<DestinatarioRhModel> _resultados = const [];
  bool _buscando = false;
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
      setState(() {
        _resultados = const [];
        _buscando = false;
      });
      return;
    }
    setState(() => _buscando = true);
    try {
      final res = await ref
          .read(mensagensRepositoryProvider)
          .buscarDestinatarios(termo.trim());
      if (mounted) {
        setState(() {
          _resultados = res;
          _buscando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _buscando = false);
    }
  }

  Future<void> _salvar() async {
    final nome = _nomeCtrl.text.trim();
    if (nome.isEmpty) {
      AppFeedback.showWarning(context, 'Informe o nome do grupo.');
      return;
    }
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
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  InputDecoration _inputDecoration(String label, {Widget? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      floatingLabelStyle: const TextStyle(
        color: MensagensColors.brandDark,
        fontWeight: FontWeight.w700,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: MensagensColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: MensagensColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: MensagensColors.brandDark,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MainLayout.horizontalPadding(context);
    final bottomPadding = MainLayout.contentBottomPadding(context);

    return Scaffold(
      backgroundColor: MensagensColors.background,
      body: Column(
        children: [
          HeroHeaderPublico(
            label: '',
            title: widget.existente == null ? 'Novo Grupo' : 'Editar Grupo',
            subtitle: '',
            icon: Icons.groups_rounded,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                8,
                horizontalPadding,
                bottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dados do Grupo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: MensagensColors.ink,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _nomeCtrl,
                          decoration: _inputDecoration('Nome do grupo *'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _descCtrl,
                          decoration: _inputDecoration('Descrição (opcional)'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Participantes (${_matriculas.length})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: MensagensColors.ink,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _buscaCtrl,
                          decoration: _inputDecoration(
                            'Buscar membro ou servidor (nome ou matrícula)',
                            prefixIcon: const Icon(
                              Icons.person_search_rounded,
                              color: MensagensColors.ink,
                            ),
                            suffixIcon: _buscando
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: MensagensColors.green,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          onChanged: _buscar,
                        ),
                        if (_resultados.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 220),
                            decoration: BoxDecoration(
                              color: MensagensColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: MensagensColors.border),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: _resultados.length,
                              separatorBuilder: (_, _) => const Divider(
                                height: 1,
                                color: MensagensColors.border,
                              ),
                              itemBuilder: (_, idx) {
                                final r = _resultados[idx];
                                final jaTem = _matriculas.contains(r.matricula);
                                return ListTile(
                                  dense: true,
                                  leading: RemetenteAvatar(
                                    nome: r.nome,
                                    matricula: r.matricula,
                                    size: 36,
                                  ),
                                  title: Text(
                                    r.nome,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: MensagensColors.ink,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Matrícula ${r.matricula} • ${r.setorNome ?? r.cargoNome ?? ""}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: MensagensColors.muted,
                                    ),
                                  ),
                                  trailing: Icon(
                                    jaTem
                                        ? Icons.check_circle_rounded
                                        : Icons.add_circle_outline_rounded,
                                    color: jaTem
                                        ? MensagensColors.green
                                        : MensagensColors.ink,
                                  ),
                                  onTap: () {
                                    if (!jaTem) {
                                      setState(() {
                                        _matriculas.add(r.matricula);
                                        _nomesPorMatricula[r.matricula] = r.nome;
                                        _buscaCtrl.clear();
                                        _resultados = const [];
                                      });
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        if (_matriculas.isEmpty)
                          const Text(
                            'Nenhum participante adicionado ainda.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: MensagensColors.muted,
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _matriculas.length,
                            separatorBuilder: (_, _) => const Divider(
                              height: 1,
                              color: MensagensColors.border,
                            ),
                            itemBuilder: (_, index) {
                              final m = _matriculas[index];
                              final nome = _nomesPorMatricula[m];
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: RemetenteAvatar(
                                  nome: nome ?? m,
                                  matricula: m,
                                  size: 34,
                                ),
                                title: Text(
                                  nome != null ? '$nome ($m)' : 'Matrícula $m',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: MensagensColors.ink,
                                  ),
                                ),
                                trailing: IconButton(
                                  tooltip: 'Remover participante',
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: MensagensColors.red,
                                    size: 18,
                                  ),
                                  onPressed: () =>
                                      setState(() => _matriculas.remove(m)),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MensagensColors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _salvando ? null : _salvar,
                      icon: _salvando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded),
                      label: const Text(
                        'Salvar Grupo',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
