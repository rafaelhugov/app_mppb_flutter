import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/ui/main_layout.dart';
import '../../../../core/ui/widgets/hero_header_publico.dart';
import '../../models/acompanhamento_mensagem_model.dart';
import '../../models/mensagem_aviso_model.dart';
import '../../providers/acompanhamento_provider.dart';
import '../widgets/mensagens_theme.dart';
import '../widgets/remetente_avatar.dart';

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
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: MensagensColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: MensagensColors.border),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08101828),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              RemetenteAvatar(
                                nome: d.nome,
                                matricula: d.matricula,
                                size: 42,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d.nome,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: MensagensColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      d.setor != null && d.setor!.isNotEmpty
                                          ? 'Mat. ${d.matricula} • ${d.setor}'
                                          : 'Mat. ${d.matricula}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: MensagensColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              _StatusBadge(
                                status: d.status,
                                ciente: d.dataCiencia != null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(
                            height: 1,
                            color: MensagensColors.border,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _ConfirmacaoChip(
                                icon: Icons.done_all_rounded,
                                label: 'Entregue',
                                valor: d.dataEntrega != null
                                    ? _formatarData(d.dataEntrega)
                                    : 'Aguardando',
                                ativo: d.dataEntrega != null,
                                corAtiva: MensagensColors.blue,
                              ),
                              _ConfirmacaoChip(
                                icon: Icons.visibility_rounded,
                                label: 'Lido',
                                valor: d.dataLeitura != null
                                    ? _formatarData(d.dataLeitura)
                                    : 'Não lido',
                                ativo: d.dataLeitura != null,
                                corAtiva: MensagensColors.green,
                              ),
                              if (d.dataCiencia != null ||
                                  dados.resumo.exigeCiencia)
                                _ConfirmacaoChip(
                                  icon: Icons.verified_rounded,
                                  label: 'Ciente',
                                  valor: d.dataCiencia != null
                                      ? _formatarData(d.dataCiencia)
                                      : 'Pendente',
                                  ativo: d.dataCiencia != null,
                                  corAtiva: MensagensColors.green,
                                  corInativa: MensagensColors.orange,
                                ),
                            ],
                          ),
                        ],
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
  const _StatusBadge({required this.status, this.ciente = false});

  final StatusDestinatario status;
  final bool ciente;

  @override
  Widget build(BuildContext context) {
    final (cor, icone, texto) = ciente
        ? (MensagensColors.green, Icons.verified_rounded, 'CIENTE')
        : switch (status) {
            StatusDestinatario.lido => (
              MensagensColors.green,
              Icons.visibility_rounded,
              'LIDO',
            ),
            StatusDestinatario.entregue => (
              MensagensColors.blue,
              Icons.done_all_rounded,
              'ENTREGUE',
            ),
            StatusDestinatario.pendente => (
              MensagensColors.muted,
              Icons.schedule_rounded,
              'PENDENTE',
            ),
          };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 12.5, color: cor),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              color: cor,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmacaoChip extends StatelessWidget {
  const _ConfirmacaoChip({
    required this.icon,
    required this.label,
    required this.valor,
    required this.ativo,
    required this.corAtiva,
    this.corInativa = MensagensColors.muted,
  });

  final IconData icon;
  final String label;
  final String valor;
  final bool ativo;
  final Color corAtiva;
  final Color corInativa;

  @override
  Widget build(BuildContext context) {
    final cor = ativo ? corAtiva : corInativa;
    final bg = ativo
        ? corAtiva.withValues(alpha: 0.1)
        : MensagensColors.surfaceMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: ativo ? cor.withValues(alpha: 0.25) : MensagensColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.5, color: cor),
          const SizedBox(width: 5),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ativo ? MensagensColors.ink : MensagensColors.muted,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 11,
              fontWeight: ativo ? FontWeight.w600 : FontWeight.w500,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}
