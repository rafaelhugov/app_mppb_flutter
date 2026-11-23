import 'dart:async';

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
  Timer? _autoRefreshTimer;

  AcompanhamentoFiltro get _filtroAtual => AcompanhamentoFiltro(
    mensagemId: widget.mensagemId,
    status: _statusFiltro,
    busca: _busca,
  );

  @override
  void initState() {
    super.initState();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        ref.invalidate(acompanhamentoMensagemProvider(_filtroAtual));
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
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
              : _buildSecoesWhatsApp(
                  dados.destinatarios,
                  horizontalPadding,
                  bottomPadding,
                ),
        ),
      ],
    );
  }

  Widget _buildSecoesWhatsApp(
    List<DestinatarioStatusModel> lista,
    double horizontalPadding,
    double bottomPadding,
  ) {
    final cientes = lista.where((d) => d.dataCiencia != null).toList();
    final lidos = lista
        .where((d) => d.dataCiencia == null && d.dataLeitura != null)
        .toList();
    final entregues = lista
        .where(
          (d) =>
              d.dataCiencia == null &&
              d.dataLeitura == null &&
              d.dataEntrega != null,
        )
        .toList();
    final pendentes = lista
        .where(
          (d) =>
              d.dataCiencia == null &&
              d.dataLeitura == null &&
              d.dataEntrega == null,
        )
        .toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        4,
        horizontalPadding,
        bottomPadding,
      ),
      children: [
        if (cientes.isNotEmpty)
          _SecaoConfirmacaoWhatsApp(
            titulo: 'Ciente por',
            icone: Icons.verified_rounded,
            corIcone: MensagensColors.green,
            itens: cientes,
            obterData: (d) => d.dataCiencia,
            formatarData: _formatarData,
          ),
        if (lidos.isNotEmpty)
          _SecaoConfirmacaoWhatsApp(
            titulo: 'Lida por',
            icone: Icons.done_all_rounded,
            corIcone: const Color(0xFF53BDEB),
            itens: lidos,
            obterData: (d) => d.dataLeitura,
            formatarData: _formatarData,
          ),
        if (entregues.isNotEmpty)
          _SecaoConfirmacaoWhatsApp(
            titulo: 'Entregue para',
            icone: Icons.done_all_rounded,
            corIcone: MensagensColors.muted,
            itens: entregues,
            obterData: (d) => d.dataEntrega,
            formatarData: _formatarData,
          ),
        if (pendentes.isNotEmpty)
          _SecaoConfirmacaoWhatsApp(
            titulo: 'Pendente',
            icone: Icons.schedule_rounded,
            corIcone: MensagensColors.muted,
            itens: pendentes,
            obterData: (_) => null,
            formatarData: _formatarData,
          ),
      ],
    );
  }
}

class _SecaoConfirmacaoWhatsApp extends StatelessWidget {
  const _SecaoConfirmacaoWhatsApp({
    required this.titulo,
    required this.icone,
    required this.corIcone,
    required this.itens,
    required this.obterData,
    required this.formatarData,
  });

  final String titulo;
  final IconData icone;
  final Color corIcone;
  final List<DestinatarioStatusModel> itens;
  final DateTime? Function(DestinatarioStatusModel) obterData;
  final String Function(DateTime?) formatarData;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: MensagensColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MensagensColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: MensagensColors.ink,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${itens.length})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: MensagensColors.muted,
                  ),
                ),
                const Spacer(),
                Icon(icone, size: 17, color: corIcone),
              ],
            ),
          ),
          const Divider(height: 1, color: MensagensColors.border),
          for (var i = 0; i < itens.length; i++) ...[
            _LinhaDestinatarioDiscreta(
              destinatario: itens[i],
              dataTexto: obterData(itens[i]) != null
                  ? formatarData(obterData(itens[i]))
                  : 'Aguardando',
            ),
            if (i < itens.length - 1)
              const Divider(
                height: 1,
                indent: 66,
                endIndent: 14,
                color: MensagensColors.border,
              ),
          ],
        ],
      ),
    );
  }
}

class _LinhaDestinatarioDiscreta extends StatelessWidget {
  const _LinhaDestinatarioDiscreta({
    required this.destinatario,
    required this.dataTexto,
  });

  final DestinatarioStatusModel destinatario;
  final String dataTexto;

  @override
  Widget build(BuildContext context) {
    final nomeFormatado = formatarNomeProprio(destinatario.nome);
    final subtitulo =
        destinatario.setor != null && destinatario.setor!.trim().isNotEmpty
            ? '${destinatario.setor!.trim()} • Mat. ${destinatario.matricula}'
            : 'Mat. ${destinatario.matricula}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          RemetenteAvatar(
            nome: nomeFormatado,
            matricula: destinatario.matricula,
            size: 38,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nomeFormatado,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: MensagensColors.ink,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: MensagensColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            dataTexto,
            style: const TextStyle(
              fontSize: 11.5,
              color: MensagensColors.muted,
            ),
          ),
        ],
      ),
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
