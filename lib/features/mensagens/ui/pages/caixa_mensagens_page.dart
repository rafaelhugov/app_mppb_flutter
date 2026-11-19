import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/main_layout.dart';
import '../../../../core/ui/widgets/hero_header_publico.dart';
import '../../providers/caixa_entrada_provider.dart';
import '../../providers/permissao_mensagens_provider.dart';
import '../widgets/mensagem_bolha_card.dart';
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
    final podeEnviarAsync = ref.watch(podeEnviarMensagensProvider);
    final podeEnviar = podeEnviarAsync.asData?.value ?? false;

    return Scaffold(
      backgroundColor: MensagensColors.background,
      body: Column(
        children: [
          HeroHeaderPublico(
            label: '',
            title: 'Mensagens e Avisos',
            subtitle: '',
            icon: Icons.campaign_rounded,
            rightWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (podeEnviar) ...[
                  Material(
                    color: MensagensColors.brandDark,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => context.push('/mensagens/painel'),
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.campaign_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Painel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                MensagensHeaderIconButton(
                  icon: Icons.refresh_rounded,
                  tooltip: 'Atualizar',
                  onPressed: () => ref
                      .read(caixaEntradaProvider.notifier)
                      .carregar(forceRefresh: true),
                ),
              ],
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

    final horizontalPadding = MainLayout.horizontalPadding(context);
    final bottomPadding = MainLayout.contentBottomPadding(context);

    return RefreshIndicator(
      color: MensagensColors.green,
      onRefresh: () =>
          ref.read(caixaEntradaProvider.notifier).carregar(forceRefresh: true),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          8,
          horizontalPadding,
          bottomPadding,
        ),
        itemCount: state.itens.length,
        itemBuilder: (context, index) {
          final item = state.itens[index];
          return MensagemBolhaCard(
            key: ValueKey('msg_${item.id}'),
            mensagem: item,
            onTap: () => context.push('/mensagens/${item.id}'),
            onConfirmarCiencia: item.pendenteCiencia
                ? () => ref
                    .read(caixaEntradaProvider.notifier)
                    .confirmarCiencia(item.id)
                : null,
            onArquivar: () => ref
                .read(caixaEntradaProvider.notifier)
                .arquivar(item.id, arquivada: !item.arquivada),
          );
        },
      ),
    );
  }
}
