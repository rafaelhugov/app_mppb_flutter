import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../data/mensagens_repository.dart';
import '../../models/mensagem_anexo_model.dart';
import 'mensagens_theme.dart';

class AudioPlayerCard extends ConsumerStatefulWidget {
  const AudioPlayerCard({
    super.key,
    required this.mensagemId,
    required this.anexo,
    this.localFilePath,
  });

  final int mensagemId;
  final MensagemAnexoModel anexo;
  final String? localFilePath;

  @override
  ConsumerState<AudioPlayerCard> createState() => _AudioPlayerCardState();
}

class _AudioPlayerCardState extends ConsumerState<AudioPlayerCard> {
  final AudioPlayer _player = AudioPlayer();
  bool _carregado = false;
  bool _carregando = false;
  double _velocidade = 1.0;
  Duration _posicao = Duration.zero;
  Duration _duracaoTotal = Duration.zero;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;
  StreamSubscription<PlayerState>? _stateSub;

  @override
  void initState() {
    super.initState();
    if (widget.anexo.duracaoSegundos != null &&
        widget.anexo.duracaoSegundos! > 0) {
      _duracaoTotal = Duration(seconds: widget.anexo.duracaoSegundos!);
    }
    _posSub = _player.positionStream.listen((pos) {
      if (mounted) setState(() => _posicao = pos);
    });
    _durSub = _player.durationStream.listen((dur) {
      if (mounted && dur != null && dur > Duration.zero) {
        setState(() => _duracaoTotal = dur);
      }
    });
    _stateSub = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _alternarPlayPause() async {
    if (_player.playing) {
      await _player.pause();
      return;
    }
    if (!_carregado) {
      setState(() => _carregando = true);
      try {
        if (widget.localFilePath != null) {
          await _player.setFilePath(widget.localFilePath!);
        } else {
          final repo = ref.read(mensagensRepositoryProvider);
          final token = ref.read(authProvider).token;
          final url = repo.anexoConteudoUrl(widget.mensagemId, widget.anexo.id);
          await _player.setAudioSource(
            AudioSource.uri(
              Uri.parse(url),
              headers: {
                if (token != null && token.isNotEmpty)
                  'Authorization': 'Bearer $token',
              },
            ),
          );
        }
        _carregado = true;
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível reproduzir o áudio.')),
          );
        }
        setState(() => _carregando = false);
        return;
      } finally {
        if (mounted) setState(() => _carregando = false);
      }
    }
    await _player.play();
  }

  Future<void> _alternarVelocidade() async {
    final proxima = _velocidade == 1.0
        ? 1.5
        : (_velocidade == 1.5 ? 2.0 : 1.0);
    setState(() => _velocidade = proxima);
    await _player.setSpeed(proxima);
  }

  String _formatar(Duration d) {
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seg = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$seg';
  }

  @override
  Widget build(BuildContext context) {
    final maxMs = _duracaoTotal.inMilliseconds > 0
        ? _duracaoTotal.inMilliseconds.toDouble()
        : 1.0;
    final atualMs = _posicao.inMilliseconds.clamp(0, maxMs.toInt()).toDouble();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: MensagensColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MensagensColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: _carregando ? null : _alternarPlayPause,
              icon: _carregando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: MensagensColors.green,
                      ),
                    )
                  : Icon(
                      _player.playing
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                      size: 36,
                      color: MensagensColors.green,
                    ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                  ),
                  child: Slider(
                    value: atualMs,
                    max: maxMs,
                    activeColor: MensagensColors.green,
                    inactiveColor: MensagensColors.border,
                    onChanged: _carregado
                        ? (val) => _player.seek(
                            Duration(milliseconds: val.toInt()),
                          )
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatar(_player.playing || _posicao > Duration.zero
                            ? _posicao
                            : _duracaoTotal),
                        style: const TextStyle(
                          fontSize: 11,
                          color: MensagensColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(
                            Icons.mic,
                            size: 13,
                            color: MensagensColors.green,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Mensagem de voz',
                            style: TextStyle(
                              fontSize: 11,
                              color: MensagensColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: _alternarVelocidade,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 36),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: MensagensColors.brandDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_velocidade.toStringAsFixed(_velocidade == _velocidade.roundToDouble() ? 0 : 1)}x',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
