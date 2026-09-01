import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/certidao_extrajudicial.dart';

class CertidaoExtrajudicialState {
  const CertidaoExtrajudicialState({
    this.isLoading = false,
    this.isPdfLoading = false,
    this.errorMessage,
    this.certidao,
    this.pdfBytes,
  });

  final bool isLoading;
  final bool isPdfLoading;
  final String? errorMessage;
  final CertidaoExtrajudicial? certidao;
  final Uint8List? pdfBytes;

  CertidaoExtrajudicialState copyWith({
    bool? isLoading,
    bool? isPdfLoading,
    String? errorMessage,
    CertidaoExtrajudicial? certidao,
    Uint8List? pdfBytes,
    bool clearPdf = false,
  }) {
    return CertidaoExtrajudicialState(
      isLoading: isLoading ?? this.isLoading,
      isPdfLoading: isPdfLoading ?? this.isPdfLoading,
      errorMessage: errorMessage,
      certidao: certidao ?? this.certidao,
      pdfBytes: clearPdf ? null : pdfBytes ?? this.pdfBytes,
    );
  }
}

class CertidaoExtrajudicialNotifier
    extends Notifier<CertidaoExtrajudicialState> {
  static const _basePath = '/api/public/certidoes-extrajudiciais';

  @override
  CertidaoExtrajudicialState build() => const CertidaoExtrajudicialState();

  Future<Uint8List?> emitirPdf({
    required String tipoDocumento,
    required String documento,
    required String nome,
  }) async {
    state = state.copyWith(
      isPdfLoading: true,
      errorMessage: null,
      clearPdf: true,
    );

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post<List<int>>(
        '$_basePath/pdf',
        data: {
          'tipoDocumento': tipoDocumento,
          'documento': _digitsOnly(documento),
          'nome': nome.trim(),
        },
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = Uint8List.fromList(response.data ?? const []);
      state = state.copyWith(isPdfLoading: false, pdfBytes: bytes);
      return bytes;
    } catch (e) {
      state = state.copyWith(
        isPdfLoading: false,
        errorMessage: _formatError(e),
      );
      return null;
    }
  }

  Future<void> consultarCodigo(String codigo) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<Map<String, dynamic>>(
        '$_basePath/codigo/${Uri.encodeComponent(codigo.trim())}',
      );

      state = state.copyWith(
        isLoading: false,
        certidao: CertidaoExtrajudicial.fromJson(response.data ?? const {}),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _formatError(e));
    }
  }

  Future<Uint8List?> baixarPdfPorCodigo(String codigo) async {
    state = state.copyWith(
      isPdfLoading: true,
      errorMessage: null,
      clearPdf: true,
    );

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<List<int>>(
        '$_basePath/codigo/${Uri.encodeComponent(codigo.trim())}/pdf',
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = Uint8List.fromList(response.data ?? const []);
      state = state.copyWith(isPdfLoading: false, pdfBytes: bytes);
      return bytes;
    } catch (e) {
      state = state.copyWith(
        isPdfLoading: false,
        errorMessage: _formatError(e),
      );
      return null;
    }
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  String _formatError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is List && data.isNotEmpty) {
        return data.join('\n');
      }
      if (data is String && data.trim().isNotEmpty) {
        return data.trim();
      }
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return 'Não foi possível comunicar com o serviço de certidão.';
    }
    return 'Não foi possível processar a solicitação.';
  }
}

final certidaoExtrajudicialProvider =
    NotifierProvider<CertidaoExtrajudicialNotifier, CertidaoExtrajudicialState>(
      CertidaoExtrajudicialNotifier.new,
    );
