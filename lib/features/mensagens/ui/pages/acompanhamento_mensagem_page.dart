import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/acompanhamento_mensagem_model.dart';
import '../../models/mensagem_aviso_model.dart';
import '../../providers/acompanhamento_provider.dart';

class AcompanhamentoMensagemPage extends ConsumerStatefulWidget {
  const AcompanhamentoMensagemPage({super.key, required this.mensagemId});

  final int mensagemId;

  @override
  ConsumerState<AcompanhamentoMensagemPage> createState() =>
      _AcompanhamentoMensagemPageState();
}

class _AcompanhamentoMensagemPageState
    extends ConsumerState<AcompanhamentoMensagemPage> {
  StatusDestinatario? _statusFiltro;
  String _busca = '';
  final TextEditingController _buscaCtrl = TextEditingController();

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  String _formatarData(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final filtro = AcompanhamentoFiltro(
      mensagemId: widget.mensagemId,
      status: _statusFiltro,
      busca: _busca,
    );
    final asyncData = ref.watch(acompanhamentoMensagemProvider(filtro));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: const Text('Acompanhamento de Leitura'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () => ref.invalidate(acompanhamentoMensagemProvider(filtro)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: ElevatedButton(
            onPressed: () =>
                ref.invalidate(acompanhamentoMensagemProvider(filtro)),
            child: const Text('Tentar novamente'),
          ),
        ),
        data: (dados) => _buildConteudo(dados),
      ),
    );
  }

  Widget _buildConteudo(AcompanhamentoMensagemModel dados) {
    final resumo = dados.resumo;
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                resumo.titulo ?? 'Aviso institucional #${resumo.id}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ResumoBox(
                    titulo: 'Total',
                    valor: resumo.totalDestinatarios,
                    cor: const Color(0xFF334155),
                  ),
                  _ResumoBox(
                    titulo: 'Entregues',
                    valor: resumo.totalEntregues,
                    cor: const Color(0xFF0284C7),
                  ),
                  _ResumoBox(
                    titulo: 'Lidos',
                    valor: resumo.totalLidos,
                    cor: const Color(0xFF15803D),
                  ),
                  if (resumo.exigeCiencia)
                    _ResumoBox(
                      titulo: 'Cientes',
                      valor: resumo.totalCientes,
                      cor: const Color(0xFFD97706),
                    ),
                  _ResumoBox(
                    titulo: 'Pendentes',
                    valor: resumo.totalPendentes,
                    cor: const Color(0xFFB91C1C),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _buscaCtrl,
                decoration: InputDecoration(
                  hintText: 'Filtrar por nome, matrícula ou setor...',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: const OutlineInputBorder(),
                  suffixIcon: _busca.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _buscaCtrl.clear();
                            setState(() => _busca = '');
                          },
                        )
                      : null,
                ),
                onChanged: (v) => setState(() => _busca = v.trim()),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Todos'),
                      selected: _statusFiltro == null,
                      onSelected: (_) => setState(() => _statusFiltro = null),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Lidos'),
                      selected: _statusFiltro == StatusDestinatario.lido,
                      onSelected: (_) => setState(
                        () => _statusFiltro = StatusDestinatario.lido,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Entregues'),
                      selected: _statusFiltro == StatusDestinatario.entregue,
                      onSelected: (_) => setState(
                        () => _statusFiltro = StatusDestinatario.entregue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Pendentes'),
                      selected: _statusFiltro == StatusDestinatario.pendente,
                      onSelected: (_) => setState(
                        () => _statusFiltro = StatusDestinatario.pendente,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: dados.destinatarios.isEmpty
              ? const Center(
                  child: Text('Nenhum destinatário encontrado neste filtro.'),
                )
              : ListView.separated(
                  itemCount: dados.destinatarios.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final d = dados.destinatarios[index];
                    return ListTile(
                      title: Text(
                        '${d.nome} (${d.matricula})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (d.setor != null && d.setor!.isNotEmpty)
                            Text(d.setor!, style: const TextStyle(fontSize: 12)),
                          Text(
                            'Entregue: ${_formatarData(d.dataEntrega)} • Lido: ${_formatarData(d.dataLeitura)}'
                            '${d.dataCiencia != null ? " • Ciente: ${_formatarData(d.dataCiencia)}" : ""}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                      trailing: _StatusBadge(status: d.status),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ResumoBox extends StatelessWidget {
  const _ResumoBox({
    required this.titulo,
    required this.valor,
    required this.cor,
  });

  final String titulo;
  final int valor;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$valor',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
        Text(
          titulo,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final StatusDestinatario status;

  @override
  Widget build(BuildContext context) {
    final (cor, texto) = switch (status) {
      StatusDestinatario.lido => (const Color(0xFF15803D), 'LIDO'),
      StatusDestinatario.entregue => (const Color(0xFF0284C7), 'ENTREGUE'),
      StatusDestinatario.pendente => (const Color(0xFF64748B), 'PENDENTE'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: cor,
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

