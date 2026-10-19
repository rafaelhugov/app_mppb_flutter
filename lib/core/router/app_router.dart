import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/ui/login_page.dart';
import '../../features/carteira/ui/carteira_page.dart';
import '../../features/certidao_extrajudicial/ui/certidao_extrajudicial_page.dart';
import '../../features/contra_cheque/ui/contra_cheque_page.dart';
import '../../features/dashboard/ui/dashboard_page.dart';
import '../../features/designacoes/ui/designacoes_page.dart';
import '../../features/diario_oficial/ui/diario_oficial_page.dart';
import '../../features/noticias/ui/noticias_page.dart';
import '../../features/processos/ui/consulta_processos_page.dart';
import '../../features/processos/ui/processo_detalhes_page.dart';
import '../../features/processos/providers/processos_provider.dart';
import '../../features/perfil/ui/perfil_page.dart';
import '../../features/public/ui/public_dashboard_page.dart';
import '../../features/concessao_afastamento/ui/concessao_afastamento_page.dart';
import '../../features/pagamentos/ui/pagamentos_page.dart';
import '../../features/ouvidoria/ui/ouvidoria_page.dart';
import '../../features/contatos/ui/contatos_page.dart';
import '../network/connectivity_provider.dart';
import '../ui/main_layout.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (_, _) {
      notifyListeners();
    });
    _ref.listen(connectivityProvider, (_, _) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>(
  (ref) => RouterNotifier(ref),
);

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  // Lista de rotas que exigem autenticação
  final restrictedRoutes = [
    '/restrito',
    '/carteira',
    '/contracheque',
    '/pagamentos',
    '/concessao-afastamento',
    '/designacoes',
    '/perfil',
  ];
  final onlineOnlyRoutes = [
    '/contracheque',
    '/pagamentos',
    '/concessao-afastamento',
    '/designacoes',
    '/noticias',
    '/diario_oficial',
    '/certidao-extrajudicial',
    '/processos',
    '/ouvidoria',
  ];

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: notifier,
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isGoingToLogin = state.matchedLocation == '/login';
      final isRestricted = restrictedRoutes.any(
        (route) => state.matchedLocation.startsWith(route),
      );
      final isAuthenticated = authState.isAuthenticated;
      final hasInternet = ref.read(connectivityProvider);
      final isOnline = hasInternet;
      final isOnlineOnly = onlineOnlyRoutes.any(
        (route) => state.matchedLocation.startsWith(route),
      );

      // Se tentar acessar uma rota restrita sem estar logado
      if (isRestricted && !isAuthenticated) {
        return '/login';
      }

      // Se já estiver logado e tentar ir para o login ou para a rota inicial pública, joga pro dashboard restrito
      if (isAuthenticated && (isGoingToLogin || state.matchedLocation == '/')) {
        return '/restrito';
      }

      if (isAuthenticated && !isOnline && isOnlineOnly) {
        return '/restrito';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const PublicDashboardPage(),
          ),
          GoRoute(
            path: '/restrito',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/carteira',
            builder: (context, state) => const CarteiraPage(),
          ),
          GoRoute(
            path: '/contracheque',
            builder: (context, state) => const ContraChequePage(),
          ),
          GoRoute(
            path: '/concessao-afastamento',
            builder: (context, state) => const ConcessaoAfastamentoPage(),
          ),
          GoRoute(
            path: '/designacoes',
            builder: (context, state) => const DesignacoesPage(),
          ),
          GoRoute(
            path: '/pagamentos',
            builder: (context, state) => const PagamentosPage(),
          ),
          GoRoute(
            path: '/perfil',
            builder: (context, state) => const PerfilPage(),
          ),
          GoRoute(
            path: '/diario_oficial',
            builder: (context, state) => const DiarioOficialPage(),
          ),
          GoRoute(
            path: '/certidao-extrajudicial',
            builder: (context, state) => const CertidaoExtrajudicialPage(),
          ),
          GoRoute(
            path: '/noticias',
            builder: (context, state) => NoticiasPage(
              initialNewsKey: state.uri.queryParameters['noticia'],
              initialNewsLink: state.uri.queryParameters['link'],
              initialNewsTitle: state.uri.queryParameters['titulo'],
            ),
          ),
          GoRoute(
            path: '/processos',
            builder: (context, state) => const ConsultaProcessosPage(),
          ),
          GoRoute(
            path: '/processos/:id/detalhes',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final secureParams = state.extra is ProcessoDetalheParams
                  ? state.extra! as ProcessoDetalheParams
                  : null;
              // Compatibilidade temporária com links de versões anteriores.
              final captchaToken =
                  secureParams?.captchaToken ??
                  state.uri.queryParameters['captchaToken'] ??
                  '';
              final captchaValue =
                  secureParams?.captchaValue ??
                  state.uri.queryParameters['captchaValue'] ??
                  '';
              return ProcessoDetalhesPage(
                idProcesso: id,
                captchaToken: captchaToken,
                captchaValue: captchaValue,
              );
            },
          ),
          GoRoute(
            path: '/ouvidoria',
            builder: (context, state) => const OuvidoriaPage(),
          ),
          GoRoute(
            path: '/contatos',
            builder: (context, state) => const ContatosPage(),
          ),
        ],
      ),
    ],
  );
});
