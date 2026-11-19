import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/mensagens_repository.dart';
import '../../models/acompanhamento_mensagem_model.dart';
import '../../providers/permissao_mensagens_provider.dart';

class PainelRemetentePage extends ConsumerStatefulWidget {
  const PainelRemetentePage({super.key});

  @override
  ConsumerState<PainelRemetentePage> createState() =>
      _PainelRemetentePageState();
}

class _PainelRemetentePageState extends ConsumerState<PainelRemetentePage> {
  List<MensagemEnviadaModel> _enviadas = const [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    Future.microtask(_carregar);
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final lista = await ref
          .read(mensagensRepositoryProvider)
          .listarEnviadas();
      if (mounted) {
        setState(() {
          _enviadas = lista;
          _carregando = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _carregando = false;
          _erro = 'Não foi possível carregar os avisos enviados.';
        });
      }
    }
  }

  String _formatarData(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final permissaoAsync = ref.watch(podeEnviarMensagensProvider);

    return permissaoAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => _buildAcessoNegado(),
      data: (podeEnviar) {
        if (!podeEnviar) {
          return _buildAcessoNegado();
        }
        return _buildPainel(context);
      },
    );
  }

  Widget _buildAcessoNegado() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: const Text('Painel de Avisos'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 56, color: Colors.redAccent),
              SizedBox(height: 12),
              Text(
                'Acesso restrito ao PGJ e autoridades designadas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPainel(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: const Text('Painel de Envio de Avisos'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/mensagens/painel/grupos'),
            icon: const Icon(Icons.group_work, color: Colors.white),
            label: const Text(
              'Grupos',
              style: TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _carregar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFB91C1C),
        foregroundColor: Colors.white,
        onPressed: () async {
          await context.push('/mensagens/painel/nova');
          if (mounted) _carregar();
        },
        icon: const Icon(Icons.send),
        label: const Text('Novo Aviso'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(child: Text(_erro!))
              : _enviadas.isEmpty
                  ? const Center(
                      child: Text('Nenhum aviso institucional enviado ainda.'),
                    )
                  : RefreshIndicator(
                      onRefresh: _carregar,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          top: 12,
                          bottom: 88,
                        ),
                        itemCount: _enviadas.length,
                        itemBuilder: (context, index) {
                          final msg = _enviadas[index];
                          return _MensagemEnviadaCard(
                            mensagem: msg,
                            dataFormatada: _formatarData(
                              msg.dataEnvio ?? msg.dataAgendamento,
                            ),
                            onTapAcompanhamento: () => context.push(
                              '/mensagens/painel/${msg.id}/acompanhamento',
                            ),
                            onCancelarAgendada:
                                msg.statusPublicacao == 'AGENDADA'
                                    ? () async {
                                        await ref
                                            .read(mensagensRepositoryProvider)
                                            .cancelarAgendada(msg.id);
                                        if (mounted) _carregar();
                                      }
                                    : null,
                          );
                        },
                      ),
                    ),
    );
  }
}

class _MensagemEnviadaCard extends StatelessWidget {
  const _MensagemEnviadaCard({
    required this.mensagem,
    required this.dataFormatada,
    required this.onTapAcompanhamento,
    this.onCancelarAgendada,
  });

  final MensagemEnviadaModel mensagem;
  final String dataFormatada;
  final VoidCallback onTapAcompanhamento;
  final VoidCallback? onCancelarAgendada;

  @override
  Widget build(BuildContext context) {
    final titulo = (mensagem.titulo != null && mensagem.titulo!.isNotEmpty)
        ? mensagem.titulo!
        : (mensagem.anexos.isNotEmpty
            ? 'Aviso em mídia (${mensagem.anexos.first.categoria.apiValue})'
            : 'Aviso institucional');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: InkWell(
        onTap: onTapAcompanhamento,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${mensagem.modalidade.apiValue} • ${mensagem.statusPublicacao}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dataFormatada,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (mensagem.conteudo != null &&
                  mensagem.conteudo!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  mensagem.conteudo!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MetricaChip(
                    label: 'Total',
                    valor: mensagem.totalDestinatarios,
                    cor: const Color(0xFF334155),
                  ),
                  _MetricaChip(
                    label: 'Entregues',
                    valor: mensagem.totalEntregues,
                    cor: const Color(0xFF0284C7),
                  ),
                  _MetricaChip(
                    label: 'Lidos',
                    valor: mensagem.totalLidos,
                    cor: const Color(0xFF15803D),
                  ),
                  if (mensagem.exigeCiencia)
                    _MetricaChip(
                      label: 'Cientes',
                      valor: mensagem.totalCientes,
                      cor: const Color(0xFFD97706),
                    ),
                ],
              ),
              if (onCancelarAgendada != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onCancelarAgendada,
                    icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                    label: const Text(
                      'Cancelar agendamento',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricaChip extends StatelessWidget {
  const _MetricaChip({
    required this.label,
    required this.valor,
    required this.cor,
  });

  final String label;
  final int valor;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$valor',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}
