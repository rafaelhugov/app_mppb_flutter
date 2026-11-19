import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mensagens_repository.dart';
import '../../models/mensagem_aviso_model.dart';
import 'mensagens_theme.dart';

final remetenteFotoProvider = FutureProvider.family<Uint8List?, String>(
  (ref, matricula) async {
    return ref.read(mensagensRepositoryProvider).buscarFotoRemetente(matricula);
  },
);

/// Avatar circular do remetente com foto institucional (quando disponível) e
/// fallback automático para iniciais com destaque por prioridade.
class RemetenteAvatar extends ConsumerWidget {
  const RemetenteAvatar({
    super.key,
    required this.nome,
    this.matricula,
    this.prioridade = PrioridadeMensagem.normal,
    this.size = 50,
    this.darkHeader = false,
  });

  final String nome;
  final String? matricula;
  final PrioridadeMensagem prioridade;
  final double size;
  final bool darkHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mat = matricula?.trim();
    final fotoAsync = (mat != null && mat.isNotEmpty)
        ? ref.watch(remetenteFotoProvider(mat))
        : const AsyncValue<Uint8List?>.data(null);
    final bytes = fotoAsync.asData?.value;

    final (bg, fg) = darkHeader
        ? (
            MensagensColors.green.withValues(alpha: 0.2),
            Colors.white,
          )
        : switch (prioridade) {
            PrioridadeMensagem.urgente => (
              MensagensColors.red.withValues(alpha: 0.12),
              MensagensColors.red,
            ),
            PrioridadeMensagem.importante => (
              MensagensColors.orange.withValues(alpha: 0.12),
              MensagensColors.orange,
            ),
            PrioridadeMensagem.normal => (
              MensagensColors.green.withValues(alpha: 0.12),
              MensagensColors.green,
            ),
          };

    final borderColor = darkHeader
        ? MensagensColors.green.withValues(alpha: 0.6)
        : fg.withValues(alpha: 0.25);
    final iniciais = _extrairIniciais(nome);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: ClipOval(
        child: bytes != null && bytes.isNotEmpty
            ? Image.memory(
                bytes,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildFallback(iniciais, fg),
              )
            : _buildFallback(iniciais, fg),
      ),
    );
  }

  Widget _buildFallback(String? iniciais, Color fg) {
    return Center(
      child: iniciais != null
          ? Text(
              iniciais,
              style: TextStyle(
                fontSize: size * 0.33,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            )
          : Icon(Icons.campaign_rounded, color: fg, size: size * 0.48),
    );
  }

  String? _extrairIniciais(String texto) {
    final partes = texto
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (partes.isEmpty) return null;
    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }
    return (partes.first.substring(0, 1) + partes[1].substring(0, 1))
        .toUpperCase();
  }
}

