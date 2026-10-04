import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/notifications/device_registration_provider.dart';
import '../../../core/storage/secure_storage.dart';

final authDioProvider = Provider<Dio>((ref) => Dio());

// Definimos o estado da autenticação
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;
  final String? token;

  // Para sabermos se o usuário acabou de logar e precisamos oferecer biometria
  final bool justLoggedIn;
  final String? tempUsername;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
    this.token,
    this.justLoggedIn = false,
    this.tempUsername,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? errorMessage,
    String? token,
    bool? justLoggedIn,
    String? tempUsername,
    bool clearToken = false,
    bool clearTempCredentials = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: errorMessage,
      token: clearToken ? null : token ?? this.token,
      justLoggedIn: justLoggedIn ?? this.justLoggedIn,
      tempUsername: clearTempCredentials
          ? null
          : tempUsername ?? this.tempUsername,
    );
  }
}

// Criamos o Notifier do Riverpod
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _checkInitialAuth();
    return AuthState();
  }

  Future<void> _checkInitialAuth() async {
    final secureStorage = ref.read(secureStorageProvider);
    await _migrarSenhaBiometricaLegada(secureStorage);
    if (!ref.mounted) return;
    final token = await secureStorage.read(key: 'auth_token');
    if (!ref.mounted) return;

    if (token != null && token.isNotEmpty) {
      state = state.copyWith(isAuthenticated: true, token: token);
      await _registrarDispositivoAutenticado(token);
    }
  }

  Future<bool> login(
    String username,
    String password, {
    bool offerBiometrics = true,
  }) async {
    if (state.isLoading) {
      return false;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Cria uma instância de Dio específica para Auth,
      // pois não precisamos dos interceptors normais de requisição autenticada
      final authDio = ref.read(authDioProvider);

      final response = await authDio.post(
        authLoginUrl,
        data: {
          'login': username,
          'senha': password,
          'siglaSistema':
              'ANDROID', // O Vue enviou 'ANDROID' fixo, vamos manter compatibilidade
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) =>
              status != null &&
              status < 600, // Permite tratar a resposta de autenticação.
        ),
      );

      if (_isErroCredencial(response.statusCode)) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário ou senha inválidos.',
        );
        return false;
      } else if (response.statusCode != 200) {
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              'Erro na API de autenticação (Status: ${response.statusCode})',
        );
        return false;
      }

      final data = response.data;
      final token = data['token'];

      if (token == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Token não retornado pela API de autenticação.',
        );
        return false;
      }

      // Salva no secure storage
      final secureStorage = ref.read(secureStorageProvider);
      await _limparDadosLocaisSeTrocarUsuario(secureStorage, username);
      await secureStorage.write(key: 'auth_token', value: token);
      await secureStorage.write(key: 'auth_username', value: username);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        token: token,
        justLoggedIn: false,
        tempUsername: offerBiometrics ? username : null,
        clearTempCredentials: !offerBiometrics,
      );
      await _registrarDispositivoAutenticado(token);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mensagemErroLogin(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Falha na conexão com o servidor.',
      );
      return false;
    }
  }

  bool _isErroCredencial(int? statusCode) {
    return statusCode == 400 ||
        statusCode == 401 ||
        statusCode == 403 ||
        statusCode == 500;
  }

  String _mensagemErroLogin(DioException erro) {
    final statusCode = erro.response?.statusCode;
    if (_isErroCredencial(statusCode)) {
      return 'Usuário ou senha inválidos.';
    }

    if (statusCode != null && statusCode >= 500) {
      return 'Serviço de autenticação indisponível no momento.';
    }

    return 'Falha na conexão com o servidor.';
  }

  Future<void> enableBiometricLogin() async {
    final secureStorage = ref.read(secureStorageProvider);
    await _migrarSenhaBiometricaLegada(secureStorage);
    await secureStorage.write(key: 'biometrics_asked', value: 'true');
    state = state.copyWith(justLoggedIn: false, clearTempCredentials: true);
  }

  Future<void> _limparDadosLocaisSeTrocarUsuario(
    FlutterSecureStorage secureStorage,
    String username,
  ) async {
    final currentUsername = await secureStorage.read(key: 'auth_username');
    final savedUsername = await secureStorage.read(key: 'saved_username');
    await _migrarSenhaBiometricaLegada(secureStorage);

    await secureStorage.delete(key: 'carteira_cache_data');
    await secureStorage.delete(key: 'perfil_cache_data');

    if (currentUsername != null && currentUsername != username) {
      await secureStorage.delete(key: 'auth_token');
      await secureStorage.delete(key: 'carteira_cache_username');
      await secureStorage.delete(key: 'perfil_cache_username');
      await secureStorage.delete(key: 'saved_username');
      await secureStorage.delete(key: 'biometrics_enabled');
      await secureStorage.delete(key: 'biometrics_asked');
    }

    if (savedUsername != null && savedUsername != username) {
      await secureStorage.delete(key: 'saved_username');
      await secureStorage.delete(key: 'biometrics_enabled');
      await secureStorage.delete(key: 'biometrics_asked');
    }
  }

  Future<void> dismissBiometricPrompt() async {
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.write(key: 'biometrics_asked', value: 'true');
    state = state.copyWith(justLoggedIn: false, clearTempCredentials: true);
  }

  Future<void> offerBiometricSetupOnNextLogin() async {
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.delete(key: 'biometrics_asked');
  }

  Future<bool> hasAvailableBiometricCredentials() async {
    final secureStorage = ref.read(secureStorageProvider);
    await _migrarSenhaBiometricaLegada(secureStorage);
    return false;
  }

  Future<bool> enableBiometricLoginFromAvailableCredentials() async {
    final secureStorage = ref.read(secureStorageProvider);
    await _migrarSenhaBiometricaLegada(secureStorage);
    await secureStorage.write(key: 'biometrics_asked', value: 'true');
    state = state.copyWith(justLoggedIn: false, clearTempCredentials: true);
    return false;
  }

  Future<bool> enableBiometricLoginForCurrentUser(String password) async {
    final secureStorage = ref.read(secureStorageProvider);
    await _migrarSenhaBiometricaLegada(secureStorage);
    await secureStorage.write(key: 'biometrics_asked', value: 'true');
    state = state.copyWith(justLoggedIn: false, clearTempCredentials: true);
    return false;
  }

  Future<void> disableBiometricLogin() async {
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.delete(key: 'saved_password');
    await secureStorage.delete(key: 'saved_username');
    await secureStorage.delete(key: 'biometrics_enabled');
    await secureStorage.write(key: 'biometrics_asked', value: 'true');
    state = state.copyWith(justLoggedIn: false, clearTempCredentials: true);
  }

  Future<bool> loginWithSavedCredentials() async {
    final secureStorage = ref.read(secureStorageProvider);
    await _migrarSenhaBiometricaLegada(secureStorage);
    return false;
  }

  Future<void> logout() async {
    final secureStorage = ref.read(secureStorageProvider);
    final token = state.token ?? await secureStorage.read(key: 'auth_token');
    await ref
        .read(deviceRegistrationManagerProvider)
        .desativarAntesLogout(token);

    await secureStorage.delete(key: 'auth_token');
    await secureStorage.delete(key: 'auth_username');
    await secureStorage.delete(key: 'carteira_cache_data');
    await secureStorage.delete(key: 'carteira_cache_username');
    await secureStorage.delete(key: 'perfil_cache_data');
    await secureStorage.delete(key: 'perfil_cache_username');

    state = AuthState(); // Reset state
  }

  Future<void> _migrarSenhaBiometricaLegada(
    FlutterSecureStorage secureStorage,
  ) async {
    final savedPassword = await secureStorage.read(key: 'saved_password');
    if (savedPassword == null) {
      return;
    }
    await secureStorage.delete(key: 'saved_password');
    await secureStorage.delete(key: 'saved_username');
    await secureStorage.delete(key: 'biometrics_enabled');
    await secureStorage.write(key: 'biometrics_asked', value: 'true');
  }

  Future<void> _registrarDispositivoAutenticado(String token) async {
    final manager = ref.read(deviceRegistrationManagerProvider);
    manager.startTokenRefreshListener(() => state.token);
    await manager.registrarSeAutenticado(token);
  }
}

// O provider exposto
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
