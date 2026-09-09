import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/ui/main_layout.dart';
import '../../../core/ui/widgets/hero_header_publico.dart';
import '../providers/carteira_provider.dart';
import '../models/usuario_carteira.dart';

class CarteiraPage extends ConsumerStatefulWidget {
  const CarteiraPage({super.key});

  @override
  ConsumerState<CarteiraPage> createState() => _CarteiraPageState();
}

class _CarteiraPageState extends ConsumerState<CarteiraPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isFront = true;

  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticatedLocally = false;
  bool _isAuthenticating = false;
  bool _didTryAutoAuth = false;
  bool _isExportingPdf = false;

  final GlobalKey _pdfFrontKey = GlobalKey();
  final GlobalKey _pdfBackKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    _isFront = !_isFront;
  }

  String _formatCpf(String? cpf) {
    if (cpf == null || cpf.isEmpty) return '';
    final numbers = cpf.replaceAll(RegExp(r'\D'), '');
    if (numbers.length == 11) {
      return '${numbers.substring(0, 3)}.${numbers.substring(3, 6)}.${numbers.substring(6, 9)}-${numbers.substring(9, 11)}';
    }
    return cpf;
  }

  String _formatData(String? data) {
    if (data == null || data.isEmpty) return '';
    try {
      final parts = data.split(' ');
      final datePart = parts[0];
      final dateTokens = datePart.split('-');
      if (dateTokens.length == 3) {
        return '${dateTokens[2]}/${dateTokens[1]}/${dateTokens[0]}';
      }
      return data;
    } catch (e) {
      return data;
    }
  }

  Future<void> _authenticate() async {
    setState(() => _isAuthenticating = true);
    try {
      final authenticated = await _auth.authenticate(
        localizedReason:
            'Autentique-se para acessar sua Carteira Funcional offline',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      if (mounted) {
        setState(() {
          _isAuthenticatedLocally = authenticated;
        });
      }
    } on PlatformException catch (e) {
      debugPrint('Erro na biometria: $e');
    } on MissingPluginException catch (e) {
      debugPrint(
        'Biometria não suportada nesta plataforma (mockando como sucesso): $e',
      );
      if (mounted) {
        setState(() {
          _isAuthenticatedLocally = true;
        });
      }
    } catch (e) {
      debugPrint('Erro inesperado na biometria: \$e');
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(carteiraProvider);

    if (state.isOffline && !_isAuthenticatedLocally) {
      if (!_didTryAutoAuth && !_isAuthenticating) {
        _didTryAutoAuth = true;
        Future.microtask(() => _authenticate());
      }
      return Scaffold(
        backgroundColor: const Color(0xFFEBE3D7),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 64,
                color: Color(0xFF3E2723),
              ),
              const SizedBox(height: 16),
              const Text(
                'Acesso Offline',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Para visualizar sua Carteira Funcional sem conexão, é necessária autenticação no dispositivo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6D4C41)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isAuthenticating ? null : _authenticate,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Autenticar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8F2A1D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final content = state.isLoading
        ? const Center(child: CircularProgressIndicator())
        : state.errorMessage != null && state.data == null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(carteiraProvider.notifier).fetchCarteira(),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          )
        : state.data != null
        ? SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  0,
                  MainLayout.authenticatedContentTopPadding(context),
                  0,
                  MainLayout.contentBottomPadding(context),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const HeroHeaderPublico(
                      label: '',
                      title: 'Carteira Funcional',
                      subtitle: '',
                      icon: Icons.badge_rounded,
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _flipCard,
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          final transform = Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(_animation.value * pi);

                          return Transform(
                            transform: transform,
                            alignment: Alignment.center,
                            child: _animation.value < 0.5
                                ? _buildFront(state.data!, state.isOffline)
                                : Transform(
                                    transform: Matrix4.identity()..rotateY(pi),
                                    alignment: Alignment.center,
                                    child: _buildBack(state.data!),
                                  ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: _isExportingPdf
                          ? null
                          : () => _exportarPdf(
                              context,
                              state.data!,
                              state.isOffline,
                            ),
                      icon: _isExportingPdf
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.file_download, size: 18),
                      label: Text(
                        _isExportingPdf ? 'GERANDO PDF' : 'BAIXAR PDF',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD62828),
                        side: const BorderSide(color: Color(0xBFD62828)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : const Center(child: Text('Nenhum dado encontrado'));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(carteiraProvider.notifier).fetchCarteira(),
              child: content,
            ),
          ),
          if (state.data != null)
            Positioned(
              left: -10000,
              top: 0,
              child: Material(
                color: Colors.transparent,
                child: Row(
                  children: [
                    RepaintBoundary(
                      key: _pdfFrontKey,
                      child: _buildFront(state.data!, false),
                    ),
                    RepaintBoundary(
                      key: _pdfBackKey,
                      child: _buildBack(state.data!),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFront(UsuarioCarteira usuario, bool isOffline) {
    final isMembro = usuario.tipoCargo == 'M' || usuario.tipoCargo == 'MEMBRO';

    final bgColor1 = isMembro
        ? const Color(0xFF7A1A1A)
        : const Color(0xFFF5EBE1);
    final bgColor2 = isMembro
        ? const Color(0xFF4A0909)
        : const Color(0xFFE8DCD1);

    final titleColor = isMembro ? Colors.white : const Color(0xFF3E2723);
    final subTitleColor = isMembro
        ? const Color(0xFFD4AF37)
        : const Color(0xFF6D4C41);

    final badgeBg = isMembro
        ? const Color(0xFFD4AF37)
        : const Color(0xFFE4D5CD);
    final badgeText = isMembro
        ? const Color(0xFF5A0B0B)
        : const Color(0xFF3E2723);

    final nameColor = isMembro ? Colors.white : const Color(0xFF3E2723);
    final cargoColor = isMembro
        ? const Color(0xFFD4AF37)
        : const Color(0xFF6D4C41);

    final labelColor = isMembro
        ? Colors.white.withValues(alpha: 0.6)
        : const Color(0xFF6D4C41);
    final valueColor = isMembro ? Colors.white : const Color(0xFF3E2723);

    final borderColor = isMembro
        ? Colors.transparent
        : Colors.white.withValues(alpha: 0.2);
    final borderSize = isMembro ? 0.0 : 2.0;

    return Container(
      width: 320,
      height: 500, // aspect ratio 54/86 approx
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor1, bgColor2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: borderSize),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Lines Pattern
            CustomPaint(
              size: const Size(320, 500),
              painter: _PatternPainter(isMembro),
            ),
            // Watermark
            Center(
              child: Opacity(
                opacity: isMembro ? 0.08 : 0.05,
                child: Image.asset(
                  'assets/images/brasao_mppb_sem_fundo.png',
                  width: 250,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  // Header
                  SizedBox(
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Conteúdo centralizado
                        Column(
                          children: [
                            Image.asset(
                              isMembro
                                  ? 'assets/images/Coat_of_arms_of_Brazil.svg.png'
                                  : 'assets/images/brasao_mppb_sem_fundo.png',
                              height: 56,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'MINISTÉRIO PÚBLICO DA PARAÍBA',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: GoogleFonts.manrope().fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'CARTEIRA DE IDENTIDADE FUNCIONAL',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: GoogleFonts.manrope().fontFamily,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: subTitleColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isMembro ? 'MEMBRO' : 'SERVIDOR',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: badgeText,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Foto
                  Container(
                    width: 110,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isMembro
                            ? const Color(0xFFD4AF37)
                            : const Color(0xFFE4D5CD),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: usuario.foto != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: usuario.foto!,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => const Icon(
                                Icons.person,
                                size: 56,
                                color: Colors.white54,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 56,
                            color: Colors.white54,
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Nome e Cargo
                  Text(
                    usuario.nome ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: GoogleFonts.manrope().fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: nameColor,
                    ),
                  ),
                  Text(
                    usuario.cargo ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: GoogleFonts.manrope().fontFamily,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: cargoColor,
                    ),
                  ),

                  const Spacer(),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          isMembro
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Rodapé (Matrícula e Emissão)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MATRÍCULA',
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w600,
                              color: labelColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            usuario.matricula ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: valueColor,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'EMISSÃO',
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w600,
                              color: labelColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '22/05/2026',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: valueColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.autorenew,
                        size: 12,
                        color: isMembro
                            ? Colors.white54
                            : const Color(0xFFA89F9A),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'GIRAR CREDENCIAL',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: isMembro
                              ? Colors.white54
                              : const Color(0xFFA89F9A),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack(UsuarioCarteira usuario) {
    final isMembro = usuario.tipoCargo == 'M' || usuario.tipoCargo == 'MEMBRO';

    final bgColor1 = isMembro
        ? const Color(0xFF7A1A1A)
        : const Color(0xFFF5EBE1);
    final bgColor2 = isMembro
        ? const Color(0xFF4A0909)
        : const Color(0xFFE8DCD1);

    final labelColor = isMembro
        ? Colors.white.withValues(alpha: 0.8)
        : const Color(0xFF5C524F);
    final valueColor = isMembro ? Colors.white : const Color(0xFF1C1917);

    final borderColor = isMembro
        ? Colors.transparent
        : Colors.white.withValues(alpha: 0.2);
    final borderSize = isMembro ? 0.0 : 2.0;

    final qrData =
        'https://mobile-api.mppb.mp.br/public/validar-carteira/${usuario.md5 ?? ''}';

    return Container(
      width: 320,
      height: 500,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor1, bgColor2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: borderSize),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            CustomPaint(
              size: const Size(320, 500),
              painter: _PatternPainter(isMembro),
            ),
            Center(
              child: Opacity(
                opacity: isMembro ? 0.08 : 0.05,
                child: Image.asset(
                  'assets/images/brasao_mppb_sem_fundo.png',
                  width: 250,
                ),
              ),
            ),
            if (isMembro)
              Positioned(
                top: 24,
                right: 20,
                child: Opacity(
                  opacity: 0.85,
                  child: Image.asset(
                    'assets/images/brasao_mppb_sem_fundo.png',
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBackItem(
                    'CPF',
                    _formatCpf(usuario.cpf),
                    labelColor,
                    valueColor,
                  ),
                  _buildBackItem(
                    'RG / ÓRGÃO EXPEDIDOR',
                    '${usuario.rg ?? ''} ${usuario.orgaoExp ?? ''}',
                    labelColor,
                    valueColor,
                  ),
                  _buildBackItem(
                    'DATA DE NASCIMENTO',
                    _formatData(usuario.nascimento),
                    labelColor,
                    valueColor,
                  ),
                  _buildBackItem(
                    'NATURALIDADE',
                    usuario.naturalidade ?? '',
                    labelColor,
                    valueColor,
                  ),
                  _buildBackItem(
                    'FILIAÇÃO',
                    '${usuario.nomePai ?? ''}\n${usuario.nomeMae ?? ''}',
                    labelColor,
                    valueColor,
                  ),

                  const Spacer(),

                  // QR Code
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 90.0,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Assinatura
                  Center(
                    child: Column(
                      children: [
                        _buildAssinaturaPgj(usuario, isMembro),
                        Container(
                          width: 140,
                          height: 1,
                          color: isMembro ? Colors.white54 : Colors.black54,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                        ),
                        Text(
                          usuario.nomePgj ?? 'Procurador-Geral de Justiça',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: valueColor,
                          ),
                        ),
                        Text(
                          'Procurador-Geral de Justiça',
                          style: TextStyle(fontSize: 8, color: labelColor),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    'VÁLIDA EM TODO O TERRITÓRIO NACIONAL COMO DOCUMENTO DE IDENTIDADE\nLEI Nº 8.625/1993, ART. 43 E LEI COMPLEMENTAR Nº 97/2010, ART. 182',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w600,
                      color: labelColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssinaturaPgj(UsuarioCarteira usuario, bool isMembro) {
    final assinaturaUrl = isMembro
        ? usuario.assinaturaPgjWhiteUrl
        : usuario.assinaturaPgjBlackUrl;
    final assinaturaAsset = isMembro
        ? 'assets/images/carteirafuncional/assinatura/assinaturapgj_white.png'
        : 'assets/images/carteirafuncional/assinatura/assinaturapgj_black.png';

    final fallback = Image.asset(
      assinaturaAsset,
      height: 30,
      fit: BoxFit.contain,
    );

    if (assinaturaUrl == null || assinaturaUrl.trim().isEmpty) {
      return fallback;
    }

    return CachedNetworkImage(
      imageUrl: assinaturaUrl,
      height: 30,
      fit: BoxFit.contain,
      placeholder: (context, url) => fallback,
      errorWidget: (context, url, error) => fallback,
    );
  }

  Widget _buildBackItem(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 7,
              color: labelColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportarPdf(
    BuildContext context,
    UsuarioCarteira usuario,
    bool isOffline,
  ) async {
    if (isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exportação em PDF disponível apenas online.'),
        ),
      );
      return;
    }

    setState(() => _isExportingPdf = true);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await WidgetsBinding.instance.endOfFrame;

      final frontBytes = await _capturePng(_pdfFrontKey);
      final backBytes = await _capturePng(_pdfBackKey);
      final pdfBytes = await _buildPdf(frontBytes, backBytes);
      final nomeArquivo = _nomeArquivoPdf(usuario);

      await Printing.sharePdf(bytes: pdfBytes, filename: nomeArquivo);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível gerar o PDF: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingPdf = false);
      }
    }
  }

  Future<Uint8List> _capturePng(GlobalKey key) async {
    final context = key.currentContext;
    if (context == null) {
      throw Exception('Credencial indisponível para exportação.');
    }

    final boundary = context.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('Não foi possível capturar a credencial.');
    }

    final image = await boundary.toImage(pixelRatio: 4);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    final bytes = byteData?.buffer.asUint8List();
    if (bytes == null || bytes.isEmpty) {
      throw Exception('Imagem da credencial vazia.');
    }

    return bytes;
  }

  Future<Uint8List> _buildPdf(Uint8List frontBytes, Uint8List backBytes) async {
    final document = pw.Document();
    final front = pw.MemoryImage(frontBytes);
    final back = pw.MemoryImage(backBytes);

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return pw.Center(
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Image(front, width: 250),
                pw.SizedBox(width: 34),
                pw.Image(back, width: 250),
              ],
            ),
          );
        },
      ),
    );

    return document.save();
  }

  String _nomeArquivoPdf(UsuarioCarteira usuario) {
    final nome = (usuario.nome ?? 'carteira_funcional')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return '${nome.isEmpty ? 'carteira_funcional' : nome}.pdf';
  }
}

class _PatternPainter extends CustomPainter {
  final bool isMembro;
  _PatternPainter(this.isMembro);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isMembro
          ? Colors.white.withValues(alpha: 0.02)
          : Colors.black.withValues(alpha: 0.02)
      ..strokeWidth = 1.0;

    for (double i = -size.height; i < size.width; i += 10) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
