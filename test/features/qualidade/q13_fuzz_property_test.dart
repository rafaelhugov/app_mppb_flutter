import 'dart:convert';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_mppb_flutter/features/carteira/models/usuario_carteira.dart';
import 'package:app_mppb_flutter/features/perfil/models/perfil_usuario.dart';
import 'package:app_mppb_flutter/features/noticias/models/noticia.dart';
import 'package:app_mppb_flutter/features/noticias/providers/noticia_provider.dart';
import 'package:app_mppb_flutter/features/ouvidoria/utils/input_formatters.dart';
import 'package:app_mppb_flutter/features/ouvidoria/providers/ouvidoria_provider.dart';
import 'package:app_mppb_flutter/features/contatos/servicos/servico_links_externos.dart';
import 'package:app_mppb_flutter/core/session/session_reset_provider.dart';
import 'package:app_mppb_flutter/features/auth/providers/auth_provider.dart';
import 'package:app_mppb_flutter/features/carteira/providers/carteira_provider.dart';
import 'package:app_mppb_flutter/features/contra_cheque/providers/contra_cheque_provider.dart';
import 'package:app_mppb_flutter/features/pagamentos/providers/pagamentos_provider.dart';
import 'package:app_mppb_flutter/core/notifications/device_registration_provider.dart';
import 'package:app_mppb_flutter/core/network/api_client.dart';
import '../../helpers/fake_dio.dart';

