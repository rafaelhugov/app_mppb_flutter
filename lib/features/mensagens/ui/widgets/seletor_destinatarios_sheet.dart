import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mensagens_repository.dart';
import '../../models/grupo_mensagem_model.dart';
import '../../models/mensagem_aviso_model.dart';
import '../../providers/envio_mensagem_provider.dart';
import 'mensagens_theme.dart';
import 'remetente_avatar.dart';

class SeletorDestinatariosWidget extends ConsumerStatefulWidget {
  const SeletorDestinatariosWidget({super.key});

  @override
  ConsumerState<SeletorDestinatariosWidget> createState() =>
      _SeletorDestinatariosWidgetState();
}

class _SeletorDestinatariosWidgetState
    extends ConsumerState<SeletorDestinatariosWidget> {
  CatalogoGruposRhModel? _catalogo;
  List<GrupoPersonalizadoModel> _gruposPersonalizados = const [];
  List<DestinatarioRhModel> _resultadosBusca = const [];
  final TextEditingController _buscaCtrl = TextEditingController();
  bool _carregandoCatalogo = false;
  bool _buscando = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_carregarDadosIniciais);
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosIniciais() async {
    setState(() => _carregandoCatalogo = true);
    try {
      final repo = ref.read(mensagensRepositoryProvider);
      final results = await Future.wait([
        repo.catalogoGruposRh(),
        repo.listarGruposPersonalizados(),
      ]);
      if (!mounted) return;
      setState(() {
        _catalogo = results[0] as CatalogoGruposRhModel;
        _gruposPersonalizados = results[1] as List<GrupoPersonalizadoModel>;
        _carregandoCatalogo = false;
      });
      await ref.read(envioMensagemProvider.notifier).atualizarPreviaAlcance();
    } catch (_) {
      if (mounted) setState(() => _carregandoCatalogo = false);
    }
  }

  Future<void> _buscarServidores(String termo) async {
    if (termo.trim().length < 2) {
      setState(() => _resultadosBusca = const []);
      return;
    }
    setState(() => _buscando = true);
    try {
      final lista = await ref
          .read(mensagensRepositoryProvider)
          .buscarDestinatarios(termo.trim());
      if (mounted) {
        setState(() {
          _resultadosBusca = lista;
          _buscando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _buscando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(envioMensagemProvider);
    final notifier = ref.read(envioMensagemProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Modalidade de Envio',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: MensagensColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        MensagensSegmentedPillBar<ModalidadeEnvio>(
          maxWidth: double.infinity,
          selectedValue: state.modalidade,
          onSelected: notifier.setModalidade,
          items: const [
            MensagensSegmentItem(
              value: ModalidadeEnvio.broadcast,
              icon: Icons.public,
              label: 'Broadcast',
            ),
            MensagensSegmentItem(
              value: ModalidadeEnvio.multicast,
              icon: Icons.groups,
              label: 'Multicast',
            ),
            MensagensSegmentItem(
              value: ModalidadeEnvio.unicast,
              icon: Icons.person,
              label: 'Unicast',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.modalidade == ModalidadeEnvio.broadcast)
          const Text(
            'Envia para todos os membros e servidores ativos do MPPB.',
            style: TextStyle(color: MensagensColors.muted, fontSize: 13),
          ),
        if (state.modalidade == ModalidadeEnvio.multicast)
          _buildMulticast(state, notifier),
        if (state.modalidade == ModalidadeEnvio.unicast)
          _buildUnicast(state, notifier),
      ],
    );
  }

  Widget _buildMulticast(
    EnvioMensagemState state,
    EnvioMensagemNotifier notifier,
  ) {
    if (_carregandoCatalogo) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(color: MensagensColors.green),
        ),
      );
    }

    final cat = _catalogo ?? const CatalogoGruposRhModel();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vínculo Funcional (RH)',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: MensagensColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: cat.tiposCargo.map((item) {
            final sel = state.tiposCargo.contains(item.id);
            return FilterChip(
              label: Text('${item.nome} (${item.quantidadeAtivos})'),
              selected: sel,
              selectedColor: MensagensColors.brandDark,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: sel ? Colors.white : MensagensColors.ink,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
              ),
              onSelected: (v) {
                final atual = [...state.tiposCargo];
                v ? atual.add(item.id) : atual.remove(item.id);
                notifier.atualizarCriteriosMulticast(tiposCargo: atual);
              },
            );
          }).toList(),
        ),
        if (_gruposPersonalizados.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Grupos Personalizados',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: MensagensColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: _gruposPersonalizados.map((g) {
              final sel = state.grupoPersonalizadoIds.contains(g.id);
              return FilterChip(
                label: Text('${g.nome} (${g.quantidadeMembros})'),
                selected: sel,
                selectedColor: MensagensColors.brandDark,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: sel ? Colors.white : MensagensColors.ink,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                ),
                onSelected: (v) {
                  final atual = [...state.grupoPersonalizadoIds];
                  v ? atual.add(g.id) : atual.remove(g.id);
                  notifier.atualizarCriteriosMulticast(
                    grupoPersonalizadoIds: atual,
                  );
                },
              );
            }).toList(),
          ),
        ],
        if (cat.setores.isNotEmpty) ...[
          const SizedBox(height: 12),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              'Setores / Lotações (${state.setorIds.length} selecionado(s))',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: MensagensColors.ink,
              ),
            ),
            children: [
              SizedBox(
                height: 180,
                child: ListView.builder(
                  itemCount: cat.setores.length,
                  itemBuilder: (context, idx) {
                    final st = cat.setores[idx];
                    final idNum = int.tryParse(st.id) ?? 0;
                    final sel = state.setorIds.contains(idNum);
                    return CheckboxListTile(
                      dense: true,
                      activeColor: MensagensColors.green,
                      value: sel,
                      title: Text('${st.nome} (${st.quantidadeAtivos})'),
                      onChanged: (v) {
                        final atual = [...state.setorIds];
                        v == true ? atual.add(idNum) : atual.remove(idNum);
                        notifier.atualizarCriteriosMulticast(setorIds: atual);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildUnicast(
    EnvioMensagemState state,
    EnvioMensagemNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _buscaCtrl,
          decoration: InputDecoration(
            labelText: 'Buscar servidor ou membro por nome ou matrícula',
            prefixIcon: const Icon(Icons.search),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: _buscarServidores,
        ),
        if (state.destinatariosUnicast.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              ...(state.destinatariosUnicast.length >= 3
                      ? state.destinatariosUnicast.take(2)
                      : state.destinatariosUnicast)
                  .map((d) {
                return InputChip(
                  avatar: RemetenteAvatar(
                    nome: d.nome,
                    matricula: d.matricula,
                    size: 24,
                  ),
                  label: Text(
                    '${formatarNomeProprio(d.nome)} (${d.matricula})',
                    overflow: TextOverflow.ellipsis,
                  ),
                  onDeleted: () {
                    final nova = state.destinatariosUnicast
                        .where((item) => item.matricula != d.matricula)
                        .toList();
                    notifier.definirDestinatariosUnicast(nova);
                  },
                );
              }),
              if (state.destinatariosUnicast.length >= 3)
                ActionChip(
                  avatar: const Icon(
                    Icons.groups_rounded,
                    size: 16,
                    color: MensagensColors.green,
                  ),
                  backgroundColor: MensagensColors.green.withValues(alpha: 0.1),
                  side: BorderSide(
                    color: MensagensColors.green.withValues(alpha: 0.3),
                  ),
                  label: Text(
                    '+${state.destinatariosUnicast.length - 2} selecionados • Ver todos',
                    style: const TextStyle(
                      color: MensagensColors.green,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                  onPressed: () => _abrirModalSelecionados(
                    context,
                    notifier,
                  ),
                ),
            ],
          ),
        ],
        if (_resultadosBusca.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: MensagensColors.surface,
              border: Border.all(color: MensagensColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _resultadosBusca.length,
              itemBuilder: (context, index) {
                final item = _resultadosBusca[index];
                final jaSelecionado = state.destinatariosUnicast.any(
                  (d) => d.matricula == item.matricula,
                );
                return ListTile(
                  dense: true,
                  leading: RemetenteAvatar(
                    nome: item.nome,
                    matricula: item.matricula,
                    size: 38,
                  ),
                  title: Text(
                    formatarNomeProprio(item.nome),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Matrícula: ${item.matricula} • ${item.setorNome ?? item.cargoNome ?? ""}',
                  ),
                  trailing: Icon(
                    jaSelecionado
                        ? Icons.check_circle
                        : Icons.add_circle_outline,
                    color: jaSelecionado
                        ? MensagensColors.green
                        : MensagensColors.muted,
                  ),
                  onTap: () {
                    if (jaSelecionado) return;
                    notifier.definirDestinatariosUnicast([
                      ...state.destinatariosUnicast,
                      item,
                    ]);
                    _buscaCtrl.clear();
                    setState(() => _resultadosBusca = const []);
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  void _abrirModalSelecionados(
    BuildContext context,
    EnvioMensagemNotifier notifier,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MensagensColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (ctx, modalRef, _) {
            final selecionados =
                modalRef.watch(envioMensagemProvider).destinatariosUnicast;
            return SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.65,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
                      child: Row(
                        children: [
                          Text(
                            'Destinatários (${selecionados.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: MensagensColors.ink,
                            ),
                          ),
                          const Spacer(),
                          if (selecionados.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                notifier.definirDestinatariosUnicast(const []);
                                Navigator.pop(ctx);
                              },
                              child: const Text(
                                'Limpar todos',
                                style: TextStyle(
                                  color: MensagensColors.red,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: MensagensColors.border),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: selecionados.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          indent: 64,
                          color: MensagensColors.border,
                        ),
                        itemBuilder: (_, idx) {
                          final d = selecionados[idx];
                          final nome = formatarNomeProprio(d.nome);
                          return ListTile(
                            leading: RemetenteAvatar(
                              nome: nome,
                              matricula: d.matricula,
                              size: 38,
                            ),
                            title: Text(
                              nome,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              'Mat. ${d.matricula}${d.setorNome != null ? " • ${d.setorNome}" : ""}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: MensagensColors.muted,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: MensagensColors.red,
                                size: 20,
                              ),
                              onPressed: () {
                                final nova = selecionados
                                    .where((x) => x.matricula != d.matricula)
                                    .toList();
                                notifier.definirDestinatariosUnicast(nova);
                                if (nova.isEmpty) Navigator.pop(ctx);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
