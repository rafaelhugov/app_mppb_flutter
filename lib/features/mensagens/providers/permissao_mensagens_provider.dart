import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/mensagens_repository.dart';

/// Indica se o usuário autenticado possui a authority `androidmppb.mensagens.admin`
/// no sistema de autorização para acessar o painel de envio de avisos.
final podeEnviarMensagensProvider = FutureProvider<bool>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) {
    return false;
  }
  try {
    return await ref.read(mensagensRepositoryProvider).verificarPermissaoAdmin();
  } catch (_) {
    return false;
  }
});

