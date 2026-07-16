import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrivacyNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() {
    state = !state;
  }
}

/// Provider que controla o estado de privacidade global do aplicativo
/// true = Oculta os valores sensíveis (padrão)
/// false = Mostra os valores sensíveis
final privacyProvider = NotifierProvider<PrivacyNotifier, bool>(PrivacyNotifier.new);
