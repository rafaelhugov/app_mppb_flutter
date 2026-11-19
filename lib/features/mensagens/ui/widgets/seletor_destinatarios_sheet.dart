import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mensagens_repository.dart';
import '../../models/grupo_mensagem_model.dart';
import '../../models/mensagem_aviso_model.dart';
import '../../providers/envio_mensagem_provider.dart';

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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        SegmentedButton<ModalidadeEnvio>(
          segments: const [
            ButtonSegment(
              value: ModalidadeEnvio.broadcast,
              icon: Icon(Icons.public, size: 18),
              label: Text('Broadcast'),
            ),
            ButtonSegment(
              value: ModalidadeEnvio.multicast,
              icon: Icon(Icons.groups, size: 18),
              label: Text('Multicast'),
            ),
            ButtonSegment(
              value: ModalidadeEnvio.unicast,
              icon: Icon(Icons.person, size: 18),
              label: Text('Unicast'),
            ),
          ],
          selected: {state.modalidade},
          onSelectionChanged: (s) => notifier.setModalidade(s.first),
        ),
        const SizedBox(height: 12),
        if (state.modalidade == ModalidadeEnvio.broadcast)
          const Text(
            'Envia para todos os membros e servidores ativos do MPPB.',
            style: TextStyle(color: Color(0xFF475569), fontSize: 13),
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
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final cat = _catalogo ?? const CatalogoGruposRhModel();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vínculo Funcional (RH)',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: cat.tiposCargo.map((item) {
            final sel = state.tiposCargo.contains(item.id);
            return FilterChip(
              label: Text('${item.nome} (${item.quantidadeAtivos})'),
              selected: sel,
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
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: _gruposPersonalizados.map((g) {
              final sel = state.grupoPersonalizadoIds.contains(g.id);
              return FilterChip(
                label: Text('${g.nome} (${g.quantidadeMembros})'),
                selected: sel,
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
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            border: const OutlineInputBorder(),
          ),
          onChanged: _buscarServidores,
        ),
        if (state.destinatariosUnicast.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: state.destinatariosUnicast.map((d) {
              return InputChip(
                label: Text('${d.nome} (${d.matricula})'),
                onDeleted: () {
                  final nova = state.destinatariosUnicast
                      .where((item) => item.matricula != d.matricula)
                      .toList();
                  notifier.definirDestinatariosUnicast(nova);
                },
              );
            }).toList(),
          ),
        ],
        if (_resultadosBusca.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCBD5E1)),
              borderRadius: BorderRadius.circular(8),
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
                  title: Text(item.nome),
                  subtitle: Text(
                    'Matrícula: ${item.matricula} • ${item.setorNome ?? item.cargoNome ?? ""}',
                  ),
                  trailing: Icon(
                    jaSelecionado
                        ? Icons.check_circle
                        : Icons.add_circle_outline,
                    color: jaSelecionado
                        ? const Color(0xFF15803D)
                        : const Color(0xFF475569),
                  ),
                  onTap: () {
                    if (jaSelecionado) return;
                    notifier.definirDestinatariosUnicast([
                      ...state.destinatariosUnicast,
                      item,
                    ]);
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

