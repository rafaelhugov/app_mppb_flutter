import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/notifications/push_notification_service.dart';
import 'core/notifications/push_navigation_service.dart';
import 'core/notifications/notification_center_provider.dart';
import 'core/router/app_router.dart';
import 'core/session/session_reset_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/perfil/providers/preferencias_notificacao_provider.dart';
import 'firebase_options.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  runApp(const ProviderScope(child: MyApp()));
}

const _disableFcmForE2E = bool.fromEnvironment('Q5_E2E_DISABLE_FCM');

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  bool _fcmReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeFirebaseAndPush());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(notificationCenterProvider.notifier).reload());
    }
  }

  Future<void> _initializeFirebaseAndPush() async {
    if (_disableFcmForE2E || !PushNotificationService.isSupportedPlatform) {
      if (kDebugMode) {
        debugPrint('Firebase/FCM desabilitado nesta plataforma.');
      }
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ).timeout(const Duration(seconds: 4));
      }
      if (!mounted) return;
      setState(() => _fcmReady = true);
      await PushNotificationService.instance.initialize();
      if (!mounted) return;
      await ref.read(authProvider.notifier).refreshPushRegistration();
      await ref.read(preferenciasNotificacaoProvider.notifier).carregar();
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          'FCM indisponível; aplicativo seguirá sem notificações: $error',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    ref.watch(sessionResetProvider);
    ref.watch(preferenciasNotificacaoProvider);
    if (_fcmReady) {
      ref.watch(pushNavigationServiceProvider);
    }

    return MaterialApp.router(
      title: 'MPPB App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8F2A1D),
        ), // Vermelho escuro/Vinho do MPPB
        useMaterial3: true,
        textTheme: GoogleFonts.manropeTextTheme(Theme.of(context).textTheme),
      ),
      routerConfig: router,
      scrollBehavior: AppScrollBehavior(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
    );
  }
}
