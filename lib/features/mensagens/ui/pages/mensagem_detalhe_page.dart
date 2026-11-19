import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/main_layout.dart';
import '../../../../core/ui/widgets/hero_header_publico.dart';
import '../../models/mensagem_aviso_model.dart';
import '../../providers/caixa_entrada_provider.dart';
import '../widgets/mensagem_bolha_card.dart';
import '../widgets/mensagens_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MainLayout.horizontalPadding(context);
    final bottomPadding = MainLayout.contentBottomPadding(context);

    return Scaffold(
      backgroundColor: MensagensColors.background,
      body: Column(
        children: [
          const HeroHeaderPublico(
            label: '',
            title: 'Detalhe do Aviso',
            subtitle: '',
            icon: Icons.campaign_rounded,
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
                          12,
                          horizontalPadding,
                          bottomPadding,
                        ),
                        child: MensagemBolhaCard(
                          mensagem: _mensagem!,
                          onConfirmarCiencia: _mensagem!.pendenteCiencia
                              ? _confirmarCiencia
                              : null,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
