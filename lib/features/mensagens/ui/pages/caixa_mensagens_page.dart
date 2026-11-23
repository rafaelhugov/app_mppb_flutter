import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/main_layout.dart';
import '../../../../core/ui/widgets/hero_header_publico.dart';
import '../../providers/caixa_entrada_provider.dart';
import '../widgets/mensagem_conversa_tile.dart';
import '../widgets/mensagens_theme.dart';

class CaixaMensagensPage extends ConsumerStatefulWidget {
  const CaixaMensagensPage({super.key});

  @override
  ConsumerState<CaixaMensagensPage> createState() => _CaixaMensagensPageState();
}

class _CaixaMensagensPageState extends ConsumerState<CaixaMensagensPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(caixaEntradaProvider.notifier).carregar(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(caixaEntradaProvider);

    return Scaffold(
      backgroundColor: MensagensColors.background,
      body: Column(
        children: [
          HeroHeaderPublico(
            label: '',
            title: 'Mensagens e Avisos',
            subtitle: '',
            icon: Icons.campaign_rounded,
            rightWidget: MensagensHeaderIconButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Atualizar',
              onPressed: () => ref
                  .read(caixaEntradaProvider.notifier)
                  .carregar(forceRefresh: true),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: MensagensSegmentedPillBar<String>(
              selectedValue: state.filtro,
              onSelected: (novoFiltro) => ref
                  .read(caixaEntradaProvider.notifier)
                  .carregar(filtro: novoFiltro, forceRefresh: true),
              items: [
                const MensagensSegmentItem(
                  value: 'TODAS',
                  icon: Icons.inbox_rounded,
                  label: 'Todas',
                ),
                MensagensSegmentItem(
                  value: 'NAO_LIDAS',
                  icon: Icons.mark_email_unread_outlined,
                  label: state.totalNaoLidas > 0
                      ? 'Não lidas (${state.totalNaoLidas})'
                      : 'Não lidas',
                ),
                const MensagensSegmentItem(
                  value: 'ARQUIVADAS',
                  icon: Icons.archive_outlined,
                  label: 'Arquivadas',
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildLista(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildLista(BuildContext context, CaixaEntradaState state) {
    if (state.isLoading && state.itens.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: MensagensColors.green),
      );
    }
    if (state.errorMessage != null && state.itens.isEmpty) {
      return MensagensErrorState(
        message: state.errorMessage!,
        onRetry: () => ref
            .read(caixaEntradaProvider.notifier)
            .carregar(forceRefresh: true),
      );
    }
    if (state.itens.isEmpty) {
      return const MensagensEmptyState(
        message: 'Nenhuma mensagem ou aviso encontrado neste filtro.',
      );
    }

    final bottomPadding = MainLayout.contentBottomPadding(context);

    return RefreshIndicator(
      color: MensagensColors.green,
      onRefresh: () =>
          ref.read(caixaEntradaProvider.notifier).carregar(forceRefresh: true),
      child: Container(
        color: MensagensColors.surface,
        child: ListView.separated(
          padding: EdgeInsets.only(bottom: bottomPadding),
          itemCount: state.itens.length,
          separatorBuilder: (_, _) => const Divider(
            height: 1,
            thickness: 0.6,
            indent: 78,
            endIndent: 16,
            color: MensagensColors.border,
          ),
          itemBuilder: (context, index) {
            final item = state.itens[index];
            return Dismissible(
              key: ValueKey('msg_${item.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                color: MensagensColors.green,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.arquivada
                          ? Icons.unarchive_outlined
                          : Icons.archive_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.arquivada ? 'Desarquivar' : 'Arquivar',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              onDismissed: (_) => ref
                  .read(caixaEntradaProvider.notifier)
                  .arquivar(item.id, arquivada: !item.arquivada),
              child: MensagemConversaTile(
                mensagem: item,
                onTap: () => context.push('/mensagens/${item.id}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
