import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/ui/main_layout.dart';
import '../../../../core/ui/widgets/hero_header_publico.dart';
import '../../data/mensagens_repository.dart';
import '../../models/acompanhamento_mensagem_model.dart';
import '../../providers/permissao_mensagens_provider.dart';
import '../widgets/mensagens_theme.dart';

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
        backgroundColor: MensagensColors.background,
        body: Center(
          child: CircularProgressIndicator(color: MensagensColors.green),
        ),
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
    return const Scaffold(
      backgroundColor: MensagensColors.background,
      body: Column(
        children: [
          HeroHeaderPublico(
            label: '',
            title: 'Painel de Avisos',
            subtitle: '',
            icon: Icons.campaign_rounded,
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: MensagensColors.red,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Acesso restrito ao PGJ e autoridades designadas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: MensagensColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPainel(BuildContext context) {
    final horizontalPadding = MainLayout.horizontalPadding(context);
    final bottomPadding = MainLayout.contentBottomPadding(context);

    return Scaffold(
      backgroundColor: MensagensColors.background,
      body: Column(
        children: [
          HeroHeaderPublico(
            label: '',
            title: 'Painel de Avisos',
            subtitle: '',
            icon: Icons.campaign_rounded,
            rightWidget: MensagensHeaderIconButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Atualizar',
              onPressed: _carregar,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              4,
              horizontalPadding,
              8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MensagensColors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      await context.push('/mensagens/painel/nova');
                      if (mounted) _carregar();
                    },
                    icon: const Icon(Icons.send_rounded, size: 17),
                    label: const Text(
                      'Novo Aviso',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MensagensColors.ink,
                    backgroundColor: MensagensColors.surface,
                    side: const BorderSide(color: MensagensColors.border),
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => context.push('/mensagens/painel/grupos'),
                  icon: const Icon(Icons.groups_rounded, size: 18),
                  label: const Text(
                    'Grupos',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
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
                        onRetry: _carregar,
                      )
                    : _enviadas.isEmpty
                        ? const MensagensEmptyState(
                            message:
                                'Nenhum aviso institucional enviado ainda.',
                            icon: Icons.campaign_outlined,
                          )
                        : RefreshIndicator(
                            color: MensagensColors.green,
                            onRefresh: _carregar,
                            child: ListView.builder(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                8,
                                horizontalPadding,
                                bottomPadding,
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
                                                  .read(
                                                    mensagensRepositoryProvider,
                                                  )
                                                  .cancelarAgendada(msg.id);
                                              if (mounted) _carregar();
                                            }
                                          : null,
                                );
                              },
                            ),
                          ),
          ),
        ],
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTapAcompanhamento,
          borderRadius: BorderRadius.circular(16),
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
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: MensagensColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: MensagensColors.border),
                      ),
                      child: Text(
                        '${mensagem.modalidade.apiValue} • ${mensagem.statusPublicacao}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: MensagensColors.ink,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      dataFormatada,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: MensagensColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: MensagensColors.ink,
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
                      color: MensagensColors.muted,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: MensagensColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: MensagensColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MetricaChip(
                        label: 'Total',
                        valor: mensagem.totalDestinatarios,
                        cor: MensagensColors.ink,
                      ),
                      _MetricaChip(
                        label: 'Entregues',
                        valor: mensagem.totalEntregues,
                        cor: MensagensColors.blue,
                      ),
                      _MetricaChip(
                        label: 'Lidos',
                        valor: mensagem.totalLidos,
                        cor: MensagensColors.green,
                      ),
                      if (mensagem.exigeCiencia)
                        _MetricaChip(
                          label: 'Cientes',
                          valor: mensagem.totalCientes,
                          cor: MensagensColors.orange,
                        ),
                    ],
                  ),
                ),
                if (onCancelarAgendada != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onCancelarAgendada,
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: MensagensColors.red,
                      ),
                      label: const Text(
                        'Cancelar agendamento',
                        style: TextStyle(color: MensagensColors.red),
                      ),
                    ),
                  ),
                ],
              ],
            ),
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
            fontWeight: FontWeight.w800,
            color: cor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: MensagensColors.muted,
          ),
        ),
      ],
    );
  }
}
