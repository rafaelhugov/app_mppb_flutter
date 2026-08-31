import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/main_layout.dart';
import '../../../core/ui/widgets/hero_header_publico.dart';

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
      backgroundColor: const Color(0xFFF7F8F6),
      body: Column(
        children: [
          const _Header(),
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
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const HeroHeaderPublico(
      label: '',
      title: 'Designações Ativas',
      subtitle: '',
      icon: Icons.assignment_ind,
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
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MainLayout.contentBottomPadding(context),
        ),
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
    final normalized = title.toLowerCase();
    final isLotacao = normalized.contains('lota');
    final isFuncao = normalized.contains('fun');
    final icon = isLotacao
        ? Icons.home_rounded
        : isFuncao
        ? Icons.work_rounded
        : Icons.assignment_ind_rounded;
    final color = isLotacao
        ? const Color(0xFFFFC400)
        : isFuncao
        ? const Color(0xFF1769FF)
        : const Color(0xFF697370);

    return Padding(
      padding: const EdgeInsets.only(left: 2, top: 10, bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF202322),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
      constraints: const BoxConstraints(minHeight: 168),
      decoration: BoxDecoration(
        color: category.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: category.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10101828),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -34,
            child: Icon(
              category.icon,
              color: category.backgroundIconColor,
              size: 132,
            ),
          ),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }
}

class _DesignacaoCardTopBar extends StatelessWidget {
  final _DesignacaoCategoryStyle category;
  final String label;

  const _DesignacaoCardTopBar({required this.category, required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 8,
        runSpacing: 6,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: category.chipBackground,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              softWrap: true,
              style: TextStyle(
                color: category.textOnChip,
                fontSize: 11,
                height: 1.1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: category.badgeBackground,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Ativa',
              style: TextStyle(
                color: category.badgeText,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
        ],
      ),
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
    final titleText = _capitalizeText(titulo);
    final subtitleText = hasSubtitle ? _capitalizeText(subtitulo!.trim()) : '';
    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 68),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleText,
            softWrap: true,
            style: TextStyle(
              color: category.titleColor,
              fontSize: 14.2,
              fontWeight: FontWeight.w700,
              height: 1.24,
            ),
          ),
          if (hasSubtitle) ...[
            const SizedBox(height: 6),
            Text(
              subtitleText,
              softWrap: true,
              style: TextStyle(
                color: category.subtitleColor,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _capitalizeText(String value) {
    final smallWords = <String>{
      'a',
      'as',
      'ao',
      'aos',
      'da',
      'das',
      'de',
      'do',
      'dos',
      'e',
      'em',
      'na',
      'nas',
      'no',
      'nos',
      'por',
      'para',
    };
    final words = value.trim().toLowerCase().split(RegExp(r'\s+'));
    return words
        .asMap()
        .entries
        .map((entry) {
          final word = entry.value;
          if (word.isEmpty) return word;
          if (entry.key > 0 && smallWords.contains(word)) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}

class _DesignacaoMetadataGrid extends StatelessWidget {
  final List<_DesignacaoMetadataItemData> items;

  const _DesignacaoMetadataGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 260 && items.length > 1;
        if (!twoColumns) {
          return Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _DesignacaoMetadataItem(item: item),
                  ),
                )
                .toList(),
          );
        }

        final rows = <Widget>[];
        for (var index = 0; index < items.length; index += 2) {
          final secondIndex = index + 1;
          rows.add(
            Padding(
              padding: EdgeInsets.only(
                bottom: secondIndex + 1 < items.length ? 8 : 0,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _DesignacaoMetadataItem(item: items[index]),
                    ),
                    const SizedBox(width: 8),
                    if (secondIndex < items.length)
                      Expanded(
                        child: _DesignacaoMetadataItem(
                          item: items[secondIndex],
                        ),
                      )
                    else
                      const Spacer(),
                  ],
                ),
              ),
            ),
          );
        }

