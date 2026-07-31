import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../concessao_folga/ui/widgets/concessao_folga_theme.dart';
import '../models/designacao_ativa.dart';
import '../providers/designacoes_provider.dart';

class DesignacoesPage extends ConsumerWidget {
  const DesignacoesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(designacoesProvider);
    final notifier = ref.read(designacoesProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFDED4C5),
      body: Column(
        children: [
          _Header(tipoUsuario: state.tipoUsuario),
          Expanded(
            child: _DesignacoesList(
              designacoes: state.designacoes,
              isLoading: state.isLoading,
              errorMessage: state.errorMessage,
              onRetry: () => notifier.carregar(forceRefresh: true),
              onRefresh: () => notifier.carregar(forceRefresh: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String tipoUsuario;

  const _Header({required this.tipoUsuario});

  @override
  Widget build(BuildContext context) {
    final perfil = switch (tipoUsuario) {
      'MEMBRO' => 'Membro',
      'SERVIDOR' => 'Servidor',
      _ => 'Membro ou Servidor',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 44),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x3DD6A92F), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(255, 221, 132, 0.14),
            offset: Offset(0, -1),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF241D19), Color(0xFF3A241D), Color(0xFF8F2A1D)],
          stops: [0.0, 0.46, 1.0],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE5B84C), Color(0xFFA96A1D)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color.fromRGBO(255, 222, 142, 0.44),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(36, 18, 12, 0.30),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(
              Icons.assignment_ind,
              color: Color(0xFF211713),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MINISTÉRIO PÚBLICO DA PARAÍBA',
                  style: TextStyle(
                    color: Color(0xFFE3C474),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Designações Ativas',
                  style: TextStyle(
                    color: Color(0xFFFFF8EA),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        color: Color.fromRGBO(0, 0, 0, 0.22),
                        blurRadius: 12,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  perfil,
                  style: const TextStyle(
                    color: Color(0xFFD8C5AA),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesignacoesList extends StatelessWidget {
  final List<DesignacaoAtiva> designacoes;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;

  const _DesignacoesList({
    required this.designacoes,
    required this.isLoading,
    this.errorMessage,
    required this.onRetry,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && designacoes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null && designacoes.isEmpty) {
      return _ErrorState(message: errorMessage!, onRetry: onRetry);
    }

    final agrupadas = _agrupar(designacoes);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        children: [
          if (errorMessage != null)
            _InlineError(message: errorMessage!, onRetry: onRetry),
          if (designacoes.isEmpty)
            const _EmptyState()
          else
            ...agrupadas.entries.expand(
              (entry) => [
                _SectionTitle(title: entry.key),
                ...entry.value.map((item) => DesignacaoCard(designacao: item)),
                const SizedBox(height: 8),
              ],
            ),
        ],
      ),
    );
  }

  Map<String, List<DesignacaoAtiva>> _agrupar(List<DesignacaoAtiva> itens) {
    final result = <String, List<DesignacaoAtiva>>{};
    for (final item in itens) {
      result.putIfAbsent(item.tipoDescricao, () => []).add(item);
    }
    return result;
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, top: 8, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF2F2923),
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class DesignacaoCard extends StatelessWidget {
  final DesignacaoAtiva designacao;

  const DesignacaoCard({super.key, required this.designacao});

  @override
  Widget build(BuildContext context) {
    final category = _DesignacaoCategoryStyle.from(designacao.tipoDescricao);
    final details = _metadataItems(category);

    return Semantics(
      label:
          '${designacao.tipoDescricao}. ${designacao.titulo}. '
          '${designacao.periodo.isEmpty ? '' : designacao.periodo}.',
      button: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _DesignacaoSolidContainer(
          category: category,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DesignacaoCardTopBar(
                category: category,
                label: designacao.tipoDescricao,
              ),
              const SizedBox(height: 12),
              _DesignacaoIdentity(
                category: category,
                titulo: designacao.titulo,
                subtitulo: designacao.subtitulo,
              ),
              if (details.isNotEmpty) ...[
                const SizedBox(height: 12),
                _DesignacaoMetadataGrid(items: details),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<_DesignacaoMetadataItemData> _metadataItems(
    _DesignacaoCategoryStyle category,
  ) {
    return [
      if (designacao.periodo.isNotEmpty)
        _DesignacaoMetadataItemData(
          icon: Icons.event_rounded,
          label: 'Período',
          value: designacao.periodo,
          color: category.base,
          background: category.metadataBackground,
          border: category.metadataBorder,
          labelColor: category.metadataLabelColor,
          valueColor: category.metadataValueColor,
        ),
      if (_showOrgao)
        _DesignacaoMetadataItemData(
          icon: Icons.location_city_rounded,
          label: 'Unidade',
          value: designacao.orgao!.trim(),
          color: category.base,
          background: category.metadataBackground,
          border: category.metadataBorder,
          labelColor: category.metadataLabelColor,
          valueColor: category.metadataValueColor,
        ),
      if (designacao.ato != null && designacao.ato!.trim().isNotEmpty)
        _DesignacaoMetadataItemData(
          icon: Icons.description_rounded,
          label: 'Ato',
          value: 'Ato ${designacao.ato!.trim()}',
          color: category.base,
          background: category.metadataBackground,
          border: category.metadataBorder,
          labelColor: category.metadataLabelColor,
          valueColor: category.metadataValueColor,
        ),
    ];
  }

  bool get _showOrgao {
    final orgao = designacao.orgao?.trim();
    if (orgao == null || orgao.isEmpty) {
      return false;
    }
    return !_sameText(orgao, designacao.titulo) &&
        !_sameText(orgao, designacao.subtitulo);
  }

  static bool _sameText(String value, String? other) {
    return other != null &&
        value.trim().toLowerCase() == other.trim().toLowerCase();
  }
}

class _DesignacaoSolidContainer extends StatelessWidget {
  final _DesignacaoCategoryStyle category;
  final Widget child;

  const _DesignacaoSolidContainer({
    required this.category,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: category.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: category.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12432B1D),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DesignacaoCardTopBar extends StatelessWidget {
  final _DesignacaoCategoryStyle category;
  final String label;

  const _DesignacaoCardTopBar({required this.category, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: category.chipBackground,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: category.border),
            ),
            child: Text(
              label,
              softWrap: true,
              style: TextStyle(
                color: category.textOnChip,
                fontSize: 11,
                height: 1.1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: category.badgeBackground,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: category.badgeBorder),
          ),
          child: Text(
            'Ativa',
            style: TextStyle(
              color: category.badgeText,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _DesignacaoIdentity extends StatelessWidget {
  final _DesignacaoCategoryStyle category;
  final String titulo;
  final String? subtitulo;

  const _DesignacaoIdentity({
    required this.category,
    required this.titulo,
    this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitulo != null && subtitulo!.trim().isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: category.iconBackground,
            shape: BoxShape.circle,
            border: Border.all(color: category.border),
          ),
          child: Icon(category.icon, color: category.iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                softWrap: true,
                style: TextStyle(
                  color: category.titleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              if (hasSubtitle) ...[
                const SizedBox(height: 4),
                Text(
                  subtitulo!.trim(),
                  softWrap: true,
                  style: TextStyle(
                    color: category.subtitleColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DesignacaoMetadataGrid extends StatelessWidget {
  final List<_DesignacaoMetadataItemData> items;

  const _DesignacaoMetadataGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 360 && items.length > 1;
        final itemWidth = twoColumns
            ? (constraints.maxWidth - 8) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: _DesignacaoMetadataItem(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _DesignacaoMetadataItem extends StatelessWidget {
  final _DesignacaoMetadataItemData item;

  const _DesignacaoMetadataItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: item.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: item.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, color: item.color, size: 16),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    color: item.labelColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.value,
                  softWrap: true,
                  style: TextStyle(
                    color: item.valueColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesignacaoMetadataItemData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color background;
  final Color border;
  final Color labelColor;
  final Color valueColor;

  const _DesignacaoMetadataItemData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.background,
    required this.border,
    required this.labelColor,
    required this.valueColor,
  });
}

class _DesignacaoCategoryStyle {
  final Color base;
  final Color surface;
  final Color border;
  final Color titleColor;
  final Color subtitleColor;
  final Color chipBackground;
  final Color textOnChip;
  final Color iconBackground;
  final Color iconColor;
  final Color metadataBackground;
  final Color metadataBorder;
  final Color metadataLabelColor;
  final Color metadataValueColor;
  final Color badgeBackground;
  final Color badgeBorder;
  final Color badgeText;
  final IconData icon;

  const _DesignacaoCategoryStyle({
    required this.base,
    required this.surface,
    required this.border,
    required this.titleColor,
    required this.subtitleColor,
    required this.chipBackground,
    required this.textOnChip,
    required this.iconBackground,
    required this.iconColor,
    required this.metadataBackground,
    required this.metadataBorder,
    required this.metadataLabelColor,
    required this.metadataValueColor,
    required this.badgeBackground,
    required this.badgeBorder,
    required this.badgeText,
    required this.icon,
  });

  factory _DesignacaoCategoryStyle.from(String categoria) {
    final normalized = categoria.toLowerCase();
    const institutionalBlack = Color(0xFF241D19);
    const cream = Color(0xFFF7EFE3);
    const inkMuted = Color(0xFF73543E);
    const accentGold = Color(0xFFA96A1D);
    const accentRed = Color(0xFF8F2A1D);
    const accentWine = Color(0xFF7A2E26);
    const accentOrange = Color(0xFFC16A2B);
    const accentBrown = Color(0xFF73543E);
    const accentGray = Color(0xFF746A60);
    const softGold = Color(0xFFE3C474);
    const warmCream = Color(0xFFFFF8EA);
    final base = switch (normalized) {
      String value when value.contains('titular') => accentWine,
      String value when value.contains('substitui') => accentOrange,
      String value when value.contains('fun') => accentRed,
      String value when value.contains('lota') => accentGold,
      String value when value.contains('atribui') || value.contains('exerc') =>
        accentBrown,
      String value when value.contains('tempor') => accentGold,
      _ => accentGray,
    };
    final surface = switch (normalized) {
      String value when value.contains('titular') => const Color(0xFFF8EEEA),
      String value when value.contains('substitui') => const Color(0xFFFFF1E4),
      String value when value.contains('fun') => const Color(0xFFF9EDEA),
      String value when value.contains('lota') => const Color(0xFFFFF5DA),
      String value when value.contains('atribui') || value.contains('exerc') =>
        const Color(0xFFF5EDE3),
      String value when value.contains('tempor') => const Color(0xFFFFF5DA),
      _ => const Color(0xFFF1ECE5),
    };
    final icon = switch (normalized) {
      String value when value.contains('titular') =>
        Icons.workspace_premium_rounded,
      String value when value.contains('substitui') => Icons.swap_horiz_rounded,
      String value when value.contains('fun') => Icons.badge_rounded,
      String value when value.contains('lota') => Icons.location_city_rounded,
      String value when value.contains('atribui') || value.contains('exerc') =>
        Icons.account_tree_rounded,
      String value when value.contains('tempor') => Icons.event_rounded,
      _ => Icons.assignment_ind_rounded,
    };
    const titleColor = institutionalBlack;
    const subtitleColor = inkMuted;
    final chipBackground = Color.lerp(cream, base, 0.16)!;
    final chipTextColor = Color.lerp(base, institutionalBlack, 0.20)!;
    final softIconBackground = Color.lerp(cream, base, 0.08)!;

    return _DesignacaoCategoryStyle(
      base: base,
      surface: surface,
      border: Color.lerp(surface, base, 0.16)!,
      titleColor: titleColor,
      subtitleColor: subtitleColor,
      chipBackground: chipBackground,
      textOnChip: chipTextColor,
      iconBackground: softIconBackground,
      iconColor: chipTextColor,
      metadataBackground: warmCream,
      metadataBorder: Color.lerp(cream, base, 0.08)!,
      metadataLabelColor: inkMuted,
      metadataValueColor: institutionalBlack,
      badgeBackground: Color.lerp(warmCream, softGold, 0.28)!,
      badgeBorder: Color.lerp(warmCream, accentGold, 0.22)!,
      badgeText: institutionalBlack,
      icon: icon,
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off,
              size: 42,
              color: ConcessaoFolgaColors.brand,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InlineError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 42,
            color: ConcessaoFolgaColors.muted,
          ),
          SizedBox(height: 10),
          Text(
            'Nenhuma designação ativa encontrada.',
            textAlign: TextAlign.center,
            style: TextStyle(color: ConcessaoFolgaColors.muted),
          ),
        ],
      ),
    );
  }
}
