import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/ui/main_layout.dart';
import '../../../../core/ui/widgets/hero_header_publico.dart';
import '../../models/acompanhamento_mensagem_model.dart';
import '../../models/mensagem_aviso_model.dart';
import '../../providers/acompanhamento_provider.dart';
import '../widgets/anexo_preview_widget.dart';
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        resumo.titulo ?? 'Aviso institucional #${resumo.id}',
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: MensagensColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _abrirModalMensagemEnviada(context, resumo),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: MensagensColors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: MensagensColors.green.withValues(alpha: 0.28),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: 14,
                              color: MensagensColors.green,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Ver aviso',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: MensagensColors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if ((resumo.conteudo?.trim().isNotEmpty ?? false) ||
                    resumo.anexos.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => _abrirModalMensagemEnviada(context, resumo),
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (resumo.conteudo?.trim().isNotEmpty ?? false)
                          Text(
                            resumo.conteudo!
                                .replaceAllMapped(
                                  RegExp(r'\[([^\]]+)\]\([^)]+\)'),
                                  (m) => m.group(1) ?? '',
                                )
                                .replaceAll('**', '')
                                .replaceAll('~~', '')
                                .replaceAll('*', '')
                                .replaceAll(RegExp(r'\s*\n+\s*'), ' ')
                                .trim(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: MensagensColors.muted,
                              height: 1.35,
                            ),
                          ),
                        if (resumo.anexos.isNotEmpty) ...[
                          if (resumo.conteudo?.trim().isNotEmpty ?? false)
                            const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.attach_file,
                                size: 14,
                                color: MensagensColors.muted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${resumo.anexos.length} ${resumo.anexos.length == 1 ? 'anexo' : 'anexos'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: MensagensColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
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

void _abrirModalMensagemEnviada(
  BuildContext context,
  MensagemEnviadaModel resumo,
) {
  final dataFormatada = resumo.dataEnvio != null
      ? DateFormat('dd/MM/yyyy HH:mm').format(resumo.dataEnvio!)
      : (resumo.dataAgendamento != null
          ? 'Agendada para ${DateFormat('dd/MM/yyyy HH:mm').format(resumo.dataAgendamento!)}'
          : '');
  final temTexto = resumo.conteudo?.trim().isNotEmpty ?? false;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: MensagensColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MensagensColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Aviso enviado',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: MensagensColors.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: MensagensColors.muted),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: MensagensColors.border),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _ModalTag(label: resumo.prioridade.label),
                      _ModalTag(label: resumo.modalidade.label),
                      if (resumo.exigeCiencia)
                        const _ModalTag(label: 'Exige ciência'),
                      if (dataFormatada.isNotEmpty)
                        _ModalTag(label: dataFormatada),
                    ],
                  ),
                  if (resumo.titulo != null &&
                      resumo.titulo!.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      resumo.titulo!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: MensagensColors.ink,
                      ),
                    ),
                  ],
                  if (temTexto) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: MensagensColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: MensagensColors.border),
                      ),
                      child: MarkdownBody(
                        data: resumo.conteudo!,
                        selectable: true,
                        onTapLink: (_, href, _) {
                          if (href != null && href.isNotEmpty) {
                            final uri = Uri.tryParse(href);
                            if (uri != null) {
                              launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          }
                        },
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: MensagensColors.ink,
                          ),
                          strong: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: MensagensColors.ink,
                          ),
                          a: const TextStyle(
                            color: MensagensColors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (resumo.anexos.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    for (final anexo in resumo.anexos)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                        decoration: BoxDecoration(
                          color: MensagensColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: MensagensColors.border),
                        ),
                        child: AnexoPreviewWidget(
                          mensagemId: resumo.id,
                          anexo: anexo,
                        ),
                      ),
                  ],
                  if (!temTexto && resumo.anexos.isEmpty)
                    const Text(
                      'Sem conteúdo textual ou anexos.',
                      style: TextStyle(color: MensagensColors.muted),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ModalTag extends StatelessWidget {
  const _ModalTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: MensagensColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: MensagensColors.muted,
        ),
      ),
    );
  }
}
