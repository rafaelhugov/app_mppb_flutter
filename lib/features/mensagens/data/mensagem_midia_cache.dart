import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'mensagens_repository.dart';

final mensagemMidiaCacheProvider = Provider<MensagemMidiaCache>((ref) {
  return MensagemMidiaCache(ref.read(mensagensRepositoryProvider));
});

class MensagemMidiaCache {
  MensagemMidiaCache(this._repository);

  final MensagensRepository _repository;

  Future<File> baixarParaTemporario({
    required int mensagemId,
    required int anexoId,
    required String nomeArquivo,
  }) async {
    final bytes = await _repository.baixarAnexoBytes(mensagemId, anexoId);
    final nomeSeguro = nomeArquivo.replaceAll(RegExp(r'[^\w.\-]'), '_');
    final dir = Directory('${Directory.systemTemp.path}/mppb_mensagens/$mensagemId');
    await dir.create(recursive: true);
    final arquivo = File('${dir.path}/${anexoId}_$nomeSeguro');
    await arquivo.writeAsBytes(bytes, flush: true);
    return arquivo;
  }

  Future<void> compartilharAnexo({
    required int mensagemId,
    required int anexoId,
    required String nomeArquivo,
  }) async {
    final arquivo = await baixarParaTemporario(
      mensagemId: mensagemId,
      anexoId: anexoId,
      nomeArquivo: nomeArquivo,
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(arquivo.path)],
        text: nomeArquivo,
      ),
    );
  }
}

