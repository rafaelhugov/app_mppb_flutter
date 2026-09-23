import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../core/network/connectivity_provider.dart';
import '../../../core/ui/app_feedback.dart';
import '../../../core/ui/main_layout.dart';
import '../../../core/ui/widgets/hero_header_publico.dart';
import '../models/certidao_extrajudicial.dart';
import '../providers/certidao_extrajudicial_provider.dart';

class CertidaoExtrajudicialPage extends ConsumerStatefulWidget {
  const CertidaoExtrajudicialPage({super.key});

  @override
  ConsumerState<CertidaoExtrajudicialPage> createState() =>
      _CertidaoExtrajudicialPageState();
}

class _CertidaoExtrajudicialPageState
    extends ConsumerState<CertidaoExtrajudicialPage> {
  final _formKey = GlobalKey<FormState>();
  final _codigoFormKey = GlobalKey<FormState>();
  final _documentoController = TextEditingController();
  final _nomeController = TextEditingController();
  final _codigoController = TextEditingController();

  String _tipoDocumento = 'F';
  int _tabIndex = 0;

  @override
  void dispose() {
    _documentoController.dispose();
    _nomeController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(certidaoExtrajudicialProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(connectivityProvider.notifier).refresh();
          final codigo = _codigoController.text.trim();
          if (_tabIndex == 1 && codigo.isNotEmpty) {
            await ref
                .read(certidaoExtrajudicialProvider.notifier)
                .consultarCodigo(codigo);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HeroHeaderPublico(
                label: '',
                title: 'Certidão Extrajudicial',
                subtitle: '',
                icon: Icons.verified_outlined,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTabs(),
                    const SizedBox(height: 14),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: _tabIndex == 0
                          ? _buildEmissaoForm(state)
                          : _buildValidacaoForm(state),
                    ),
                    if (state.certidao != null && _tabIndex == 1) ...[
                      const SizedBox(height: 14),
                      _buildResultadoValidacao(state.certidao!, state),
                    ],
                    SizedBox(height: MainLayout.contentBottomPadding(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 230),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFF202322),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0x66FFFFFF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2A101828),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: DefaultTabController(
            length: 2,
            initialIndex: _tabIndex,
            child: TabBar(
              onTap: (index) => setState(() => _tabIndex = index),
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: const Color(0xFF202322),
              unselectedLabelColor: const Color(0xFFDDE4DF),
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              tabs: const [
                Tab(
                  height: 34,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf_rounded, size: 17),
                      SizedBox(width: 4),
                      Flexible(child: Text('Emitir')),
                    ],
                  ),
                ),
                Tab(
                  height: 34,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_rounded, size: 17),
                      SizedBox(width: 4),
                      Flexible(child: Text('Validar')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmissaoForm(CertidaoExtrajudicialState state) {
    return Form(
      key: _formKey,
      child: _buildPanel(
        key: const ValueKey('emissao'),
        children: [
          _buildInfoCard(
            'Emita a certidão informando CPF ou CNPJ e o nome da pessoa ou empresa.',
          ),
          const SizedBox(height: 18),
          _buildRadioGroup(),
          const SizedBox(height: 18),
          _buildTextField(
            controller: _documentoController,
            label: _tipoDocumento == 'F' ? 'CPF' : 'CNPJ',
            keyboardType: TextInputType.number,
            maxLength: _tipoDocumento == 'F' ? 14 : 18,
            inputFormatters: [_DocumentoCertidaoInputFormatter(_tipoDocumento)],
            validator: (value) {
              final digits = _digitsOnly(value ?? '');
              final expected = _tipoDocumento == 'F' ? 11 : 14;
              if (digits.length != expected) {
                return 'Informe ${_tipoDocumento == 'F' ? 'um CPF' : 'um CNPJ'} válido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _nomeController,
            label: 'Nome',
            textCapitalization: TextCapitalization.words,
            maxLength: 60,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.length < 3) return 'Informe pelo menos 3 caracteres.';
              return null;
            },
          ),
          const SizedBox(height: 18),
          _buildPrimaryButton(
            label: 'Emitir PDF',
            color: _tipoDocumento == 'F'
                ? const Color(0xFFD62828)
                : const Color(0xFF2563EB),
            onTap: state.isPdfLoading ? null : _emitirPdf,
            isLoading: state.isPdfLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildValidacaoForm(CertidaoExtrajudicialState state) {
    return Form(
      key: _codigoFormKey,
      child: _buildPanel(
        key: const ValueKey('validacao'),
        children: [
          _buildInfoCard(
            'Consulte uma certidão já emitida pelo código verificador.',
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _codigoController,
            label: 'Código verificador',
            textCapitalization: TextCapitalization.characters,
            borderColor: _codigoValidadoComSucesso(state)
                ? const Color(0xFF00A86B)
                : null,
            onChanged: (_) => setState(() {}),
            validator: (value) {
              if ((value ?? '').trim().isEmpty) {
                return 'Informe o código verificador.';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          _buildPrimaryButton(
            label: 'Validar certidão',
            color: const Color(0xFF00A86B),
            onTap: state.isLoading ? null : _consultarCodigo,
            isLoading: state.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildPanel({required Key key, required List<Widget> children}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE9EDF0)),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F6),
        border: Border.all(color: const Color(0xFFE9EDF0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFD62828),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF697370),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioGroup() {
    final activeColor = _tipoDocumento == 'F'
        ? const Color(0xFFD62828)
        : const Color(0xFF2563EB);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 172),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFE9EDF0)),
          ),
          child: DefaultTabController(
            length: 2,
            initialIndex: _tipoDocumento == 'F' ? 0 : 1,
            child: TabBar(
              onTap: (index) {
                final value = index == 0 ? 'F' : 'J';
                setState(() {
                  _tipoDocumento = value;
                  _documentoController.clear();
                });
              },
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF202322),
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              indicator: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(999),
              ),
              tabs: const [
                Tab(height: 34, child: Text('CPF')),
                Tab(height: 34, child: Text('CNPJ')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    Color? borderColor,
  }) {
    final activeBorderColor = borderColor ?? const Color(0xFFD62828);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      onChanged: onChanged,
      inputFormatters: [
        ...?inputFormatters,
        if (inputFormatters == null && keyboardType == TextInputType.number)
          FilteringTextInputFormatter.digitsOnly,
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE9EDF0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: borderColor ?? const Color(0xFFE9EDF0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: activeBorderColor, width: 1.2),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required Color color,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: isLoading ? 48 : 190,
        height: 40,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            disabledBackgroundColor: color.withAlpha(100),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isLoading ? 20 : 999),
            ),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: isLoading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(label, key: const ValueKey('label')),
          ),
        ),
      ),
    );
  }

  Widget _buildResultadoValidacao(
    CertidaoExtrajudicial certidao,
    CertidaoExtrajudicialState state,
  ) {
    return _buildPanel(
      key: const ValueKey('resultado'),
      children: [
        Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: Color(0xFF00A86B),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                certidao.status ?? 'Certidão encontrada',
                style: const TextStyle(
                  color: Color(0xFF202322),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildResultLine('Código', certidao.codigoVerificador),
        _buildResultLine('Documento', certidao.documentoFormatado),
        _buildResultLine('Nome', certidao.nome),
        _buildResultLine('Tipo', certidao.tipoDocumento),
        if (certidao.protocolos.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Protocolos relacionados',
            style: TextStyle(
              color: Color(0xFF202322),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...certidao.protocolos.map(_buildProtocoloCard),
        ],
        if (certidao.codigoVerificador != null) ...[
          const SizedBox(height: 16),
          _buildPrimaryButton(
            label: 'Abrir PDF',
            color: const Color(0xFF2563EB),
            onTap: state.isPdfLoading
                ? null
                : () => _baixarPdfPorCodigo(certidao.codigoVerificador!),
            isLoading: state.isPdfLoading,
          ),
        ],
      ],
    );
  }

  Widget _buildResultLine(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Color(0xFF697370),
            fontSize: 13,
            height: 1.3,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Color(0xFF202322),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtocoloCard(ProtocoloCertidao protocolo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F6),
        border: Border.all(color: const Color(0xFFE9EDF0)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultLine('Número', protocolo.numero),
          _buildResultLine('Classe', protocolo.classe),
          _buildResultLine('Assunto', protocolo.assunto),
        ],
      ),
    );
  }

  Future<void> _emitirPdf() async {
    if (!_formKey.currentState!.validate()) return;
    final bytes = await ref
        .read(certidaoExtrajudicialProvider.notifier)
        .emitirPdf(
          tipoDocumento: _tipoDocumento,
          documento: _documentoController.text,
          nome: _nomeController.text,
        );
    if (bytes != null && mounted) {
      _mostrarPdf(bytes, 'certidao-extrajudicial.pdf');
      return;
    }
    if (mounted) {
      _mostrarErroCertidao();
    }
  }

  Future<void> _consultarCodigo() async {
    if (!_codigoFormKey.currentState!.validate()) return;
    await ref
        .read(certidaoExtrajudicialProvider.notifier)
        .consultarCodigo(_codigoController.text);
    if (mounted) {
      _mostrarErroCertidao(
        titulo: 'Certidão não encontrada',
        mensagemPadrao: 'Não localizamos uma certidão com esse código.',
      );
    }
  }

  Future<void> _baixarPdfPorCodigo(String codigo) async {
    final bytes = await ref
        .read(certidaoExtrajudicialProvider.notifier)
        .baixarPdfPorCodigo(codigo);
    if (bytes != null && mounted) {
      _mostrarPdf(bytes, 'certidao-extrajudicial-$codigo.pdf');
      return;
    }
    if (mounted) {
      _mostrarErroCertidao();
    }
  }

  void _mostrarErroCertidao({
    String titulo = 'Não foi possível concluir',
    String mensagemPadrao = 'Tente novamente em instantes.',
  }) {
    final mensagem = ref
        .read(certidaoExtrajudicialProvider)
        .errorMessage
        ?.trim();
    if (mensagem == null || mensagem.isEmpty) return;
    AppFeedback.showError(
      context,
      mensagem == 'Informação não encontrada' ? mensagemPadrao : mensagem,
      title: titulo,
    );
  }

  bool _codigoValidadoComSucesso(CertidaoExtrajudicialState state) {
    final codigoValidado = state.certidao?.codigoVerificador?.trim();
    if (codigoValidado == null || codigoValidado.isEmpty) return false;
    return _codigoController.text.trim().toLowerCase() ==
        codigoValidado.toLowerCase();
  }

  void _mostrarPdf(Uint8List bytes, String fileName) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.94,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F8F6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 10, 8),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0x33202322),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Certidão Extrajudicial',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF202322),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Compartilhar PDF',
                      onPressed: () =>
                          Printing.sharePdf(bytes: bytes, filename: fileName),
                      icon: const Icon(
                        Icons.ios_share_rounded,
                        color: Color(0xFF697370),
                        size: 19,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF202322),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.paddingOf(context).bottom + 72,
                  ),
                  child: PdfPreview(
                    build: (_) async => bytes,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                    allowPrinting: false,
                    allowSharing: false,
                    pdfFileName: fileName,
                    loadingWidget: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFD62828),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  MediaQuery.paddingOf(context).bottom + 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: FilledButton(
                          onPressed: () => Printing.sharePdf(
                            bytes: bytes,
                            filename: fileName,
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFD62828),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: const Text('Baixar'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () => Printing.sharePdf(
                            bytes: bytes,
                            filename: fileName,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF202322),
                            side: const BorderSide(color: Color(0xFFE0E5E3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: const Text('Compartilhar'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');
}

class _DocumentoCertidaoInputFormatter extends TextInputFormatter {
  _DocumentoCertidaoInputFormatter(this.tipoDocumento);

  final String tipoDocumento;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final maxDigits = tipoDocumento == 'F' ? 11 : 14;
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > maxDigits
        ? digits.substring(0, maxDigits)
        : digits;
    final formatted = tipoDocumento == 'F'
        ? _formatCpf(limited)
        : _formatCnpj(limited);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatCpf(String digits) {
    if (digits.length > 9) {
      return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9)}';
    }
    if (digits.length > 6) {
      return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6)}';
    }
    if (digits.length > 3) {
      return '${digits.substring(0, 3)}.${digits.substring(3)}';
    }
    return digits;
  }

  String _formatCnpj(String digits) {
    if (digits.length > 12) {
      return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5, 8)}/${digits.substring(8, 12)}-${digits.substring(12)}';
    }
    if (digits.length > 8) {
      return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5, 8)}/${digits.substring(8)}';
    }
    if (digits.length > 5) {
      return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5)}';
    }
    if (digits.length > 2) {
      return '${digits.substring(0, 2)}.${digits.substring(2)}';
    }
    return digits;
  }
}
