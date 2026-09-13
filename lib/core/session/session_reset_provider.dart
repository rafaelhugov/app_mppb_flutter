import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/carteira/providers/carteira_provider.dart';
import '../../features/concessao_afastamento/providers/concessao_afastamento_provider.dart';
import '../../features/contra_cheque/providers/contra_cheque_provider.dart';
import '../../features/designacoes/providers/designacoes_provider.dart';
import '../../features/pagamentos/providers/pagamentos_provider.dart';
import '../notifications/notification_center_provider.dart';

final sessionResetProvider = Provider<void>((ref) {
  ref.listen(authProvider, (previous, next) {
    final previousToken = previous?.token;
    final nextToken = next.token;
    if (previousToken == nextToken) {
      return;
    }

    ref.invalidate(carteiraProvider);
    ref.invalidate(contraChequeProvider);
    ref.invalidate(pagamentosProvider);
    ref.invalidate(concessaoAfastamentoProvider);
    ref.invalidate(designacoesProvider);
    ref.invalidate(notificationCenterProvider);
  });
});
