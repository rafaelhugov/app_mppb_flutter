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
    if (_idComarca != null) filtros['idComarca'] = _idComarca;
    if (_idClasse != null) filtros['idClasse'] = _idClasse;
    if (_idTipoAtividade != null) filtros['idTipoAtividade'] = _idTipoAtividade;

    ref.read(consultaProcessosProvider.notifier).buscarProcessos(filtros);
  }

  void _abrirProcesso(ProcessoResumo processo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _CaptchaDialog(processo: processo),
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
              child: _buildFormPanel(state.isLoading),
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

  Widget _buildFormPanel(bool isLoading) {
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
          subtitle: 'Refine a busca',
          children: [
            _buildDropdown(
              'Comarca',
              ['--Todas--'],
              _idComarca,
              (v) => setState(() => _idComarca = v),
            ),
            const SizedBox(height: 10),
            _buildDropdown(
              'Classe',
              ['--Todas--'],
              _idClasse,
              (v) => setState(() => _idClasse = v),
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
              ['--Todas--'],
              _idTipoAtividade,
              (v) => setState(() => _idTipoAtividade = v),
            ),
            const SizedBox(height: 10),
            _buildStatusRadio(),
          ],
        ),
        const SizedBox(height: 14),

        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 210),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _buscar,
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.search, size: 18),
                label: const Text(
                  'Pesquisar processo',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD62828),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  shadowColor: Colors.transparent,
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
    required String subtitle,
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
        fillColor: const Color(0xFFF7F8F6),
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
    List<String> options,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value ?? options.first,
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFF202322),
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF697370),
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFF7F8F6),
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
          vertical: 10,
        ),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF697370),
      ),
      items: options.map((e) {
        return DropdownMenuItem(
          value: e,
          child: Text(
            e,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF202322),
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildStatusRadio() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F6),
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
    if (state.errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }

    if (!state.searched) return const SizedBox.shrink();

    if (state.resultados.isEmpty && !state.isLoading) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFCCCCCC),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: const [
            Icon(Icons.search_off, size: 64, color: Color(0xFFBDBDBD)),
            SizedBox(height: 16),
            Text(
              'Nenhum processo encontrado',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Tente ajustar os filtros da pesquisa e tente novamente.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
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
            mainAxisExtent: 220,
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
                            color: isAtivo ? Colors.green : Colors.grey,
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
                        color: Color(0xFF1976D2),
                        letterSpacing: -0.5,
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.person,
                          color: Color(0xFF1976D2),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF424242),
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Interessado: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF616161),
                                  ),
                                ),
                                TextSpan(text: proc.interessado ?? 'N/D'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.account_balance,
                          color: Color(0xFF1976D2),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            proc.promotoria ?? 'N/D',
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

  @override
  Widget build(BuildContext context) {
    final captchaAsync = ref.watch(captchaProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF1976D2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Informe o código',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
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
                          color: const Color(0xFFF5F5F5),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
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
                              widget.processo.classe ?? '',
                            ),
                            _buildProcessDetailRow(
                              'Órgão Atual:',
                              widget.processo.promotoria ?? '',
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
                                  color: const Color(0xFFEEEEEE),
                                  border: Border.all(
                                    color: const Color(0xFFBDBDBD),
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
                                          color: Color(0xFF1976D2),
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
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1976D2),
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF424242),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                color: isHighlight
                    ? const Color(0xFF1976D2)
                    : const Color(0xFF424242),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
