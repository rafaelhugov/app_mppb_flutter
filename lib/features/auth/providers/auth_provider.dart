import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/notifications/device_registration_provider.dart';
import '../../../core/storage/secure_storage.dart';
import '../repositories/biometric_auth_repository.dart';

final authDioProvider = Provider<Dio>((ref) => Dio());
final biometricAuthRepositoryProvider = Provider<BiometricAuthRepository>((
  ref,
) {
  return BiometricAuthRepository(
    dio: ref.read(authDioProvider),
    baseUrl: apiBaseUrl,
  );
});

const _biometricCredentialKey = 'biometric_device_credential';
const _biometricUsernameKey = 'biometric_username';
const skipLocalAuthAutoPromptOnceStorageKey =
    'skip_local_auth_auto_prompt_once';
// Nova versao do convite: instalacoes que receberam a antiga indisponibilidade
// devem ter uma nova oportunidade apos a ativacao da credencial revogavel.
const biometricPromptStorageKey = 'biometrics_secure_v3_asked';

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
  String? _biometricActivationError;

  String? get biometricActivationError => _biometricActivationError;

  @override
  AuthState build() {
    _checkInitialAuth();
    return AuthState();
  }

  Future<void> _checkInitialAuth() async {
    final secureStorage = ref.read(secureStorageProvider);
    await _migrarSenhaBiometricaLegada(secureStorage);
    if (!ref.mounted) return;
    final biometricsEnabled =
        await secureStorage.read(key: 'biometrics_enabled') == 'true';
    final biometricCredential = await secureStorage.read(
      key: _biometricCredentialKey,
    );
    if (biometricsEnabled && biometricCredential?.isNotEmpty == true) {
      await secureStorage.delete(key: 'auth_token');
      return;
    }
    if (biometricsEnabled) {
      await secureStorage.delete(key: 'biometrics_enabled');
    }
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
        justLoggedIn: offerBiometrics,
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

  Future<bool> enableBiometricLogin() async {
    _biometricActivationError = null;
    final secureStorage = ref.read(secureStorageProvider);
    await _migrarSenhaBiometricaLegada(secureStorage);
    final token = state.token ?? await secureStorage.read(key: 'auth_token');
    final username =
        state.tempUsername ?? await secureStorage.read(key: 'auth_username');
    final platform = ref.read(devicePlatformResolverProvider).currentPlatform();
    if (token == null ||
        token.isEmpty ||
        username == null ||
        platform == null) {
      _biometricActivationError =
          'A sessão atual não possui os dados necessários para habilitar a biometria.';
      return false;
    }
    try {
      final deviceId = await ref
          .read(deviceRegistrationStoreProvider)
          .getOrCreateInstallationId();
      final response = await ref
          .read(biometricAuthRepositoryProvider)
          .activate(token: token, deviceId: deviceId, platform: platform);
      if (response.credential.isEmpty) {
        _biometricActivationError =
            'O servidor não retornou a credencial biométrica.';
        return false;
      }
      await secureStorage.write(
        key: _biometricCredentialKey,
        value: response.credential,
      );
      await secureStorage.write(key: _biometricUsernameKey, value: username);
      await secureStorage.write(key: 'biometrics_enabled', value: 'true');
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      _biometricActivationError = status == null
          ? 'Não foi possível conectar ao serviço de biometria.'
          : 'O serviço recusou a habilitação da biometria (HTTP $status).';
      return false;
    } catch (_) {
      _biometricActivationError =
          'Ocorreu uma falha ao armazenar a credencial biométrica.';
      return false;
    }
    await secureStorage.write(key: biometricPromptStorageKey, value: 'true');
    state = state.copyWith(justLoggedIn: false, clearTempCredentials: true);
    return true;
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
      await secureStorage.delete(key: _biometricCredentialKey);
      await secureStorage.delete(key: _biometricUsernameKey);
      await secureStorage.delete(key: 'biometrics_enabled');
      await secureStorage.delete(key: 'biometrics_asked');
      await secureStorage.delete(key: biometricPromptStorageKey);
    }

    if (savedUsername != null && savedUsername != username) {
      await secureStorage.delete(key: 'saved_username');
      await secureStorage.delete(key: _biometricCredentialKey);
      await secureStorage.delete(key: _biometricUsernameKey);
      await secureStorage.delete(key: 'biometrics_enabled');
      await secureStorage.delete(key: 'biometrics_asked');
      await secureStorage.delete(key: biometricPromptStorageKey);
    }
  }

  Future<void> dismissBiometricPrompt() async {
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.write(key: biometricPromptStorageKey, value: 'true');
    state = state.copyWith(justLoggedIn: false, clearTempCredentials: true);
  }

  Future<void> offerBiometricSetupOnNextLogin() async {
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.delete(key: biometricPromptStorageKey);
  }

  Future<bool> hasAvailableBiometricCredentials() async {
    final secureStorage = ref.read(secureStorageProvider);
    await _migrarSenhaBiometricaLegada(secureStorage);
    final credential = await secureStorage.read(key: _biometricCredentialKey);
    return credential != null && credential.isNotEmpty;
  }

  Future<bool> enableBiometricLoginFromAvailableCredentials() async {
    return enableBiometricLogin();
  }

  Future<bool> enableBiometricLoginForCurrentUser(String password) async {
    return enableBiometricLogin();
  }

  Future<void> disableBiometricLogin() async {
    final secureStorage = ref.read(secureStorageProvider);
    final token = state.token ?? await secureStorage.read(key: 'auth_token');
    final deviceId = await ref
        .read(deviceRegistrationStoreProvider)
        .readInstallationId();
    if (token != null && deviceId != null) {
      try {
        await ref
            .read(biometricAuthRepositoryProvider)
            .revoke(token: token, deviceId: deviceId);
      } on DioException {
        // A limpeza local não pode depender da disponibilidade da rede.
      }
    }
    await secureStorage.delete(key: 'saved_password');
    await secureStorage.delete(key: 'saved_username');
    await secureStorage.delete(key: _biometricCredentialKey);
    await secureStorage.delete(key: _biometricUsernameKey);
    await secureStorage.delete(key: 'biometrics_enabled');
    await secureStorage.write(key: biometricPromptStorageKey, value: 'true');
    state = state.copyWith(justLoggedIn: false, clearTempCredentials: true);
  }

  Future<bool> loginWithSavedCredentials() async {
    final secureStorage = ref.read(secureStorageProvider);
    await _migrarSenhaBiometricaLegada(secureStorage);
    final credential = await secureStorage.read(key: _biometricCredentialKey);
    final username = await secureStorage.read(key: _biometricUsernameKey);
    if (credential == null || credential.isEmpty || username == null) {
      return false;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await ref
          .read(biometricAuthRepositoryProvider)
          .authenticate(credential: credential);
      if (response.token.isEmpty) {
        await _limparCredencialBiometricaLocal(secureStorage);
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Credencial biométrica inválida.',
        );
        return false;
      }
      await secureStorage.write(key: 'auth_token', value: response.token);
      await secureStorage.write(key: 'auth_username', value: username);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        token: response.token,
        justLoggedIn: false,
        clearTempCredentials: true,
      );
      await _registrarDispositivoAutenticado(response.token);
      return true;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final invalidCredential =
          statusCode == 400 ||
          statusCode == 401 ||
          statusCode == 403 ||
          statusCode == 404;
      if (invalidCredential) {
        await _limparCredencialBiometricaLocal(secureStorage);
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: invalidCredential
            ? 'Credencial biométrica expirada ou revogada. Entre com sua senha.'
            : 'Serviço indisponível. Tente novamente.',
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Não foi possível concluir o acesso biométrico.',
      );
      return false;
    }
  }

  Future<void> _limparCredencialBiometricaLocal(
    FlutterSecureStorage secureStorage,
  ) async {
    await secureStorage.delete(key: _biometricCredentialKey);
    await secureStorage.delete(key: _biometricUsernameKey);
    await secureStorage.delete(key: 'biometrics_enabled');
    await secureStorage.delete(key: 'auth_token');
    await secureStorage.delete(key: biometricPromptStorageKey);
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
    // A tela de login aberta por um logout voluntario nao deve autenticar de
    // novo automaticamente. O botao de acesso seguro continua disponivel.
    await secureStorage.write(
      key: skipLocalAuthAutoPromptOnceStorageKey,
      value: 'true',
    );

    // Logout encerra somente a sessao atual. A credencial biometrica revogavel
    // deve permanecer no armazenamento seguro para permitir o proximo acesso.
    // A revogacao ocorre exclusivamente na acao "Desativar biometria".
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
    await secureStorage.delete(key: 'biometrics_asked');
    await secureStorage.delete(key: biometricPromptStorageKey);
  }

  Future<void> _registrarDispositivoAutenticado(String token) async {
    final manager = ref.read(deviceRegistrationManagerProvider);
    manager.startTokenRefreshListener(() => state.token);
    await manager.registrarSeAutenticado(token);
  }

  Future<void> refreshPushRegistration() async {
    final token = state.token;
    if (token == null || token.isEmpty) return;
    await _registrarDispositivoAutenticado(token);
  }
}

// O provider exposto
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
