import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/ui/app_feedback.dart';
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
  bool _mostrarArquivadas = false;
  String? _erro;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(_carregar);
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted && !_carregando) {
        _carregar(silencioso: true);
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _carregar({bool silencioso = false}) async {
    if (!silencioso) {
      setState(() {
        _carregando = true;
        _erro = null;
      });
    }
    try {
      final lista = await ref
          .read(mensagensRepositoryProvider)
          .listarEnviadas(arquivada: _mostrarArquivadas);
      if (mounted) {
        setState(() {
          _enviadas = lista;
          _carregando = false;
          _erro = null;
        });
      }
    } catch (_) {
      if (mounted && !silencioso) {
        setState(() {
          _carregando = false;
          _erro = 'Não foi possível carregar os avisos enviados.';
        });
      }
    }
  }

  Future<void> _arquivarOuRestaurar(MensagemEnviadaModel msg) async {
    final arquivar = !_mostrarArquivadas;
    try {
      await ref
          .read(mensagensRepositoryProvider)
          .arquivarRemetente(msg.id, arquivada: arquivar);
      if (!mounted) return;
      AppFeedback.showSuccess(
        context,
        arquivar
            ? 'Aviso arquivado no painel.'
            : 'Aviso restaurado para os ativos.',
      );
      _carregar();
    } catch (_) {
      if (mounted) {
        AppFeedback.showError(
          context,
          'Não foi possível atualizar o arquivamento do aviso.',
        );
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
            rightWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MensagensHeaderIconButton(
                  icon: Icons.groups_rounded,
                  tooltip: 'Grupos personalizados',
                  onPressed: () => context.push('/mensagens/painel/grupos'),
                ),
                const SizedBox(width: 6),
                MensagensHeaderIconButton(
                  icon: Icons.refresh_rounded,
                  tooltip: 'Atualizar',
                  onPressed: _carregar,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              4,
              horizontalPadding,
              12,
            ),
            child: SizedBox(
              width: double.infinity,
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
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              8,
            ),
            child: MensagensSegmentedPillBar<bool>(
              selectedValue: _mostrarArquivadas,
              onSelected: (arq) {
                setState(() => _mostrarArquivadas = arq);
                _carregar();
              },
              items: const [
                MensagensSegmentItem(
                  value: false,
                  icon: Icons.send_outlined,
                  label: 'Ativos',
                ),
                MensagensSegmentItem(
                  value: true,
                  icon: Icons.archive_outlined,
                  label: 'Arquivados',
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
                        ? MensagensEmptyState(
                            message: _mostrarArquivadas
                                ? 'Nenhum aviso arquivado no painel.'
                                : 'Nenhum aviso institucional enviado ainda.',
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
                                  arquivada: _mostrarArquivadas,
                                  dataFormatada: _formatarData(
                                    msg.dataEnvio ?? msg.dataAgendamento,
                                  ),
                                  onTapAcompanhamento: () async {
                                    await context.push(
                                      '/mensagens/painel/${msg.id}/acompanhamento',
                                    );
                                    if (mounted) _carregar(silencioso: true);
                                  },
                                  onArquivar: () => _arquivarOuRestaurar(msg),
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
    required this.arquivada,
    required this.dataFormatada,
    required this.onTapAcompanhamento,
    required this.onArquivar,
    this.onCancelarAgendada,
  });

  final MensagemEnviadaModel mensagem;
  final bool arquivada;
  final String dataFormatada;
  final VoidCallback onTapAcompanhamento;
  final VoidCallback onArquivar;
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
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: MensagensColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dataFormatada,
                      style: const TextStyle(
                        fontSize: 11,
                        color: MensagensColors.muted,
                      ),
                    ),
                    IconButton(
                      tooltip: arquivada ? 'Restaurar' : 'Arquivar',
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.only(left: 4),
                      constraints: const BoxConstraints(),
                      onPressed: onArquivar,
                      icon: Icon(
                        arquivada
                            ? Icons.unarchive_outlined
                            : Icons.archive_outlined,
                        size: 18,
                        color: MensagensColors.muted,
                      ),
                    ),
                  ],
                ),
                if (mensagem.conteudo != null &&
                    mensagem.conteudo!.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    mensagem.conteudo!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: MensagensColors.muted,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: MensagensColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${mensagem.modalidade.apiValue} • ${mensagem.statusPublicacao}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: MensagensColors.muted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${mensagem.totalDestinatarios} dest. • '
                        '${mensagem.totalEntregues} entr. • '
                        '${mensagem.totalLidos} lido(s)'
                        '${mensagem.exigeCiencia ? " • ${mensagem.totalCientes} ciente(s)" : ""}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: MensagensColors.ink,
                        ),
                      ),
                    ),
                    if (onCancelarAgendada != null)
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: MensagensColors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          minimumSize: const Size(0, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: onCancelarAgendada,
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
