import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mppb_flutter/core/version/force_update_provider.dart';
import 'package:app_mppb_flutter/core/version/force_update_state.dart';
import 'package:app_mppb_flutter/core/version/ui/force_update_dialog.dart';

void main() {
  group('ForceUpdateNotifier & State', () {
    test('Estado inicial não exige atualização', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(forceUpdateProvider);
      expect(state.isForceUpdateRequired, isFalse);
      expect(state.minBuild, 0);
    });

    test('triggerForceUpdate atualiza estado para bloqueio com links corretos',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(forceUpdateProvider.notifier).triggerForceUpdate(
            minBuild: 130,
            currentBuild: 129,
            storeUrl: 'https://play.google.com/store/apps/details?id=br.mp.mppbapp.app',
            message: 'Atualização mandatória para testes.',
          );

      final state = container.read(forceUpdateProvider);
      expect(state.isForceUpdateRequired, isTrue);
      expect(state.minBuild, 130);
      expect(state.currentBuild, 129);
      expect(state.message, 'Atualização mandatória para testes.');
      expect(state.storeUrl, contains('br.mp.mppbapp.app'));
    });
  });

  group('ForceUpdateDialog Widget', () {
    testWidgets('Renderiza informações institucionais e botão de atualização',
        (tester) async {
      const state = ForceUpdateState(
        isForceUpdateRequired: true,
        minBuild: 130,
        currentBuild: 129,
        storeUrl: 'https://play.google.com/store/apps/details?id=br.mp.mppbapp.app',
        message: 'Versão obsoleta. Favor atualizar na loja.',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ForceUpdateDialog(state: state),
          ),
        ),
      );

      expect(find.text('Atualização Necessária'), findsOneWidget);
      expect(find.text('Ministério Público da Paraíba'), findsOneWidget);
      expect(
        find.text('Versão obsoleta. Favor atualizar na loja.'),
        findsOneWidget,
      );
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
    });
  });
}

