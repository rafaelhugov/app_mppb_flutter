import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_storage.dart';

// Definimos o estado da autenticação
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;
  final String? token;
  
  // Para sabermos se o usuário acabou de logar e precisamos oferecer biometria
  final bool justLoggedIn;
  final String? tempUsername;
  final String? tempPassword;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
    this.token,
    this.justLoggedIn = false,
    this.tempUsername,
    this.tempPassword,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? errorMessage,
    String? token,
    bool? justLoggedIn,
    String? tempUsername,
    String? tempPassword,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: errorMessage,
      token: token ?? this.token,
      justLoggedIn: justLoggedIn ?? this.justLoggedIn,
      tempUsername: tempUsername ?? this.tempUsername,
      tempPassword: tempPassword ?? this.tempPassword,
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
    final token = await secureStorage.read(key: 'auth_token');
    
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(isAuthenticated: true, token: token);
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Cria uma instância de Dio específica para Auth, 
      // pois não precisamos dos interceptors normais de requisição autenticada
      final authDio = Dio();
      
      final siglaSistema = Platform.isIOS ? 'IOS' : 'ANDROID'; // Baseado no comportamento do Vue, mas adaptado

      final response = await authDio.post(
        'https://auth-api.mppb.mp.br/acesso/autoriza',
        data: {
          'login': username,
          'senha': password,
          'siglaSistema': 'ANDROID', // O Vue enviou 'ANDROID' fixo, vamos manter compatibilidade
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500, // Permite ler o status 401 sem lançar DioException de imediato
        ),
      );

      if (response.statusCode == 401) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário ou senha inválidos.',
        );
        return false;
      } else if (response.statusCode != 200) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Erro na API de autenticação (Status: ${response.statusCode})',
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
      await secureStorage.write(key: 'auth_token', value: token);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        token: token,
        justLoggedIn: true,
        tempUsername: username,
        tempPassword: password,
      );
      return true;

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Falha na conexão com o servidor.',
      );
      return false;
    }
  }

  Future<void> enableBiometricLogin() async {
    final secureStorage = ref.read(secureStorageProvider);
    if (state.tempUsername != null && state.tempPassword != null) {
      await secureStorage.write(key: 'saved_username', value: state.tempUsername!);
      await secureStorage.write(key: 'saved_password', value: state.tempPassword!);
      await secureStorage.write(key: 'biometrics_enabled', value: 'true');
      await secureStorage.write(key: 'biometrics_asked', value: 'true');
    }
    // Remove as temps após salvar
    state = state.copyWith(justLoggedIn: false, tempUsername: null, tempPassword: null);
  }

  Future<void> dismissBiometricPrompt() async {
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.write(key: 'biometrics_asked', value: 'true');
    state = state.copyWith(justLoggedIn: false, tempUsername: null, tempPassword: null);
  }

  Future<bool> loginWithSavedCredentials() async {
    final secureStorage = ref.read(secureStorageProvider);
    final savedUsername = await secureStorage.read(key: 'saved_username');
    final savedPassword = await secureStorage.read(key: 'saved_password');

    if (savedUsername != null && savedPassword != null) {
      return login(savedUsername, savedPassword);
    }
    return false;
  }

  Future<void> logout() async {
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.delete(key: 'auth_token');
    
    // NOTA: NÃO apagamos saved_username, saved_password nem biometrics_enabled.
    // Isso garante que no próximo acesso a biometria seja pedida.

    state = AuthState(); // Reset state
  }
}

// O provider exposto
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
