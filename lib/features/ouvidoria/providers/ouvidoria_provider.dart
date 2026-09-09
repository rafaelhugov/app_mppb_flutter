import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/manifestacao_request_model.dart';
import '../data/models/combo_models.dart';
import '../data/repositories/ouvidoria_repository.dart';
import '../../../../services/captcha_service.dart';
import '../../../../services/upload_service.dart';
import '../../../../models/attachment_model.dart';

final ouvidoriaProvider = NotifierProvider<OuvidoriaNotifier, OuvidoriaState>(
  OuvidoriaNotifier.new,
);

class OuvidoriaState {
  final int currentStep;
  final ManifestacaoRequestModel requestModel;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final double uploadProgress;

  final List<ComboItem> tipos;
  final List<ComboItem> materias;
  final List<ComboItem> assuntos;
  final List<ComboItem> municipios;
  final List<ComboItem> bairros;

  final CaptchaData? captchaData;

  OuvidoriaState({
    required this.currentStep,
    required this.requestModel,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.uploadProgress = 0.0,
    this.tipos = const [],
    this.materias = const [],
    this.assuntos = const [],
    this.municipios = const [],
    this.bairros = const [],
    this.captchaData,
  });

  OuvidoriaState copyWith({
    int? currentStep,
    ManifestacaoRequestModel? requestModel,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    double? uploadProgress,
    List<ComboItem>? tipos,
    List<ComboItem>? materias,
    List<ComboItem>? assuntos,
    List<ComboItem>? municipios,
    List<ComboItem>? bairros,
    CaptchaData? captchaData,
  }) {
    return OuvidoriaState(
      currentStep: currentStep ?? this.currentStep,
      requestModel: requestModel ?? this.requestModel,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage, // can be null
      uploadProgress: uploadProgress ?? this.uploadProgress,
      tipos: tipos ?? this.tipos,
      materias: materias ?? this.materias,
      assuntos: assuntos ?? this.assuntos,
      municipios: municipios ?? this.municipios,
      bairros: bairros ?? this.bairros,
      captchaData: captchaData ?? this.captchaData,
    );
  }
}

class OuvidoriaNotifier extends Notifier<OuvidoriaState> {
  late final OuvidoriaRepository _repository;
  late final CaptchaService _captchaService;
  late final UploadService _uploadService;

  @override
  OuvidoriaState build() {
    _repository = OuvidoriaRepository();
    _captchaService = CaptchaService();
    _uploadService = UploadService();

    Future.microtask(_initCombos);

    return OuvidoriaState(
      currentStep: 0,
      requestModel: ManifestacaoRequestModel(),
    );
  }

  Future<void> _initCombos() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final tipos = await _repository.fetchTipos();
      final materias = [
        ComboItem(id: 1, descricao: 'Ouvidoria'),
        ComboItem(id: 2, descricao: 'Ouvidoria das Mulheres'),
      ];
      final municipios = await _repository.fetchMunicipios();

