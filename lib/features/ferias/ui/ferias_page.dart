import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/ferias_provider.dart';
import '../models/solicitacao_ferias.dart';

class FeriasPage extends ConsumerWidget {
  const FeriasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feriasProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFDED4C5),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: _buildHeaderContent(),
          ),
          if (state.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.errorMessage != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildError(state.errorMessage!, ref),
            )
          else if (state.solicitacoes.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(context),
            )
          else
            _buildList(state.solicitacoes),
          
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)), // Space for FAB
        ],
      ),
      floatingActionButton: state.isLoading || state.errorMessage != null
          ? null
          : FloatingActionButton(
              onPressed: () => context.push('/ferias/nova'),
              backgroundColor: const Color(0xFF8F2A1D),
              foregroundColor: Colors.white,
              tooltip: 'Nova Solicitação',
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFF241D19),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFFFFF8EA)),
        onPressed: () => context.canPop() ? context.pop() : context.go('/restrito'),
        tooltip: 'Voltar',
      ),
      title: const Text(
        'Férias e Licenças',
        style: TextStyle(color: Color(0xFFFFF8EA), fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF241D19), Color(0xFF3A241D), Color(0xFF8F2A1D)],
          stops: [0.0, 0.46, 1.0],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE5B84C), Color(0xFFA96A1D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5B84C).withOpacity(0.44)),
            ),
            child: const Icon(Icons.event_available, color: Color(0xFF211713), size: 30),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MINISTÉRIO PÚBLICO DA PARAÍBA',
                  style: TextStyle(
                    color: Color(0xFFE3C474),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Férias e Licenças',
                  style: TextStyle(
                    color: Color(0xFFFFF8EA),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Suas solicitações (FLA)',
                  style: TextStyle(
                    color: Color(0xFFD8C5AA),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildError(String error, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.withOpacity(0.2)),
            ),
            child: const Icon(Icons.wifi_off, color: Colors.red, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('Falha na conexão', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF86715B))),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.read(feriasProvider.notifier).fetchSolicitacoes(),
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC43922),
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 48), // Touch target
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEAD4A3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD6A92F).withOpacity(0.38)),
            ),
            child: const Icon(Icons.flight_takeoff, color: Color(0xFF8F2A1D), size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma solicitação',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2F2923)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Você ainda não possui solicitações de férias ou licenças cadastradas.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF86715B), fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/ferias/nova'),
            icon: const Icon(Icons.add),
            label: const Text('Solicitar agora'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC43922),
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 48), // Touch target
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<SolicitacaoFerias> solicitacoes) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildStats(solicitacoes),
              );
            }
            final sol = solicitacoes[index - 1];
            return _FeriasCard(solicitacao: sol);
          },
          childCount: solicitacoes.length + 1,
        ),
      ),
    );
  }

  Widget _buildStats(List<SolicitacaoFerias> solicitacoes) {
    final pendentes = solicitacoes.where((s) => s.status == 'P').length;
    final aprovadas = solicitacoes.where((s) => ['H', 'D', 'L'].contains(s.status)).length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2722),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6A92F).withOpacity(0.24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: solicitacoes.length.toString(), label: 'TOTAL'),
          Container(width: 1, height: 36, color: const Color(0xFFD6A92F).withOpacity(0.28)),
          _StatItem(value: pendentes.toString(), label: 'PENDENTES'),
          Container(width: 1, height: 36, color: const Color(0xFFD6A92F).withOpacity(0.28)),
          _StatItem(value: aprovadas.toString(), label: 'APROVADAS'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFFE5B84C),
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFFCDBDA9),
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

class _FeriasCard extends StatelessWidget {
  final SolicitacaoFerias solicitacao;

  const _FeriasCard({required this.solicitacao});

  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'GO': return Icons.beach_access;
      case 'GC': return Icons.groups;
      case 'AN': return Icons.fast_forward;
      case 'IF': return Icons.payments;
      case 'CF': return Icons.currency_exchange;
      default: return Icons.event_note;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'P': return const Color(0xFFD64222); // Pending
      case 'L': return const Color(0xFF6F7D3F); // Released
      case 'H':
      case 'D': return const Color(0xFF2F6B3F); // Approved
      case 'I':
      case 'N': return const Color(0xFF7F2018); // Denied
      case 'C': return const Color(0xFF756C61); // Neutral
      default: return const Color(0xFF756C61);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'P': return Icons.schedule;
      case 'L': return Icons.thumb_up;
      case 'H': return Icons.verified;
      case 'D': return Icons.check_circle;
      case 'I': return Icons.cancel;
      case 'N': return Icons.do_not_disturb;
      case 'C': return Icons.block;
      default: return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EFE3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF9C7A54).withOpacity(0.35)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29432B1D),
            offset: Offset(0, 14),
            blurRadius: 30,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Color(0xFF8F2A1D), width: 4),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAD4A3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_getTipoIcon(solicitacao.tipo), color: const Color(0xFF8F2A1D), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      solicitacao.tipoExtenso,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2F2923),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getStatusColor(solicitacao.status),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getStatusIcon(solicitacao.status), color: Colors.white, size: 10),
                        const SizedBox(width: 4),
                        Text(
                          solicitacao.statusExtenso,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 14),
              // Dates
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFE3D1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD8C6AA)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.event, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          const Text('INÍCIO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF86715B))),
                          const SizedBox(width: 4),
                          Text(dateFormat.format(solicitacao.dataInicio), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF342C25))),
                        ],
                      ),
                    ),
                    const Text('→', style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 12)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.event, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          const Text('FIM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF86715B))),
                          const SizedBox(width: 4),
                          Text(dateFormat.format(solicitacao.dataFim), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF342C25))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (solicitacao.justificativa != null && solicitacao.justificativa!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notes, size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        solicitacao.justificativa!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF806F5E),
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
