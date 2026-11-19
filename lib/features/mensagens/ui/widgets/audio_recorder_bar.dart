import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../../models/mensagem_anexo_model.dart';
import 'audio_player_card.dart';
import 'mensagens_theme.dart';

class AudioRecorderBar extends StatefulWidget {
  const AudioRecorderBar({
    super.key,
    required this.onAudioConfirmado,
    this.ocultarBotaoInicial = false,
  });

  final Future<void> Function(File arquivo, int duracaoSegundos)
      onAudioConfirmado;
  final bool ocultarBotaoInicial;

  @override
  State<AudioRecorderBar> createState() => AudioRecorderBarState();
}

class AudioRecorderBarState extends State<AudioRecorderBar> {
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _timer;
  bool _gravando = false;
  bool _enviando = false;
  int _segundos = 0;
  String? _caminhoGravado;

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> iniciarGravacao() => _iniciarGravacao();

  Future<void> _iniciarGravacao() async {
    try {
      final permitido = await _recorder.hasPermission();
      if (!permitido) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permissão de microfone negada no dispositivo.'),
            ),
          );
        }
        return;
      }

      final dir = Directory('${Directory.systemTemp.path}/mppb_audio_rec');
      await dir.create(recursive: true);
      final path =
          '${dir.path}/aviso_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

      setState(() {
        _gravando = true;
        _segundos = 0;
        _caminhoGravado = null;
      });

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _segundos++);
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível iniciar a gravação.')),
        );
      }
    }
  }

  Future<void> _pararGravacao({bool descartar = false}) async {
    _timer?.cancel();
    try {
      final path = await _recorder.stop();
      if (!mounted) return;
      if (descartar || path == null) {
        setState(() {
          _gravando = false;
          _segundos = 0;
          _caminhoGravado = null;
        });
      } else {
        setState(() {
          _gravando = false;
          _caminhoGravado = path;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _gravando = false);
    }
  }

  Future<void> _confirmarEnvioAudio() async {
    final path = _caminhoGravado;
    if (path == null) return;
    setState(() => _enviando = true);
    try {
      await widget.onAudioConfirmado(File(path), _segundos > 0 ? _segundos : 1);
      if (mounted) {
        setState(() {
          _caminhoGravado = null;
          _segundos = 0;
          _enviando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _enviando = false);
    }
  }

  String _formatarTempo(int seg) {
    final m = (seg ~/ 60).toString().padLeft(2, '0');
    final s = (seg % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_caminhoGravado != null) {
      final previewAnexo = MensagemAnexoModel(
        id: 0,
        categoria: CategoriaAnexo.audio,
        nomeOriginal: 'aviso_voz.m4a',
        mimeType: 'audio/mp4',
        tamanhoBytes: File(_caminhoGravado!).existsSync()
            ? File(_caminhoGravado!).lengthSync()
            : 0,
        duracaoSegundos: _segundos,
      );

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: MensagensColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: MensagensColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pré-visualização do aviso em áudio',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                color: MensagensColors.ink,
              ),
            ),
            AudioPlayerCard(
              mensagemId: 0,
              anexo: previewAnexo,
              localFilePath: _caminhoGravado,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: MensagensColors.red,
                      side: BorderSide(
                        color: MensagensColors.red.withValues(alpha: 0.35),
                      ),
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _enviando
                        ? null
                        : () => setState(() {
                            _caminhoGravado = null;
                            _segundos = 0;
                          }),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text(
                      'Descartar',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MensagensColors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _enviando ? null : _confirmarEnvioAudio,
                    icon: _enviando
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: const Text(
                      'Anexar áudio',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (_gravando) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: MensagensColors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: MensagensColors.red.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.fiber_manual_record,
              color: MensagensColors.red,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Gravando ${_formatarTempo(_segundos)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: MensagensColors.red,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Cancelar gravação',
              onPressed: () => _pararGravacao(descartar: true),
              icon: const Icon(
                Icons.delete_outline,
                color: MensagensColors.red,
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: MensagensColors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _pararGravacao(descartar: false),
              icon: const Icon(Icons.stop_rounded, size: 18),
              label: const Text(
                'Concluir',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.ocultarBotaoInicial) {
      return const SizedBox.shrink();
    }

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        foregroundColor: MensagensColors.green,
        side: const BorderSide(color: MensagensColors.green),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: _iniciarGravacao,
      icon: const Icon(Icons.mic),
      label: const Text(
        'Gravar mensagem de áudio',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
