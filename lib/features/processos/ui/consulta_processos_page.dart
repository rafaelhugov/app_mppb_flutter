import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/ui/main_layout.dart';
import '../../../core/ui/widgets/hero_header_publico.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/processos_provider.dart';
import '../models/processo.dart';

const _processBlue = Color(0xFF2563EB);
const _statusGreen = Color(0xFF00A86B);

class ConsultaProcessosPage extends ConsumerStatefulWidget {
  const ConsultaProcessosPage({super.key});

  @override
  ConsumerState<ConsultaProcessosPage> createState() =>
      _ConsultaProcessosPageState();
}

class _ConsultaProcessosPageState extends ConsumerState<ConsultaProcessosPage> {
  final _numeroProcessoCtrl = TextEditingController();
  final _numeroOrigemCtrl = TextEditingController();
  final _numeroCnmpCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _cnpjCtrl = TextEditingController();
  final _interessadoCtrl = TextEditingController();
  final _nomePromotorCtrl = TextEditingController();

  String? _statusSelecionado;
  String? _idComarca;
  String? _idClasse;
  String? _idTipoAtividade;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(consultaProcessosProvider.notifier).carregarFiltros(),
    );
  }

  @override
  void dispose() {
    _numeroProcessoCtrl.dispose();
    _numeroOrigemCtrl.dispose();
    _numeroCnmpCtrl.dispose();
    _cpfCtrl.dispose();
    _cnpjCtrl.dispose();
    _interessadoCtrl.dispose();
    _nomePromotorCtrl.dispose();
    super.dispose();
  }

  void _buscar() {
    FocusScope.of(context).unfocus();
    final filtros = <String, dynamic>{};

    if (_numeroProcessoCtrl.text.isNotEmpty) {
      filtros['numeroProcesso'] = _numeroProcessoCtrl.text;
    }
    if (_numeroOrigemCtrl.text.isNotEmpty) {
      filtros['numeroOrigem'] = _numeroOrigemCtrl.text;
    }
    if (_numeroCnmpCtrl.text.isNotEmpty) {
      filtros['numeroCnmp'] = _numeroCnmpCtrl.text;
    }
    if (_cpfCtrl.text.isNotEmpty) {
      filtros['cpf'] = _cpfCtrl.text.replaceAll(RegExp(r'\D'), '');
    }
    if (_cnpjCtrl.text.isNotEmpty) {
      filtros['cnpj'] = _cnpjCtrl.text.replaceAll(RegExp(r'\D'), '');
    }
    if (_interessadoCtrl.text.isNotEmpty) {
      filtros['interessado'] = _interessadoCtrl.text;
    }
    if (_nomePromotorCtrl.text.isNotEmpty) {
      filtros['nomePromotor'] = _nomePromotorCtrl.text;
    }
    if (_statusSelecionado != null) filtros['status'] = _statusSelecionado;
    if (_idComarca != null) filtros['idComarca'] = int.parse(_idComarca!);
    if (_idClasse != null) filtros['idClasse'] = int.parse(_idClasse!);
    if (_idTipoAtividade != null) filtros['idTipoAtividade'] = _idTipoAtividade;

    ref.read(consultaProcessosProvider.notifier).buscarProcessos(filtros);
  }

  void _limparBusca() {
    FocusScope.of(context).unfocus();
    _numeroProcessoCtrl.clear();
    _numeroOrigemCtrl.clear();
    _numeroCnmpCtrl.clear();
    _cpfCtrl.clear();
    _cnpjCtrl.clear();
    _interessadoCtrl.clear();
    _nomePromotorCtrl.clear();
    setState(() {
      _statusSelecionado = null;
      _idComarca = null;
      _idClasse = null;
      _idTipoAtividade = null;
    });
    ref.read(consultaProcessosProvider.notifier).limpar();
    Future.microtask(
      () => ref.read(consultaProcessosProvider.notifier).carregarFiltros(),
    );
  }

  void _abrirProcesso(ProcessoResumo processo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _CaptchaDialog(processo: processo),
    );
  }

  List<String> _formatInteressados(String? interessado) {
    final raw = interessado?.trim();
    if (raw == null || raw.isEmpty) return const ['N/D'];

    final nomes = raw
        .split(RegExp(r'\s*,\s*'))
        .map(_capitalizeName)
        .where((nome) => nome.isNotEmpty)
        .toList(growable: false);

    return nomes.isEmpty ? const ['N/D'] : nomes;
  }

  String _capitalizeName(String value) {
    const lowercaseWords = {
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
    };

    final words = value.trim().toLowerCase().split(RegExp(r'\s+'));
    return words
        .asMap()
        .entries
        .map((entry) {
          final word = entry.value;
          if (word.isEmpty) return word;
          if (entry.key > 0 && lowercaseWords.contains(word)) return word;

          return word
              .split('-')
              .map((part) {
                if (part.isEmpty) return part;
                return '${part[0].toUpperCase()}${part.substring(1)}';
              })
              .join('-');
        })
        .join(' ');
  }

  String _sentenceCaseText(String value) {
    final lower = value.trim().toLowerCase();
    final buffer = StringBuffer();
    var capitalizeNext = true;

    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      if (RegExp(r'[a-záéíóúâêôãõç]').hasMatch(char)) {
        buffer.write(capitalizeNext ? char.toUpperCase() : char);
        capitalizeNext = false;
      } else {
        buffer.write(char);
        if (RegExp(r'[.!?:;\n]').hasMatch(char)) {
          capitalizeNext = true;
        }
      }
    }

    return buffer
        .toString()
        .replaceAll(RegExp(r'\bmppb\b', caseSensitive: false), 'MPPB')
        .replaceAll(RegExp(r'\bmp\b', caseSensitive: false), 'MP')
        .replaceAll(RegExp(r'\bcnmp\b', caseSensitive: false), 'CNMP')
        .replaceAll(RegExp(r'\bcpf\b', caseSensitive: false), 'CPF')
        .replaceAll(RegExp(r'\bcnpj\b', caseSensitive: false), 'CNPJ');
  }

  Widget _buildInteressadoInfo(String? interessado) {
    final nomes = _formatInteressados(interessado);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.person, color: _processBlue, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Interessado:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF616161),
                ),
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: nomes.map((nome) {
                    return Text(
                      nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF424242),
                        height: 1.25,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(consultaProcessosProvider);
    final isAuthenticated = ref.watch(authProvider).isAuthenticated;
    final horizontalPadding = isAuthenticated
        ? MainLayout.authenticatedHorizontalPadding
        : 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HERO SECTION
            const HeroHeaderPublico(
              label: '',
              title: 'Consulta Processual',
              subtitle: '',
              icon: Icons.gavel,
            ),

            // FORM CONTAINER
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 8,
              ),
              child: _buildFormPanel(state),
            ),

            // RESULTS
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: _buildResults(state),
            ),
            SizedBox(height: MainLayout.contentBottomPadding(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildFormPanel(ConsultaProcessosState state) {
    final isLoading = state.isLoading;
    final filtros = state.filtrosOrEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE9EDF0)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10101828),
                offset: Offset(0, 8),
                blurRadius: 18,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info, color: Color(0xFFD62828), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: Color(0xFF697370),
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(
                        text:
                            'Informe pelo menos um campo para consultar. Para processos judiciais, priorize ',
                      ),
                      TextSpan(
                        text:
                            'Nº do Processo, Nº de Origem (CNJ) ou Nº do CNMP.',
                        style: TextStyle(
                          color: Color(0xFF202322),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        _buildFormSection(
          title: 'Dados do processo',
          subtitle: 'Campos principais',
          children: [
            _buildTextField('Nº do Processo', _numeroProcessoCtrl),
            const SizedBox(height: 10),
            _buildTextField('Nº de Origem (CNJ)', _numeroOrigemCtrl),
            const SizedBox(height: 10),
            _buildTextField('Nº do CNMP', _numeroCnmpCtrl),
            const SizedBox(height: 10),
            _buildTextField('CPF', _cpfCtrl, isNumber: true),
            const SizedBox(height: 10),
            _buildTextField('CNPJ', _cnpjCtrl, isNumber: true),
            const SizedBox(height: 10),
            _buildTextField('Interessado', _interessadoCtrl),
          ],
        ),
        const SizedBox(height: 14),

        _buildFormSection(
          title: 'Filtros adicionais',
          trailing: TextButton.icon(
            onPressed: isLoading ? null : _limparBusca,
            icon: const Icon(Icons.refresh_rounded, size: 15),
            label: const Text('Redefinir busca'),
            style: TextButton.styleFrom(
              foregroundColor: _processBlue,
              disabledForegroundColor: const Color(0xFF9AA3A0),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              textStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          children: [
            _buildDropdown(
              'Comarca',
              filtros.comarcas,
              _idComarca,
              (v) => setState(() => _idComarca = v),
              isLoading: state.isLoadingFiltros,
            ),
            const SizedBox(height: 10),
            _buildDropdown(
              'Classe',
              filtros.classes,
              _idClasse,
              (v) => setState(() => _idClasse = v),
              isLoading: state.isLoadingFiltros,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              'Nome do promotor',
              _nomePromotorCtrl,
              showDualIcon: true,
            ),
            const SizedBox(height: 10),
            _buildDropdown(
              'Tipo de Atividade',
              filtros.tiposAtividade,
              _idTipoAtividade,
              (v) => setState(() => _idTipoAtividade = v),
              isLoading: state.isLoadingFiltros,
            ),
            const SizedBox(height: 10),
            _buildStatusRadio(),
            if (state.filtrosErrorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                state.filtrosErrorMessage!,
                style: const TextStyle(
                  color: Color(0xFFD62828),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),

        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            width: isLoading ? 48 : 220,
            height: 42,
            child: ElevatedButton(
              onPressed: isLoading ? null : _buscar,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  const Color(0xFFD62828),
                ),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                overlayColor: WidgetStateProperty.all(
                  Colors.white.withValues(alpha: 0.08),
                ),
                elevation: WidgetStateProperty.all(0),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 16),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isLoading ? 21 : 14),
                  ),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isLoading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.2,
                        ),
                      )
                    : const Row(
                        key: ValueKey('label'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search, size: 18),
                          SizedBox(width: 9),
                          Text(
                            'Pesquisar processo',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection({
    required String title,
    String? subtitle,
    Widget? trailing,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE9EDF0)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10101828),
            offset: Offset(0, 8),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF202322),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (trailing != null)
                trailing
              else if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF697370),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController ctrl, {
    bool isNumber = false,
    bool showDualIcon = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFF202322),
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF697370),
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE9EDF0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE9EDF0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD62828)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        suffixIcon: showDualIcon
            ? const Icon(Icons.search, color: Color(0xFF697370), size: 22)
            : null,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<ProcessoFiltroOption> options,
    String? value,
    ValueChanged<String?> onChanged, {
    bool isLoading = false,
  }) {
    const allOption = ProcessoFiltroOption(id: '', label: 'Todas');
    final items = [allOption, ...options];

    return DropdownButtonFormField<String>(
      initialValue: value ?? allOption.id,
      isExpanded: true,
      menuMaxHeight: 320,
      borderRadius: BorderRadius.circular(14),
      dropdownColor: Colors.white,
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFF202322),
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF697370),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE9EDF0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE9EDF0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD62828)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
      ),
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: _processBlue,
                strokeWidth: 2,
              ),
            )
          : const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF697370),
            ),
      items: items.map((option) {
        final label = option.id.isEmpty
            ? option.label
            : _sentenceCaseText(option.label);
        return DropdownMenuItem(
          value: option.id,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF202322),
              height: 1.25,
            ),
          ),
        );
      }).toList(),
      onChanged: isLoading
          ? null
          : (selected) {
              onChanged(selected == null || selected.isEmpty ? null : selected);
            },
    );
  }

  Widget _buildStatusRadio() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE9EDF0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF202322),
            ),
          ),
          const SizedBox(height: 6),
          RadioGroup<String>(
            groupValue: _statusSelecionado,
            onChanged: (v) => setState(() => _statusSelecionado = v),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildRadioOption('Ativo', 'A'),
                _buildRadioOption('Inativo', 'I'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Radio<String>(
            value: value,
            activeColor: const Color(0xFFD62828),
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFFD62828);
              }
              return const Color(0xFF697370);
            }),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF202322)),
        ),
      ],
    );
  }

  Widget _buildResults(ConsultaProcessosState state) {
    if (!state.searched) return const SizedBox.shrink();

    final hasResults = state.resultados.isNotEmpty;

    Widget buildShell({required Widget child, String? countLabel}) {
      return Padding(
        padding: const EdgeInsets.only(top: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _processBlue.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.manage_search_rounded,
                    color: _processBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Resultados',
                    style: TextStyle(
                      color: Color(0xFF202322),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (countLabel != null)
                  Text(
                    countLabel,
                    style: const TextStyle(
                      color: Color(0xFF697370),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );
    }

    if (state.isLoading) {
      return buildShell(
        child: _buildFeedbackCard(
          icon: Icons.search_rounded,
          iconColor: _processBlue,
          title: 'Consultando processos',
          message: 'Aguarde enquanto buscamos os resultados.',
          showSpinner: true,
        ),
      );
    }

    if (state.errorMessage != null) {
      return buildShell(
        child: _buildFeedbackCard(
          icon: Icons.error_outline_rounded,
          iconColor: const Color(0xFFD62828),
          title: 'Não foi possível concluir a consulta',
          message: state.errorMessage!,
        ),
      );
    }

    if (!hasResults) {
      return buildShell(
        child: _buildFeedbackCard(
          icon: Icons.search_off_rounded,
          iconColor: const Color(0xFF697370),
          title: 'Nenhum processo encontrado',
          message: 'Revise os campos informados e tente novamente.',
        ),
      );
    }

    return buildShell(
      countLabel: '${state.resultados.length} item(ns)',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth < 600
              ? 1
              : (constraints.maxWidth < 900 ? 2 : 3);

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 260,
            ),
            itemCount: state.resultados.length,
            itemBuilder: (context, index) {
              final proc = state.resultados[index];
              final isAtivo = proc.status == 'Ativo';

              return InkWell(
                onTap: () => _abrirProcesso(proc),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE2E4E8)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              proc.classe ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF616161),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isAtivo ? _statusGreen : Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              proc.status ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        proc.numeroProcesso ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _processBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.event, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Registrado em: ${proc.dataRegistro != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(proc.dataRegistro!)) : 'N/D'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFEEEEEE), height: 1),
                      const SizedBox(height: 12),
                      _buildInteressadoInfo(proc.interessado),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.account_balance,
                            color: _processBlue,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _sentenceCaseText(proc.promotoria ?? 'N/D'),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF424242),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFeedbackCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    bool showSpinner = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E4E8)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: showSpinner
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      color: iconColor,
                      strokeWidth: 2.2,
                    ),
                  )
                : Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF202322),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF697370),
                    fontSize: 13,
                    height: 1.35,
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

