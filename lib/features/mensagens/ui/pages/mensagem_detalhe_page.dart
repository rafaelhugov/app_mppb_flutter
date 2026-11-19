import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/mensagem_aviso_model.dart';
import '../../providers/caixa_entrada_provider.dart';
import '../widgets/mensagem_bolha_card.dart';

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
        _erro = 'Não foi possível carregar este aviso ou você não é destinatário.';
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
          const SnackBar(content: Text('Falha ao registrar confirmação de ciência.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: const Text('Detalhe do Aviso'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 48,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 12),
                        Text(_erro!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _abrirERegistrarLeitura,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: MensagemBolhaCard(
                    mensagem: _mensagem!,
                    onConfirmarCiencia:
                        _mensagem!.pendenteCiencia ? _confirmarCiencia : null,
                  ),
                ),
    );
  }
}

