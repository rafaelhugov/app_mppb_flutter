import 'package:flutter/material.dart';

import 'mensagens_theme.dart';

/// Controller de texto que aplica formatação visual imediata (negrito, itálico,
/// tachado, links e marcadores de lista) no próprio `TextField`, ocultando
/// visualmente os tokens Markdown sem alterar os índices de cursor/seleção.
class RichMarkdownEditingController extends TextEditingController {
  RichMarkdownEditingController({super.text});

  static final RegExp _tokenRegex = RegExp(
    r'(\*\*(.+?)\*\*)|(~~(.+?)~~)|(\*(.+?)\*)|(\[([^\]]+)\]\(([^)]+)\))',
    dotAll: true,
  );

  static const TextStyle _hiddenMarkerStyle = TextStyle(
    fontSize: 0.01,
    color: Colors.transparent,
  );

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final baseStyle = style ?? const TextStyle();
    final children = <InlineSpan>[];

    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.startsWith('- ')) {
        children.add(
          TextSpan(
            text: '- ',
            style: baseStyle.copyWith(
              color: MensagensColors.green,
              fontWeight: FontWeight.w900,
            ),
          ),
        );
        children.addAll(_parseInline(line.substring(2), baseStyle));
      } else {
        children.addAll(_parseInline(line, baseStyle));
      }
      if (i < lines.length - 1) {
        children.add(TextSpan(text: '\n', style: baseStyle));
      }
    }

    return TextSpan(style: baseStyle, children: children);
  }

  List<InlineSpan> _parseInline(String input, TextStyle baseStyle) {
    if (input.isEmpty) return const [];
    final spans = <InlineSpan>[];
    var currentIndex = 0;

    for (final match in _tokenRegex.allMatches(input)) {
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: input.substring(currentIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      if (match.group(1) != null) {
        // Negrito: **conteudo**
        final inner = match.group(2) ?? '';
        spans.add(const TextSpan(text: '**', style: _hiddenMarkerStyle));
        spans.addAll(
          _parseInline(
            inner,
            baseStyle.copyWith(fontWeight: FontWeight.w800),
          ),
        );
        spans.add(const TextSpan(text: '**', style: _hiddenMarkerStyle));
      } else if (match.group(3) != null) {
        // Tachado: ~~conteudo~~
        final inner = match.group(4) ?? '';
        spans.add(const TextSpan(text: '~~', style: _hiddenMarkerStyle));
        spans.addAll(
          _parseInline(
            inner,
            baseStyle.copyWith(
              decoration: _combineDecoration(
                baseStyle.decoration,
                TextDecoration.lineThrough,
              ),
            ),
          ),
        );
        spans.add(const TextSpan(text: '~~', style: _hiddenMarkerStyle));
      } else if (match.group(5) != null) {
        // Itálico: *conteudo*
        final inner = match.group(6) ?? '';
        spans.add(const TextSpan(text: '*', style: _hiddenMarkerStyle));
        spans.addAll(
          _parseInline(
            inner,
            baseStyle.copyWith(fontStyle: FontStyle.italic),
          ),
        );
        spans.add(const TextSpan(text: '*', style: _hiddenMarkerStyle));
      } else if (match.group(7) != null) {
        // Link: [titulo](url)
        final label = match.group(8) ?? '';
        final url = match.group(9) ?? '';
        spans.add(const TextSpan(text: '[', style: _hiddenMarkerStyle));
        spans.add(
          TextSpan(
            text: label,
            style: baseStyle.copyWith(
              color: MensagensColors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        );
        spans.add(TextSpan(text: ']($url)', style: _hiddenMarkerStyle));
      }

      currentIndex = match.end;
    }

    if (currentIndex < input.length) {
      spans.add(
        TextSpan(text: input.substring(currentIndex), style: baseStyle),
      );
    }

    return spans;
  }

  TextDecoration _combineDecoration(TextDecoration? a, TextDecoration b) {
    if (a == null || a == TextDecoration.none) return b;
    return TextDecoration.combine([a, b]);
  }

  bool estaEnvolvido(String token) {
    final sel = selection;
    if (!sel.isValid) return false;
    final start = sel.start;
    final end = sel.end;
    final len = token.length;
    if (start >= len && end + len <= text.length) {
      final before = text.substring(start - len, start);
      final after = text.substring(end, end + len);
      if (before == token && after == token) return true;
    }
    return false;
  }

  /// Aplica ou remove formatação envolvendo a seleção atual (ou criando
  /// envoltório vazio no cursor para digitação já formatada).
  String alternarEnvoltorio(String token) {
    final sel = selection;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    final len = token.length;

    if (start >= len && end + len <= text.length) {
      final before = text.substring(start - len, start);
      final after = text.substring(end, end + len);
      if (before == token && after == token) {
        final selecionado = text.substring(start, end);
        final novoTexto = text.replaceRange(start - len, end + len, selecionado);
        value = TextEditingValue(
          text: novoTexto,
          selection: TextSelection(
            baseOffset: start - len,
            extentOffset: start - len + selecionado.length,
          ),
        );
        return novoTexto;
      }
    }

    final selecionado = start < end ? text.substring(start, end) : '';
    final inserido = '$token$selecionado$token';
    final novoTexto = text.replaceRange(start, end, inserido);
    value = TextEditingValue(
      text: novoTexto,
      selection: TextSelection(
        baseOffset: start + len,
        extentOffset: start + len + selecionado.length,
      ),
    );
    return novoTexto;
  }

  /// Alterna marcador de tópico (`- `) no início da linha atual.
  String alternarListaLinha() {
    final sel = selection;
    final pos = sel.isValid ? sel.start : text.length;
    final before = text.substring(0, pos);
    final lineStart = before.lastIndexOf('\n') + 1;
    final restOfLine = text.substring(lineStart);

    if (restOfLine.startsWith('- ')) {
      final novoTexto = text.replaceRange(lineStart, lineStart + 2, '');
      final novaPos = (pos - 2).clamp(lineStart, novoTexto.length);
      value = TextEditingValue(
        text: novoTexto,
        selection: TextSelection.collapsed(offset: novaPos),
      );
      return novoTexto;
    }

    final novoTexto = text.replaceRange(lineStart, lineStart, '- ');
    value = TextEditingValue(
      text: novoTexto,
      selection: TextSelection.collapsed(offset: pos + 2),
    );
    return novoTexto;
  }

  /// Insere estrutura de link mantendo o rótulo selecionado para edição.
  String inserirLink() {
    final sel = selection;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    final label = start < end ? text.substring(start, end) : 'link';
    final inserido = '[$label](https://)';
    final novoTexto = text.replaceRange(start, end, inserido);
    value = TextEditingValue(
      text: novoTexto,
      selection: TextSelection(
        baseOffset: start + label.length + 3,
        extentOffset: start + inserido.length - 1,
      ),
    );
    return novoTexto;
  }
}