void main() {
  const int kFixedSeed = 130013;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('Q13 — Property-Based Testing (Flutter)', () {
    test('P01: Roundtrip de Serialização/Desserialização (UsuarioCarteira e PerfilUsuario)', () {
      final rng = Random(kFixedSeed);
      int successfulRoundtrips = 0;

      for (int i = 0; i < 500; i++) {
        final matriculaVal = (100000 + rng.nextInt(900000)).toString();
        final cpfVal = '${rng.nextInt(900) + 100}.${rng.nextInt(900) + 100}.${rng.nextInt(900) + 100}-${rng.nextInt(90) + 10}';
        final nomeVal = 'Servidor Teste $i #${rng.nextInt(10000)}';
        final cargoVal = i % 2 == 0 ? 'Promotor de Justiça' : 'Técnico Ministerial';

        // 1. UsuarioCarteira roundtrip
        final carteiraOriginal = UsuarioCarteira(
          matricula: matriculaVal,
          cpf: cpfVal,
          nome: nomeVal,
          cargo: cargoVal,
          rg: 'RG-$i',
          orgaoExp: 'SSP/PB',
          nascimento: '15/05/1985',
        );

        final carteiraJson = carteiraOriginal.toJson();
        final carteiraRestaurada = UsuarioCarteira.fromJson(carteiraJson);

        expect(carteiraRestaurada.matricula, carteiraOriginal.matricula);
        expect(carteiraRestaurada.cpf, carteiraOriginal.cpf);
        expect(carteiraRestaurada.nome, carteiraOriginal.nome);
        expect(carteiraRestaurada.cargo, carteiraOriginal.cargo);
        expect(carteiraRestaurada.rg, carteiraOriginal.rg);

        // 2. PerfilUsuario roundtrip
        final perfilOriginal = PerfilUsuario(
          matricula: matriculaVal,
          nome: nomeVal,
          cargo: cargoVal,
          email: 'usuario$i@mppb.mp.br',
          telefone: '(83) 98888-${1000 + (i % 8999)}',
          setorNome: 'Promotoria de João Pessoa',
          setorSigla: 'PJ-JP',
        );

        final perfilJson = perfilOriginal.toJson();
        final perfilRestaurada = PerfilUsuario.fromJson(perfilJson);

        expect(perfilRestaurada.matricula, perfilOriginal.matricula);
        expect(perfilRestaurada.nome, perfilOriginal.nome);
        expect(perfilRestaurada.cargo, perfilOriginal.cargo);
        expect(perfilRestaurada.email, perfilOriginal.email);
        expect(perfilRestaurada.setorSigla, perfilOriginal.setorSigla);

        successfulRoundtrips++;
      }

      expect(successfulRoundtrips, 500);
    });

    test('P02: Validações e Formatters com Entradas Variadas (Ausência de Exceções)', () {
      final rng = Random(kFixedSeed + 1);
      final cpfFormatter = CpfCnpjInputFormatter();
      final telFormatter = TelefoneInputFormatter();

      final baseStrings = [
        '',
        '   ',
        'abc',
        '123',
        '12345678901',
        '12345678000199',
        '83988887777',
        'test@mppb.mp.br',
        '!@#\$%^&*()',
        'áéíóú çãõ',
        '🎉📱🛡️',
        '123.456.789-00',
        '(83) 98888-7777',
      ];

      for (int i = 0; i < 500; i++) {
        final sb = StringBuffer();
        final partsCount = rng.nextInt(5) + 1;
        for (int p = 0; p < partsCount; p++) {
          sb.write(baseStrings[rng.nextInt(baseStrings.length)]);
          if (rng.nextBool()) {
            sb.write(rng.nextInt(10000));
          }
        }
        final candidate = sb.toString();

        final oldVal = const TextEditingValue();
        final newVal = TextEditingValue(text: candidate);

        final resCpf = cpfFormatter.formatEditUpdate(oldVal, newVal);
        expect(resCpf.text, isNotNull);
        expect(resCpf.selection.baseOffset, resCpf.text.length);

        final resTel = telFormatter.formatEditUpdate(oldVal, newVal);
        expect(resTel.text, isNotNull);
        expect(resTel.selection.baseOffset, resTel.text.length);
      }
    });

    test('P03: Invariantes do Validador de CPF (500 Casos Determinísticos)', () async {
      final rng = Random(kFixedSeed + 2);
      final container = ProviderContainer();
      final notifier = container.read(ouvidoriaProvider.notifier);

      // Aguarda microtask inicial de combos finalizar
      await Future.delayed(const Duration(milliseconds: 50));

      String gerarCpfValido(Random r) {
        final d = List.generate(9, (_) => r.nextInt(10));
        int s1 = 0;
        for (int i = 0; i < 9; i++) {
          s1 += d[i] * (10 - i);
        }
        int d1 = 11 - (s1 % 11);
        if (d1 >= 10) d1 = 0;
        d.add(d1);

        int s2 = 0;
        for (int i = 0; i < 10; i++) {
          s2 += d[i] * (11 - i);
        }
        int d2 = 11 - (s2 % 11);
        if (d2 >= 10) d2 = 0;
        d.add(d2);

        return d.join('');
      }

      int validAccepted = 0;
      int invalidRejected = 0;

      for (int i = 0; i < 500; i++) {
        final cpfValido = gerarCpfValido(rng);

        notifier.updateField((m) {
          m.anonimo = false;
          m.tipoRemetente = 'F';
          m.cpfCnpj = cpfValido;
          m.nome = 'Cidadão Válido $i';
        });

        final errValido = notifier.nextStep();
        expect(errValido, isNull, reason: 'CPF válido $cpfValido foi rejeitado');
        validAccepted++;

        notifier.previousStep();

        final ultDigito = int.parse(cpfValido[10]);
        final digitoInvalido = (ultDigito + 1 + rng.nextInt(8)) % 10;
        final cpfCorrompido = '${cpfValido.substring(0, 10)}$digitoInvalido';

        notifier.updateField((m) {
          m.cpfCnpj = cpfCorrompido;
        });

        final errInvalido = notifier.nextStep();
        expect(errInvalido, 'O CPF informado é inválido.',
            reason: 'CPF adulterado $cpfCorrompido não foi rejeitado');
        invalidRejected++;
      }

      for (int d = 0; d <= 9; d++) {
        final repetido = '$d' * 11;
        notifier.updateField((m) {
          m.cpfCnpj = repetido;
        });
        final errRepetido = notifier.nextStep();
        expect(errRepetido, 'O CPF informado é inválido.',
            reason: 'CPF de dígitos repetidos $repetido deveria ser inválido');
      }

      expect(validAccepted, 500);
      expect(invalidRejected, 500);

      container.dispose();
    });

    test('P04: Invariantes do Formatador de Telefone (TelefoneInputFormatter)', () {
      final rng = Random(kFixedSeed + 3);
      final formatter = TelefoneInputFormatter();
      final regex11 = RegExp(r'^\(\d{2}\) \d{5}-\d{4}$');
      final regex10 = RegExp(r'^\(\d{2}\) \d{4}-\d{4}$');

      for (int i = 0; i < 500; i++) {
        final d11 = List.generate(11, (_) => rng.nextInt(10)).join('');
        final res11 = formatter.formatEditUpdate(
          const TextEditingValue(),
          TextEditingValue(text: d11),
        );
        expect(regex11.hasMatch(res11.text), isTrue,
            reason: '11 dígitos deve gerar formato (XX) XXXXX-XXXX: ${res11.text}');

        final d10 = List.generate(10, (_) => rng.nextInt(10)).join('');
        final res10 = formatter.formatEditUpdate(
          const TextEditingValue(),
          TextEditingValue(text: d10),
        );
        expect(regex10.hasMatch(res10.text), isTrue,
            reason: '10 dígitos deve gerar formato (XX) XXXX-XXXX: ${res10.text}');

        final digitsOut = res11.text.replaceAll(RegExp(r'\D'), '');
        expect(digitsOut, d11);
      }
    });

    test('P05: Invariantes de URI de E-mail (ServicoLinksExternos)', () {
      final rng = Random(kFixedSeed + 4);
      final validChars = 'abcdefghijklmnopqrstuvwxyz0123456789._-';

      for (int i = 0; i < 200; i++) {
        final userLen = rng.nextInt(15) + 3;
        final domainLen = rng.nextInt(10) + 3;

        final user = List.generate(userLen, (_) => validChars[rng.nextInt(validChars.length)]).join('');
        final domain = List.generate(domainLen, (_) => validChars[rng.nextInt(validChars.length)]).join('');
        final email = '$user@$domain.mppb.mp.br';

        final uri = ServicoLinksExternos.uriEmail(email);
        expect(uri.scheme, 'mailto');
        expect(uri.path, email);
      }
    });

    test('P06: Invariantes de Estado dos Providers (isLoading sempre false ao terminar)', () {
      final stateInit = NoticiaState();
      expect(stateInit.isLoading, isFalse);
      expect(stateInit.totalPages, 1);
      expect(stateInit.paginatedNews, isEmpty);

      final stateError = stateInit.copyWith(
        isLoading: false,
        errorMessage: 'Erro simulado',
      );
      expect(stateError.isLoading, isFalse);
      expect(stateError.errorMessage, isNotNull);

      final stateSuccess = stateError.copyWith(
        isLoading: false,
        errorMessage: null,
        noticias: [
          Noticia(titulo: 'Título 1', resumo: 'Conteúdo 1', dataPublicacao: '01/10/2026'),
        ],
      );
      expect(stateSuccess.isLoading, isFalse);
      expect(stateSuccess.errorMessage, isNull);
      expect(stateSuccess.noticias.length, 1);
      expect(stateSuccess.totalPages, 1);
      expect(stateSuccess.paginatedNews.length, 1);
    });

    test('P07: Invariantes de Sessão Atômica (sessionResetProvider invalida providers no logout)', () async {
      FlutterSecureStorage.setMockInitialValues({
        'auth_token': 'token-ativo-p07',
        'auth_username': 'usuario.p07',
        'carteira_cache_username': 'usuario.p07',
        'carteira_cache_data': '{"nome":"Usuario P07","matricula":"777"}',
      });

      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(
            dioComRotas({
              '/carteiras-funcionais/dados': const FakeDioResponse(200, {
                'nome': 'Usuario P07',
                'matricula': 777,
                'cargo': 'Promotor',
                'md5': 'abc',
              }),
            }, baseUrl: 'https://api.test'),
          ),
          deviceRegistrationManagerProvider.overrideWithValue(_DummyDeviceRegistrationManager()),
          pushTokenProvider.overrideWithValue(const _StaticPushTokenProvider('fcm-token-p07')),
          devicePlatformResolverProvider.overrideWithValue(const _StaticPlatformResolver('ANDROID')),
        ],
      );

      // Inicializa authProvider com a sessão mockada
      container.read(authProvider);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(container.read(authProvider).isAuthenticated, isTrue);

      // Ativar o listener de reset
      container.read(sessionResetProvider);

      // Ler providers para instanciá-los com dados do usuário ativo
      container.read(carteiraProvider);
      container.read(contraChequeProvider);
      container.read(pagamentosProvider);

      // Aguarda provider carregar dados do usuário
      await Future.delayed(const Duration(milliseconds: 150));
      expect(container.read(carteiraProvider).data?.nome, 'Usuario P07');

      // Executar logout no authProvider
      await container.read(authProvider.notifier).logout();

      // Aguarda processamento do reset
      await Future.delayed(const Duration(milliseconds: 50));

      // Invariante: sessão foi invalidada e providers privados foram invalidados para estado limpo
      expect(container.read(authProvider).isAuthenticated, isFalse);
      expect(container.read(authProvider).token, isNull);
      expect(container.read(carteiraProvider).data, isNull, reason: 'Dados da carteira devem ser resetados para null apos logout');

      container.dispose();
      FlutterSecureStorage.setMockInitialValues({});
    });
  });

  group('Q13 — Fuzz Testing (Flutter)', () {
    test('F01: Fuzz de JSON Malformado para Caches Locais (Ausência de Unhandled Crash)', () {
      final malformedPayloads = [
        '',
        '   ',
        '{',
        '{{{{{',
        '}',
        'null',
        '[]',
        '{}',
        '{"nome": 12345, "cpf": true, "matricula": [1, 2, 3]}',
        '{"foto": null, "nome": "", "cargo": null, "md5": 99999}',
        '{"deep": {"nested": {"structure": {"value": "corrupt"}}}}',
        '{"invalid_unicode": "\\uD800\\uD800"}',
        '{"extra_fields": "unexpected", "nome": "Valido", "matricula": "123456"}',
        '{"cpf": "12345678901", "nome": null, "foto": "data:image/png;base64,corrupt==="}',
      ];

      for (final payload in malformedPayloads) {
        try {
          final decoded = jsonDecode(payload);
          if (decoded is Map<String, dynamic>) {
            final carteira = UsuarioCarteira.fromJson(decoded);
            expect(carteira, isA<UsuarioCarteira>());

            final perfil = PerfilUsuario.fromJson(decoded);
            expect(perfil, isA<PerfilUsuario>());
          }
        } catch (e) {
          expect(e, anyOf(isA<FormatException>(), isA<TypeError>()));
        }
      }
    });

    test('F02: Fuzz de Strings Extremas (0, 1, 10, 255, 1024, 4096 caracteres)', () {
      final lengths = [0, 1, 10, 255, 1024, 4096];
      final formatter = CpfCnpjInputFormatter();
      final telFormatter = TelefoneInputFormatter();

      for (final len in lengths) {
        final extremeString = 'A' * len;
        final numString = '9' * len;

        final resCpf = formatter.formatEditUpdate(
          const TextEditingValue(),
          TextEditingValue(text: numString),
        );
        expect(resCpf.text.length, lessThanOrEqualTo(18));

        final resTel = telFormatter.formatEditUpdate(
          const TextEditingValue(),
          TextEditingValue(text: numString),
        );
        expect(resTel.text.length, lessThanOrEqualTo(15));

        final carteira = UsuarioCarteira(nome: extremeString, matricula: numString);
        expect(carteira.nome?.length, len);
        expect(carteira.toJson()['nome'], extremeString);
      }
    });

    test('F03: Fuzz de Unicode, Emojis, RTL e Caracteres de Controle', () {
      final unicodePayloads = [
        'أحمد بن علي (RTL Arabic)',
        'עִבְרִית (RTL Hebrew)',
        '👨‍👩‍👧‍👦 🇧🇷 🏛️ ⚖️ 🔒 ⚠️',
        'Café com Açaí & Pão de Açúcar (Acentos)',
        'Zero-Width:\u200B\u200C\u200D\uFEFFTest',
        'LineBreaks:\n\r\t\u0000\u001F',
        'Combining: e\u0301 a\u0303 c\u0327',
      ];

      for (final str in unicodePayloads) {
        final carteira = UsuarioCarteira(nome: str, cargo: str);
        final map = carteira.toJson();
        final jsonStr = jsonEncode(map);
        final restored = UsuarioCarteira.fromJson(jsonDecode(jsonStr));
        expect(restored.nome, str);

        final state = NoticiaState(
          noticias: [
            Noticia(titulo: str, resumo: 'Resumo', dataPublicacao: '01/10/2026'),
          ],
        );
        final filtered = state.copyWith(searchTerm: str).filteredNews;
        expect(filtered.length, 1);
      }
    });

    test('F04: Fuzz de Números e Limites de Paginação', () async {
      final boundaryNumbers = [-999999, -1, 0, 1, 2, 100, 999999];
      final container = ProviderContainer();
      final notifier = container.read(noticiaProvider.notifier);

      await Future.delayed(const Duration(milliseconds: 50));

      for (final num in boundaryNumbers) {
        // Fuzz de transição de página via notifier
        notifier.setPage(num);
        final state = container.read(noticiaProvider);

        // Invariantes estritas de controle de paginação
        expect(state.currentPage, greaterThanOrEqualTo(1));
        expect(state.currentPage, lessThanOrEqualTo(state.totalPages));
        expect(() => state.paginatedNews, returnsNormally);
      }

      container.dispose();
    });
  });
}

class _DummyDeviceRegistrationManager implements DeviceRegistrationManager {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class _StaticPushTokenProvider implements PushTokenProvider {
  final String? token;
  const _StaticPushTokenProvider(this.token);

  @override
  Stream<String> get tokenRefreshes => const Stream.empty();

  @override
  Future<String?> getToken() async => token;

  @override
  Future<String> requestPermission() async => 'authorized';
}

class _StaticPlatformResolver extends DevicePlatformResolver {
  final String? platform;
  const _StaticPlatformResolver(this.platform);

  @override
  String? currentPlatform() => platform;
}
