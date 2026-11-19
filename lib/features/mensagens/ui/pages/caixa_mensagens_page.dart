import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/caixa_entrada_provider.dart';
import '../../providers/permissao_mensagens_provider.dart';
import '../widgets/mensagem_bolha_card.dart';

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
      backgroundColor: const Color(0xFFEFF6EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mensagens e Avisos',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              state.totalNaoLidas > 0
                  ? '${state.totalNaoLidas} não lida(s) • Canal institucional'
                  : 'Canal institucional unilateral',
              style: const TextStyle(fontSize: 11.5, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          if (podeEnviar)
            TextButton.icon(
              onPressed: () => context.push('/mensagens/painel'),
              icon: const Icon(Icons.campaign, color: Colors.amberAccent),
              label: const Text(
                'Painel',
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () => ref
                .read(caixaEntradaProvider.notifier)
                .carregar(forceRefresh: true),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _FiltroChip(
                  label: 'Todas',
                  selecionado: state.filtro == 'TODAS',
                  onSelected: () => ref
                      .read(caixaEntradaProvider.notifier)
                      .carregar(filtro: 'TODAS', forceRefresh: true),
                ),
                const SizedBox(width: 8),
                _FiltroChip(
                  label: state.totalNaoLidas > 0
                      ? 'Não lidas (${state.totalNaoLidas})'
                      : 'Não lidas',
                  selecionado: state.filtro == 'NAO_LIDAS',
                  onSelected: () => ref
                      .read(caixaEntradaProvider.notifier)
                      .carregar(filtro: 'NAO_LIDAS', forceRefresh: true),
                ),
                const SizedBox(width: 8),
                _FiltroChip(
                  label: 'Arquivadas',
                  selecionado: state.filtro == 'ARQUIVADAS',
                  onSelected: () => ref
                      .read(caixaEntradaProvider.notifier)
                      .carregar(filtro: 'ARQUIVADAS', forceRefresh: true),
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
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.itens.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Color(0xFF64748B)),
              const SizedBox(height: 12),
              Text(state.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref
                    .read(caixaEntradaProvider.notifier)
                    .carregar(forceRefresh: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }
    if (state.itens.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mark_chat_read_outlined,
                size: 56,
                color: Color(0xFF94A3B8),
              ),
              SizedBox(height: 12),
              Text(
                'Nenhuma mensagem ou aviso encontrado neste filtro.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF475569), fontSize: 14.5),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(caixaEntradaProvider.notifier).carregar(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
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

class _FiltroChip extends StatelessWidget {
  const _FiltroChip({
    required this.label,
    required this.selecionado,
    required this.onSelected,
  });

  final String label;
  final bool selecionado;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selecionado,
      onSelected: (_) => onSelected(),
      selectedColor: const Color(0xFF1E293B),
      labelStyle: TextStyle(
        color: selecionado ? Colors.white : const Color(0xFF334155),
        fontWeight: selecionado ? FontWeight.bold : FontWeight.w500,
        fontSize: 12.5,
      ),
    );
  }
}