        return Column(children: rows);
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
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
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
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.value,
                  softWrap: true,
                  style: TextStyle(
                    color: item.valueColor,
                    fontSize: 11.2,
                    fontWeight: FontWeight.w500,
                    height: 1.18,
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
  final Color metadataBackground;
  final Color metadataBorder;
  final Color metadataLabelColor;
  final Color metadataValueColor;
  final Color badgeBackground;
  final Color badgeBorder;
  final Color badgeText;
  final Color backgroundIconColor;
  final IconData icon;

  const _DesignacaoCategoryStyle({
    required this.base,
    required this.surface,
    required this.border,
    required this.titleColor,
    required this.subtitleColor,
    required this.chipBackground,
    required this.textOnChip,
    required this.metadataBackground,
    required this.metadataBorder,
    required this.metadataLabelColor,
    required this.metadataValueColor,
    required this.badgeBackground,
    required this.badgeBorder,
    required this.badgeText,
    required this.backgroundIconColor,
    required this.icon,
  });

  factory _DesignacaoCategoryStyle.from(String categoria) {
    final normalized = categoria.toLowerCase();
    const ink = Color(0xFF202322);
    const white = Color(0xFFFFFFFF);
    const mutedOnLight = Color(0xFF697370);
    const lotacaoYellow = Color(0xFFFFC400);
    const funcaoBlue = Color(0xFF1769FF);
    const neutralGray = Color(0xFF343A40);
    const activeGreen = Color(0xFF00C853);

    final isLotacao = normalized.contains('lota');
    final isFuncao =
        normalized.contains('fun') ||
        normalized.contains('atribui') ||
        normalized.contains('exerc');
    final base = switch (normalized) {
      String value when value.contains('lota') => lotacaoYellow,
      String value when value.contains('fun') => funcaoBlue,
      String value when value.contains('atribui') || value.contains('exerc') =>
        funcaoBlue,
      String value when value.contains('titular') => funcaoBlue,
      String value when value.contains('substitui') => funcaoBlue,
      _ => neutralGray,
    };
    final icon = switch (normalized) {
      String value when value.contains('titular') =>
        Icons.workspace_premium_rounded,
      String value when value.contains('substitui') => Icons.swap_horiz_rounded,
      String value when value.contains('fun') => Icons.badge_rounded,
      String value when value.contains('lota') => Icons.home_rounded,
      String value when value.contains('atribui') || value.contains('exerc') =>
        Icons.account_tree_rounded,
      String value when value.contains('tempor') => Icons.event_rounded,
      _ => Icons.assignment_ind_rounded,
    };
    const surface = white;
    const border = Color(0xFFE9EDF0);
    const titleColor = ink;
    const subtitleColor = mutedOnLight;
    final chipBackground = isLotacao
        ? lotacaoYellow
        : isFuncao
        ? funcaoBlue
        : neutralGray;
    final chipTextColor = isLotacao
        ? ink
        : isFuncao
        ? white
        : white;
    const backgroundIconColor = Color(0x14101828);
    final metadataBackground = isLotacao
        ? const Color(0x14FFC400)
        : isFuncao
        ? const Color(0x101769FF)
        : const Color(0xFFF7F8F6);
    final metadataBorder = isLotacao
        ? const Color(0x40FFC400)
        : isFuncao
        ? const Color(0x331769FF)
        : const Color(0xFFE9EDF0);
    const metadataLabelColor = Color(0xFF343A40);
    const metadataValueColor = ink;

    return _DesignacaoCategoryStyle(
      base: base,
      surface: surface,
      border: border,
      titleColor: titleColor,
      subtitleColor: subtitleColor,
      chipBackground: chipBackground,
      textOnChip: chipTextColor,
      metadataBackground: metadataBackground,
      metadataBorder: metadataBorder,
      metadataLabelColor: metadataLabelColor,
      metadataValueColor: metadataValueColor,
      badgeBackground: activeGreen,
      badgeBorder: activeGreen,
      badgeText: white,
      backgroundIconColor: backgroundIconColor,
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