// CAPTCHA DIALOG
class _CaptchaDialog extends ConsumerStatefulWidget {
  final ProcessoResumo processo;
  const _CaptchaDialog({required this.processo});

  @override
  ConsumerState<_CaptchaDialog> createState() => _CaptchaDialogState();
}

class _CaptchaDialogState extends ConsumerState<_CaptchaDialog> {
  final _ctrl = TextEditingController();

  String _capitalizeText(String value) {
    const lowercaseWords = {
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
    };

    final words = value.trim().toLowerCase().split(RegExp(r'\s+'));
    return words
        .asMap()
        .entries
        .map((entry) {
          final word = entry.value;
          if (word.isEmpty) return word;
          if (entry.key > 0 && lowercaseWords.contains(word)) return word;

          return word
              .split('-')
              .map((part) {
                if (part.isEmpty) return part;
                return '${part[0].toUpperCase()}${part.substring(1)}';
              })
              .join('-');
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final captchaAsync = ref.watch(captchaProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8F6),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Informe o código',
                    style: TextStyle(
                      color: Color(0xFF424242),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF697370)),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFDDE4DF)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _buildProcessDetailRow(
                              'Processo Nº:',
                              widget.processo.numeroProcesso ?? '',
                              isHighlight: true,
                            ),
                            _buildProcessDetailRow(
                              'Nº Origem:',
                              widget.processo.numeroOrigem ?? 'N/D',
                            ),
                            _buildProcessDetailRow(
                              'Descrição:',
                              _capitalizeText(widget.processo.classe ?? ''),
                            ),
                            _buildProcessDetailRow(
                              'Órgão Atual:',
                              _capitalizeText(widget.processo.promotoria ?? ''),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Código da imagem:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF424242),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),

