import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../providers/auth_provider.dart';

class LockedPage extends ConsumerStatefulWidget {
  const LockedPage({super.key});

  @override
  ConsumerState<LockedPage> createState() => _LockedPageState();
}

class _LockedPageState extends ConsumerState<LockedPage> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    setState(() => _isAuthenticating = true);
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Autentique-se para acessar os serviços ao servidor',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      if (mounted) {
        setState(() => _isAuthenticating = false);
        if (authenticated) {
          ref.read(authProvider.notifier).unlock();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1717),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, color: Color(0xFFC5A059), size: 80),
            const SizedBox(height: 24),
            const Text(
              'Área Restrita Bloqueada',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 48),
            if (_isAuthenticating)
              const CircularProgressIndicator(color: Color(0xFFC5A059))
            else
              ElevatedButton.icon(
                onPressed: _authenticate,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Desbloquear com Biometria / Senha'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A1B1B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
              child: const Text(
                'Sair / Entrar com outra conta',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
