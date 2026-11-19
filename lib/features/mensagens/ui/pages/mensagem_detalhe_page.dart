import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/main_layout.dart';
import '../../models/mensagem_aviso_model.dart';
import '../../providers/caixa_entrada_provider.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ciência confirmada com sucesso.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falha ao registrar confirmação de ciência.'),
          ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          novoEstado ? 'Aviso arquivado.' : 'Aviso movido para a caixa.',
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MainLayout.horizontalPadding(context);
    final bottomPadding = MainLayout.contentBottomPadding(context);
    final remetente = _mensagem?.remetenteNome?.trim().isNotEmpty == true
        ? _mensagem!.remetenteNome!.trim()
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
                            MensagemBolhaCard(
                              mensagem: _mensagem!,
                              onConfirmarCiencia: _mensagem!.pendenteCiencia
                                  ? _confirmarCiencia
                                  : null,
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
        : 'Comunicado Oficial • ${mensagem!.prioridade.apiValue}';

    return Container(
      color: MensagensColors.brandDark,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 8, 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                tooltip: 'Voltar',
                onPressed: onBack,
              ),
              RemetenteAvatar(
                nome: remetente,
                matricula: mensagem?.remetenteMatricula,
                prioridade: mensagem?.prioridade ?? PrioridadeMensagem.normal,
                size: 38,
                darkHeader: true,
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
                        color: Colors.white,
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
                        color: Color(0xFFCBD5E1),
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
                    color: Colors.white,
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