                      captchaAsync.when(
                        data: (data) {
                          final imageBase64 = data['imageBase64'] as String?;
                          final token = data['token'] as String?;

                          if (imageBase64 == null || token == null) {
                            return const Text(
                              'Erro ao carregar o captcha.',
                              style: TextStyle(color: Colors.red),
                            );
                          }
                          final imageBytes = base64Decode(
                            imageBase64.contains(',')
                                ? imageBase64.split(',')[1]
                                : imageBase64,
                          );

                          return Column(
                            children: [
                              Container(
                                height: 80,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFFD7DEDA),
                                    style: BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.memory(
                                      imageBytes,
                                      fit: BoxFit.contain,
                                    ),
                                    Positioned(
                                      right: 4,
                                      top: 4,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.refresh,
                                          color: _processBlue,
                                        ),
                                        onPressed: () =>
                                            ref.refresh(captchaProvider),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _ctrl,
                                decoration: InputDecoration(
                                  hintText: 'Digite o código acima',
                                  filled: true,
                                  fillColor: Colors.white,
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD7DEDA),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: _processBlue,
                                      width: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _processBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    final val = _ctrl.text.trim();
                                    if (val.isEmpty) return;
                                    Navigator.of(context).pop();
                                    context.push(
                                      '/processos/${widget.processo.id}/detalhes?captchaToken=$token&captchaValue=$val',
                                    );
                                  },
                                  child: const Text(
                                    'Continuar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const SizedBox(
                          height: 120,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, s) => Text(
                          'Erro: $e',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessDetailRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                height: 1.25,
                color: Color(0xFF4B5350),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isHighlight ? 11.5 : 11,
                height: 1.28,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                color: isHighlight ? _processBlue : const Color(0xFF424242),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
