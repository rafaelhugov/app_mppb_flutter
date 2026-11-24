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
import '../../models/mensagem_aviso_model.dart';
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
              10,
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
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: MensagensColors.surface,
                    foregroundColor: MensagensColors.ink,
                    minimumSize: const Size(0, 34),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    side: const BorderSide(color: MensagensColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => context.push('/mensagens/painel/grupos'),
                  icon: const Icon(Icons.groups_rounded, size: 15),
                  label: const Text(
                    'Grupos',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MensagensColors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 34),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    await context.push('/mensagens/painel/nova');
                    if (mounted) _carregar();
                  },
                  icon: const Icon(Icons.send_rounded, size: 14),
                  label: const Text(
                    'Novo Aviso',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
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
    final titulo = mensagem.titulo?.trim();
    final temTitulo = titulo != null && titulo.isNotEmpty;

    final (corPrioridade, rotuloPrioridade) = switch (mensagem.prioridade) {
      PrioridadeMensagem.urgente => (MensagensColors.red, 'Urgente'),
      PrioridadeMensagem.importante => (MensagensColors.orange, 'Importante'),
      PrioridadeMensagem.normal => (MensagensColors.green, 'Normal'),
    };
    final (corStatus, rotuloStatus) = switch (mensagem.statusPublicacao) {
      'AGENDADA' => (MensagensColors.blue, 'Agendada'),
      'CANCELADA' => (MensagensColors.red, 'Cancelada'),
      _ => (MensagensColors.green, 'Enviada'),
    };
    final previewLimpa = (mensagem.conteudo ?? '')
        .replaceAllMapped(
          RegExp(r'\[([^\]]+)\]\([^)]+\)'),
          (m) => m.group(1) ?? '',
        )
        .replaceAll('**', '')
        .replaceAll('~~', '')
        .replaceAll('*', '')
        .replaceAll(RegExp(r'\s*\n+\s*'), ' ')
        .trim();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: MensagensColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MensagensColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A101828),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTapAcompanhamento,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 4, color: corPrioridade),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _TagPill(
                                texto: rotuloPrioridade,
                                cor: corPrioridade,
                              ),
                              const SizedBox(width: 6),
                              _TagPill(
                                texto: rotuloStatus,
                                cor: corStatus,
                              ),
                              const Spacer(),
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
                          if (temTitulo) ...[
                            const SizedBox(height: 8),
                            Text(
                              titulo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: MensagensColors.ink,
                              ),
                            ),
                          ],
                          if (previewLimpa.isNotEmpty) ...[
                            SizedBox(height: temTitulo ? 3 : 8),
                            Text(
                              previewLimpa,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: MensagensColors.muted,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _MiniMetricaPill(
                                icon: Icons.people_outline_rounded,
                                valor: mensagem.totalDestinatarios,
                                rotulo: 'dest.',
                                cor: MensagensColors.ink,
                              ),
                              _MiniMetricaPill(
                                icon: Icons.done_all_rounded,
                                valor: mensagem.totalEntregues,
                                rotulo: 'entr.',
                                cor: MensagensColors.blue,
                              ),
                              _MiniMetricaPill(
                                icon: Icons.visibility_rounded,
                                valor: mensagem.totalLidos,
                                rotulo: 'lidos',
                                cor: MensagensColors.green,
                              ),
                              if (mensagem.exigeCiencia)
                                _MiniMetricaPill(
                                  icon: Icons.verified_rounded,
                                  valor: mensagem.totalCientes,
                                  rotulo: 'cientes',
                                  cor: MensagensColors.orange,
                                ),
                              if (onCancelarAgendada != null)
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: MensagensColors.red,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    minimumSize: const Size(0, 26),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: onCancelarAgendada,
                                  child: const Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      fontSize: 11.5,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.texto, required this.cor});

  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: cor,
        ),
      ),
    );
  }
}

class _MiniMetricaPill extends StatelessWidget {
  const _MiniMetricaPill({
    required this.icon,
    required this.valor,
    required this.rotulo,
    required this.cor,
  });

  final IconData icon;
  final int valor;
  final String rotulo;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.5, color: cor),
          const SizedBox(width: 4),
          Text(
            '$valor $rotulo',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}
