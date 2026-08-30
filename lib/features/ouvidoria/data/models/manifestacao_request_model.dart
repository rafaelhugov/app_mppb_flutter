import '../../../../models/attachment_model.dart';

class ManifestacaoRequestModel {
  bool anonimo = false;
  
  // Remetente
  String tipoRemetente = 'F'; // 'F' or 'J'
  String? cpfCnpj;
  String? nome;
  String? nomeSocial;
  String? sexo;
  String? endereco;
  String? email;
  String? telefone;

  // Classificacao
  bool sigilo = false;
  String? justificativaSigilo;
  
  int? tipo;
  int? materia;
  int? assunto;
  int? municipio; 
  
  int? origemMunicipio;
  int? origemBairro;

  // Relato
  String texto = '';

  // Anexos
  List<AttachmentModel> anexos = [];

  // Captcha
  String? captchaId;
  String? userEnteredCaptchaCode;

  Map<String, dynamic> toFormDataMap() {
    final map = <String, dynamic>{
      'anonimo': anonimo.toString(),
      'sigilo': sigilo.toString(),
      'texto': texto,
    };

    if (!anonimo) {
      map['remetente.tipo'] = tipoRemetente;
      if (cpfCnpj != null) map['remetente.cpfCnpj'] = cpfCnpj;
      if (nome != null) map['remetente.nome'] = nome;
      if (nomeSocial != null && nomeSocial!.isNotEmpty) map['remetente.nomeSocial'] = nomeSocial;
      if (sexo != null && tipoRemetente == 'F') map['remetente.sexo'] = sexo;
      if (endereco != null) map['remetente.endereco'] = endereco;
      if (email != null) map['remetente.email'] = email;
      if (telefone != null) map['remetente.telefone'] = telefone;
    }

    if (sigilo && justificativaSigilo != null) {
      map['justificativaSigilo'] = justificativaSigilo;
    }

    if (tipo != null) map['tipo'] = tipo.toString();
    if (materia != null) map['materia'] = materia.toString();
    if (assunto != null) map['assunto'] = assunto.toString();
    if (municipio != null) map['municipio'] = municipio.toString();
    
    if (!sigilo) {
      if (origemMunicipio != null) map['origemMunicipio'] = origemMunicipio.toString();
      if (origemBairro != null) map['origemBairro'] = origemBairro.toString();
    }

    if (captchaId != null) map['captcha.captchaId'] = captchaId;
    if (userEnteredCaptchaCode != null) map['captcha.userEnteredCaptchaCode'] = userEnteredCaptchaCode;

    return map;
  }
}