      state = state.copyWith(
        tipos: tipos,
        materias: materias,
        municipios: municipios,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar dados iniciais.',
      );
    }
  }

  Future<void> recarregarDadosIniciais() => _initCombos();

  Future<void> loadAssuntos(int? materiaId) async {
    state.requestModel.assunto = null;
    if (materiaId == null) {
      state = state.copyWith(assuntos: [], requestModel: state.requestModel);
      return;
    }
    state = state.copyWith(
      isLoading: true,
      assuntos: [],
      requestModel: state.requestModel,
    );
    try {
      final assuntos = await _repository.fetchAssuntos(materiaId);
      state = state.copyWith(assuntos: assuntos, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar assuntos.',
      );
    }
  }

  Future<void> loadBairros(int? municipioId) async {
    state.requestModel.origemBairro = null;
    if (municipioId == null) {
      state = state.copyWith(bairros: [], requestModel: state.requestModel);
      return;
    }
    state = state.copyWith(
      isLoading: true,
      bairros: [],
      requestModel: state.requestModel,
    );
    try {
      final bairros = await _repository.fetchBairros(municipioId);
      state = state.copyWith(bairros: bairros, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar bairros.',
      );
    }
  }

  Future<void> loadCaptcha() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final captchaData = await _captchaService.fetchCaptcha();
      state.requestModel.captchaId = captchaData.captchaId;
      state = state.copyWith(captchaData: captchaData, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar Captcha.',
      );
    }
  }

  String? nextStep() {
    final model = state.requestModel;
    if (state.currentStep == 0) {
      if (!model.anonimo) {
        if (model.cpfCnpj == null || model.cpfCnpj!.isEmpty) {
          return 'O CPF/CNPJ é obrigatório.';
        }
        if (model.tipoRemetente == 'F' && !_isValidCPF(model.cpfCnpj!)) {
          return 'O CPF informado é inválido.';
        }
        if (model.tipoRemetente == 'J' && !_isValidCNPJ(model.cpfCnpj!)) {
          return 'O CNPJ informado é inválido.';
        }
        if (model.nome == null || model.nome!.isEmpty) {
          return 'O Nome é obrigatório.';
        }
      }
    } else if (state.currentStep == 1) {
      if (!model.sigilo) {
        if (model.origemMunicipio == null) {
          return 'O Município de Origem é obrigatório.';
        }
        if (model.origemBairro == null) {
          return 'O Bairro de Origem é obrigatório.';
        }
      }
      if (model.tipo == null) return 'O Tipo de Manifestação é obrigatório.';
      if (model.materia == null) return 'A Matéria é obrigatória.';
      if (model.assunto == null) return 'O Assunto é obrigatório.';
      if (model.municipio == null) {
        return 'O Município Destinatário é obrigatório.';
      }
    } else if (state.currentStep == 2) {
      if (model.texto.isEmpty) return 'O Relato é obrigatório.';
    }

    if (state.currentStep < 4) {
      final next = state.currentStep + 1;
      state = state.copyWith(currentStep: next);
      if (next == 4) {
        loadCaptcha();
      }
    }
    return null;
  }

  bool _isValidCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'\D'), '');
    if (cpf.length != 11 || RegExp(r'^(\d)\1*$').hasMatch(cpf)) {
      return false;
    }
    List<int> n = cpf.split('').map(int.parse).toList();
    int sum1 = 0, sum2 = 0;
    for (int i = 0; i < 9; i++) {
      sum1 += n[i] * (10 - i);
    }
    int d1 = 11 - (sum1 % 11);
    if (d1 >= 10) d1 = 0;
    if (n[9] != d1) return false;
    for (int i = 0; i < 10; i++) {
      sum2 += n[i] * (11 - i);
    }
    int d2 = 11 - (sum2 % 11);
    if (d2 >= 10) d2 = 0;
    return n[10] == d2;
  }

  bool _isValidCNPJ(String cnpj) {
    cnpj = cnpj.replaceAll(RegExp(r'\D'), '');
    if (cnpj.length != 14 || RegExp(r'^(\d)\1*$').hasMatch(cnpj)) {
      return false;
    }
    List<int> n = cnpj.split('').map(int.parse).toList();
    int sum1 = 0, sum2 = 0;
    List<int> w1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    for (int i = 0; i < 12; i++) {
      sum1 += n[i] * w1[i];
    }
    int d1 = 11 - (sum1 % 11);
    if (d1 >= 10) d1 = 0;
    if (n[12] != d1) return false;
    List<int> w2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    for (int i = 0; i < 13; i++) {
      sum2 += n[i] * w2[i];
    }
    int d2 = 11 - (sum2 % 11);
    if (d2 >= 10) d2 = 0;
    return n[13] == d2;
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void updateField(void Function(ManifestacaoRequestModel model) updateLogic) {
    updateLogic(state.requestModel);
    state = state.copyWith(requestModel: state.requestModel); // force update
  }

  void addAttachment(AttachmentModel file) {
    if (state.requestModel.anexos.length < 4) {
      state.requestModel.anexos.add(file);
      state = state.copyWith(requestModel: state.requestModel);
    } else {
      state = state.copyWith(errorMessage: 'Limite de 4 arquivos atingido.');
    }
  }

  void removeAttachment(AttachmentModel file) {
    state.requestModel.anexos.remove(file);
    state = state.copyWith(requestModel: state.requestModel);
  }

  Future<String?> submit() async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      uploadProgress: 0.0,
    );
    try {
      final protocolo = await _uploadService.enviarManifestacao(
        requestModel: state.requestModel,
        onProgress: (sent, total) {
          if (total > 0) {
            state = state.copyWith(uploadProgress: sent / total);
          }
        },
      );
      state = state.copyWith(isSubmitting: false);
      return protocolo;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
