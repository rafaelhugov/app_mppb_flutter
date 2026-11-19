import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/ui/main_layout.dart';
import '../../../../core/ui/widgets/hero_header_publico.dart';
import '../../models/acompanhamento_mensagem_model.dart';
import '../../models/mensagem_aviso_model.dart';
import '../../providers/acompanhamento_provider.dart';
import '../widgets/mensagens_theme.dart';

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
      backgroundColor: MensagensColors.background,
      body: Column(
        children: [
          HeroHeaderPublico(
            label: '',
            title: 'Acompanhamento de Leitura',
            subtitle: '',
            icon: Icons.analytics_outlined,
            rightWidget: MensagensHeaderIconButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Atualizar',
              onPressed: () =>
                  ref.invalidate(acompanhamentoMensagemProvider(filtro)),
            ),
          ),
          Expanded(
            child: asyncData.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: MensagensColors.green),
              ),
              error: (_, _) => MensagensErrorState(
                message: 'Não foi possível carregar o acompanhamento.',
                onRetry: () =>
                    ref.invalidate(acompanhamentoMensagemProvider(filtro)),
              ),
              data: (dados) => _buildConteudo(context, dados),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConteudo(
    BuildContext context,
    AcompanhamentoMensagemModel dados,
  ) {
    final resumo = dados.resumo;
    final horizontalPadding = MainLayout.horizontalPadding(context);
    final bottomPadding = MainLayout.contentBottomPadding(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            4,
            horizontalPadding,
            8,
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
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
                  resumo.titulo ?? 'Aviso institucional #${resumo.id}',
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: MensagensColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: MensagensColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: MensagensColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ResumoBox(
                        titulo: 'Total',
                        valor: resumo.totalDestinatarios,
                        cor: MensagensColors.ink,
                      ),
                      _ResumoBox(
                        titulo: 'Entregues',
                        valor: resumo.totalEntregues,
                        cor: MensagensColors.blue,
                      ),
                      _ResumoBox(
                        titulo: 'Lidos',
                        valor: resumo.totalLidos,
                        cor: MensagensColors.green,
                      ),
                      if (resumo.exigeCiencia)
                        _ResumoBox(
                          titulo: 'Cientes',
                          valor: resumo.totalCientes,
                          cor: MensagensColors.orange,
                        ),
                      _ResumoBox(
                        titulo: 'Pendentes',
                        valor: resumo.totalPendentes,
                        cor: MensagensColors.red,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _buscaCtrl,
                  decoration: InputDecoration(
                    hintText: 'Filtrar por nome, matrícula ou setor...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                const SizedBox(height: 10),
                MensagensSegmentedPillBar<StatusDestinatario?>(
                  maxWidth: double.infinity,
                  selectedValue: _statusFiltro,
                  onSelected: (novo) => setState(() => _statusFiltro = novo),
                  items: const [
                    MensagensSegmentItem(
                      value: null,
                      label: 'Todos',
                    ),
                    MensagensSegmentItem(
                      value: StatusDestinatario.lido,
                      label: 'Lidos',
                    ),
                    MensagensSegmentItem(
                      value: StatusDestinatario.entregue,
                      label: 'Entregues',
                    ),
                    MensagensSegmentItem(
                      value: StatusDestinatario.pendente,
                      label: 'Pendentes',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: dados.destinatarios.isEmpty
              ? const MensagensEmptyState(
                  message: 'Nenhum destinatário encontrado neste filtro.',
                  icon: Icons.people_outline,
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    4,
                    horizontalPadding,
                    bottomPadding,
                  ),
                  itemCount: dados.destinatarios.length,
                  itemBuilder: (context, index) {
                    final d = dados.destinatarios[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: MensagensColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: MensagensColors.border),
                      ),
                      child: ListTile(
                        title: Text(
                          '${d.nome} (${d.matricula})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: MensagensColors.ink,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (d.setor != null && d.setor!.isNotEmpty)
                              Text(
                                d.setor!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: MensagensColors.muted,
                                ),
                              ),
                            Text(
                              'Entregue: ${_formatarData(d.dataEntrega)} • Lido: ${_formatarData(d.dataLeitura)}'
                              '${d.dataCiencia != null ? " • Ciente: ${_formatarData(d.dataCiencia)}" : ""}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: MensagensColors.muted,
                              ),
                            ),
                          ],
                        ),
                        trailing: _StatusBadge(status: d.status),
                      ),
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
            fontWeight: FontWeight.w800,
            color: cor,
          ),
        ),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 11,
            color: MensagensColors.muted,
          ),
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
      StatusDestinatario.lido => (MensagensColors.green, 'LIDO'),
      StatusDestinatario.entregue => (MensagensColors.blue, 'ENTREGUE'),
      StatusDestinatario.pendente => (MensagensColors.muted, 'PENDENTE'),
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
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
