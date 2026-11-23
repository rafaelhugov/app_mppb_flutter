import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/ui/app_feedback.dart';
import '../../../../core/ui/main_layout.dart';
import '../../models/mensagem_anexo_model.dart';
import '../../models/mensagem_aviso_model.dart';
import '../../providers/caixa_entrada_provider.dart';
import '../widgets/anexo_preview_widget.dart';
import '../widgets/mensagem_bolha_card.dart';
import '../widgets/mensagens_theme.dart';
import '../widgets/remetente_avatar.dart';

class MensagemDetalhePage extends ConsumerStatefulWidget {
  const MensagemDetalhePage({super.key, required this.mensagemId});

  final int mensagemId;

  @override
  ConsumerState<MensagemDetalhePage> createState() =>
      _MensagemDetalhePageState();
}

class _MensagemDetalhePageState extends ConsumerState<MensagemDetalhePage> {
  MensagemAvisoModel? _mensagem;
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    Future.microtask(_abrirERegistrarLeitura);
  }

  Future<void> _abrirERegistrarLeitura() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    final msg = await ref
        .read(caixaEntradaProvider.notifier)
        .abrirMensagem(widget.mensagemId);
    if (!mounted) return;
    if (msg == null) {
      setState(() {
        _carregando = false;
        _erro =
            'Não foi possível carregar este aviso ou você não é destinatário.';
      });
    } else {
      setState(() {
        _mensagem = msg;
        _carregando = false;
      });
    }
  }

  Future<void> _confirmarCiencia() async {
    try {
      final atualizada = await ref
          .read(caixaEntradaProvider.notifier)
          .confirmarCiencia(widget.mensagemId);
      if (mounted && atualizada != null) {
        setState(() => _mensagem = atualizada);
        AppFeedback.showSuccess(
          context,
          'Ciência confirmada com sucesso.',
          title: 'Ciência registrada',
        );
      }
    } catch (_) {
      if (mounted) {
        AppFeedback.showError(
          context,
          'Falha ao registrar confirmação de ciência.',
        );
      }
    }
  }

  Future<void> _alternarArquivo() async {
    final msg = _mensagem;
    if (msg == null) return;
    final novoEstado = !msg.arquivada;
    await ref
        .read(caixaEntradaProvider.notifier)
        .arquivar(msg.id, arquivada: novoEstado);
    if (!mounted) return;
    AppFeedback.showSuccess(
      context,
      novoEstado ? 'Aviso arquivado.' : 'Aviso movido para a caixa.',
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MainLayout.horizontalPadding(context);
    final bottomPadding = MainLayout.contentBottomPadding(context);
    final remetente = _mensagem?.remetenteNome?.trim().isNotEmpty == true
        ? formatarNomeProprio(_mensagem!.remetenteNome)
        : 'Comunicado Institucional';

    return Scaffold(
      backgroundColor: const Color(0xFFEFEAE2),
      body: Column(
        children: [
          _WhatsAppChatHeader(
            remetente: remetente,
            mensagem: _mensagem,
            onBack: () => Navigator.of(context).maybePop(),
            onToggleArchive: _mensagem != null ? _alternarArquivo : null,
          ),
          Expanded(
            child: _carregando
                ? const Center(
                    child: CircularProgressIndicator(
                      color: MensagensColors.green,
                    ),
                  )
                : _erro != null
                    ? MensagensErrorState(
                        message: _erro!,
                        icon: Icons.lock_outline,
                        onRetry: _abrirERegistrarLeitura,
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          14,
                          horizontalPadding,
                          bottomPadding,
                        ),
                        child: Column(
                          children: [
                            if (_mensagem!.dataEnvio != null) ...[
                              _DataConversaPill(data: _mensagem!.dataEnvio!),
                              const SizedBox(height: 12),
                            ],
                            ..._buildBolhasConversa(_mensagem!),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBolhasConversa(MensagemAvisoModel msg) {
    final temTexto = (msg.titulo?.trim().isNotEmpty ?? false) ||
        (msg.conteudo?.trim().isNotEmpty ?? false);
    final separarAnexos = temTexto && msg.anexos.isNotEmpty;

    if (!separarAnexos) {
      return [
        MensagemBolhaCard(
          mensagem: msg,
          onConfirmarCiencia: msg.pendenteCiencia ? _confirmarCiencia : null,
        ),
      ];
    }

    return [
      MensagemBolhaCard(
        mensagem: msg,
        incluirAnexos: false,
        incluirCiencia: false,
      ),
      for (var i = 0; i < msg.anexos.length; i++)
        _AnexoBolhaCard(
          mensagem: msg,
          anexo: msg.anexos[i],
          incluirCiencia: i == msg.anexos.length - 1,
          onConfirmarCiencia: msg.pendenteCiencia ? _confirmarCiencia : null,
        ),
    ];
  }
}

class _WhatsAppChatHeader extends StatelessWidget {
  const _WhatsAppChatHeader({
    required this.remetente,
    required this.mensagem,
    required this.onBack,
    this.onToggleArchive,
  });

  final String remetente;
  final MensagemAvisoModel? mensagem;
  final VoidCallback onBack;
  final VoidCallback? onToggleArchive;

  @override
  Widget build(BuildContext context) {
    final subtitulo = mensagem == null
        ? 'Carregando comunicado...'
        : 'Comunicado Oficial • ${mensagem!.prioridade.label}';

    return Container(
      decoration: const BoxDecoration(
        color: MensagensColors.surface,
        border: Border(
          bottom: BorderSide(color: MensagensColors.border),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: Row(
            children: [
              Material(
                color: MensagensColors.surfaceMuted,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onBack,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: MensagensColors.ink,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              RemetenteAvatar(
                nome: remetente,
                matricula: mensagem?.remetenteMatricula,
                prioridade: mensagem?.prioridade ?? PrioridadeMensagem.normal,
                size: 40,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      remetente,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: MensagensColors.ink,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: MensagensColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (onToggleArchive != null)
                IconButton(
                  icon: Icon(
                    mensagem?.arquivada == true
                        ? Icons.unarchive_outlined
                        : Icons.archive_outlined,
                    color: MensagensColors.ink,
                  ),
                  tooltip: mensagem?.arquivada == true
                      ? 'Desarquivar'
                      : 'Arquivar',
                  onPressed: onToggleArchive,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DataConversaPill extends StatelessWidget {
  const _DataConversaPill({required this.data});

  final DateTime data;

  static const _meses = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  @override
  Widget build(BuildContext context) {
    final texto = '${data.day} de ${_meses[data.month - 1]} de ${data.year}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: MensagensColors.muted,
        ),
      ),
    );
  }
}

class _AnexoBolhaCard extends StatelessWidget {
  const _AnexoBolhaCard({
    required this.mensagem,
    required this.anexo,
    required this.incluirCiencia,
    this.onConfirmarCiencia,
  });

  final MensagemAvisoModel mensagem;
  final MensagemAnexoModel anexo;
  final bool incluirCiencia;
  final VoidCallback? onConfirmarCiencia;

  String _formatarData(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      decoration: BoxDecoration(
        color: MensagensColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MensagensColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D101828),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnexoPreviewWidget(mensagemId: mensagem.id, anexo: anexo),
          if (incluirCiencia && mensagem.exigeCiencia) ...[
            const SizedBox(height: 12),
            if (mensagem.dataCiencia == null)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MensagensColors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onConfirmarCiencia,
                  icon: const Icon(Icons.verified_outlined, size: 18),
                  label: const Text(
                    'Confirmar Ciência',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: MensagensColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified,
                      size: 16,
                      color: MensagensColors.green,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Ciência confirmada em ${_formatarData(mensagem.dataCiencia)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: MensagensColors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _formatarData(mensagem.dataEnvio),
                style: const TextStyle(
                  fontSize: 11,
                  color: MensagensColors.muted,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.done_all,
                size: 16,
                color: mensagem.status == StatusDestinatario.lido
                    ? MensagensColors.green
                    : MensagensColors.muted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
