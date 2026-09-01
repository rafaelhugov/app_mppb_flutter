import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/storage/secure_storage.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _biometricsEnabled = false;
  bool _obscurePassword = true;
  bool _autoBiometricPrompted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricLogin();
    });
  }

  Future<void> _checkBiometricLogin() async {
    final secureStorage = ref.read(secureStorageProvider);
    final isEnabled = await secureStorage.read(key: 'biometrics_enabled');
    final savedUsername = await secureStorage.read(key: 'saved_username');
    final savedPassword = await secureStorage.read(key: 'saved_password');
    final canUseBiometrics =
        isEnabled == 'true' && savedUsername != null && savedPassword != null;

    if (canUseBiometrics && mounted) {
      setState(() => _biometricsEnabled = true);

      if (!_autoBiometricPrompted) {
        _autoBiometricPrompted = true;
        await Future<void>.delayed(const Duration(milliseconds: 350));
        if (mounted) {
          await _doBiometricLogin(showFailureSnack: false);
        }
      }
    }
  }

  Future<void> _doBiometricLogin({bool showFailureSnack = true}) async {
    final localAuth = LocalAuthentication();
    final bool authenticated;
    try {
      authenticated = await localAuth.authenticate(
        localizedReason: 'Acesse o aplicativo com sua biometria',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on MissingPluginException {
      if (mounted && showFailureSnack) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometria não disponível nesta plataforma.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    } catch (_) {
      if (mounted && showFailureSnack) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível autenticar por biometria.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (authenticated) {
      final success = await ref
          .read(authProvider.notifier)
          .loginWithSavedCredentials();
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Falha ao autenticar credenciais salvas. Faça login com senha.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authProvider.notifier)
        .login(_usuarioController.text.trim(), _senhaController.text);

    if (!success || !mounted) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF202322),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: Stack(
        children: [
          Container(color: const Color(0xFFF7F8F6)),

          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 52, 22, 24),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 360),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE9EDF0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14101828),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/brasao_mppb_sem_fundo.png',
                              width: 68,
                              height: 68,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.shield,
                                    color: Color(0xFFD62828),
                                    size: 62,
                                  ),
                            ),
                            const SizedBox(height: 14),

                            const Text(
                              'MPPB+',
                              style: TextStyle(
                                fontSize: 24,
                                color: Color(0xFF202322),
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 7),
                            const Text(
                              'ACESSO RESTRITO',
                              style: TextStyle(
                                color: Color(0xFFD62828),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            TextFormField(
                              controller: _usuarioController,
                              autocorrect: false,
                              enableSuggestions: false,
                              textCapitalization: TextCapitalization.none,
                              keyboardType: TextInputType.visiblePassword,
                              style: const TextStyle(
                                color: Color(0xFF202322),
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Usuário',
                                labelStyle: const TextStyle(
                                  color: Color(0xFF697370),
                                ),
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: Color(0xFF697370),
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF7F8F6),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE9EDF0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE9EDF0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD62828),
                                    width: 1.2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Usuário é obrigatório';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _senhaController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(
                                color: Color(0xFF202322),
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                labelStyle: const TextStyle(
                                  color: Color(0xFF697370),
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: Color(0xFF697370),
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? 'Mostrar senha'
                                      : 'Ocultar senha',
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF697370),
                                    size: 20,
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF7F8F6),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE9EDF0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE9EDF0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD62828),
                                    width: 1.2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Senha é obrigatória';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),

                            if (_biometricsEnabled) ...[
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: OutlinedButton.icon(
                                  onPressed: authState.isLoading
                                      ? null
                                      : _doBiometricLogin,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF202322),
                                    side: const BorderSide(
                                      color: Color(0xFFDDE4DF),
                                    ),
                                    backgroundColor: const Color(0xFFF7F8F6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.fingerprint_rounded,
                                    color: Color(0xFFD62828),
                                    size: 21,
                                  ),
                                  label: const Text('Acessar com biometria'),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],

                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: ElevatedButton(
                                onPressed: authState.isLoading
                                    ? null
                                    : _fazerLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD62828),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  elevation: 0,
                                ),
                                child: authState.isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'ACESSAR',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 42,
                              child: OutlinedButton(
                                onPressed: authState.isLoading
                                    ? null
                                    : () => context.go('/'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF697370),
                                  side: const BorderSide(
                                    color: Color(0xFFE0E5E3),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                child: const Text('Cancelar'),
                              ),
                            ),

                            if (authState.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 24.0),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0x14D62828),
                                    border: Border.all(
                                      color: const Color(0x33D62828),
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    authState.errorMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFFD62828),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
