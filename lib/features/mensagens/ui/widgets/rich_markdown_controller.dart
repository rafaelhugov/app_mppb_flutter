import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'mensagens_theme.dart';

/// Formatter que continua automaticamente listas (`• ` ou `N. `) ao pressionar
/// Enter e encerra a lista quando o usuário pressiona Enter em um item vazio.
class ListContinuationTextInputFormatter extends TextInputFormatter {
  static final RegExp _orderedListRegex = RegExp(r'^(\d+\.\s)(.*)$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final sel = newValue.selection;
    if (!sel.isValid || !sel.isCollapsed) return newValue;

    final pos = sel.start;
    if (pos <= 0 || newValue.text[pos - 1] != '\n') return newValue;

    final oldNewlines = '\n'.allMatches(oldValue.text).length;
    final newNewlines = '\n'.allMatches(newValue.text).length;
    if (newNewlines != oldNewlines + 1) return newValue;

    final beforeNl = newValue.text.substring(0, pos - 1);
    final prevLineStart = beforeNl.lastIndexOf('\n') + 1;
    final prevLine = beforeNl.substring(prevLineStart);

    if (prevLine == '• ' ||
        prevLine == '- ' ||
        prevLine == '•' ||
        prevLine == '-') {
      final limpo = newValue.text.replaceRange(prevLineStart, pos, '');
      return TextEditingValue(
        text: limpo,
        selection: TextSelection.collapsed(offset: prevLineStart),
      );
    }

    if (prevLine.startsWith('• ') || prevLine.startsWith('- ')) {
      final comBullet = newValue.text.replaceRange(pos, pos, '• ');
      return TextEditingValue(
        text: comBullet,
        selection: TextSelection.collapsed(offset: pos + 2),
      );
    }

    final prevOrdered = _orderedListRegex.firstMatch(prevLine);
    if (prevOrdered != null) {
      final conteudoItem = prevOrdered.group(2)!.trim();
      if (conteudoItem.isEmpty) {
        final limpo = newValue.text.replaceRange(prevLineStart, pos, '');
        return TextEditingValue(
          text: limpo,
          selection: TextSelection.collapsed(offset: prevLineStart),
        );
      }
      final numAtual = int.tryParse(
        prevOrdered.group(1)!.replaceAll('.', '').trim(),
      );
      if (numAtual != null) {
        final prox = '${numAtual + 1}. ';
        final comNumero = newValue.text.replaceRange(pos, pos, prox);
        return TextEditingValue(
          text: comNumero,
          selection: TextSelection.collapsed(offset: pos + prox.length),
        );
      }
    }

    return newValue;
  }
}

/// Controller de texto que aplica formatação visual imediata (negrito, itálico,
/// tachado, links, lista com marcadores `•` e lista ordenada `1.`) no próprio
/// `TextField`, ocultando visualmente os tokens Markdown sem alterar índices.
class RichMarkdownEditingController extends TextEditingController {
  RichMarkdownEditingController({super.text});

  static final RegExp _tokenRegex = RegExp(
    r'(\*\*(.+?)\*\*)|(~~(.+?)~~)|(\*(.+?)\*)|(\[([^\]]+)\]\(([^)]+)\))',
    dotAll: true,
  );
  static final RegExp _orderedListRegex = RegExp(r'^(\d+\.\s)(.*)$');

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
      final orderedMatch = _orderedListRegex.firstMatch(line);
      if (line.startsWith('• ') || line.startsWith('- ')) {
        children.add(
          TextSpan(
            text: line.substring(0, 2),
            style: baseStyle.copyWith(
              color: MensagensColors.green,
              fontWeight: FontWeight.w900,
              fontSize: (baseStyle.fontSize ?? 14) + 1,
            ),
          ),
        );
        children.addAll(_parseInline(line.substring(2), baseStyle));
      } else if (orderedMatch != null) {
        final prefix = orderedMatch.group(1)!;
        final rest = orderedMatch.group(2)!;
        children.add(
          TextSpan(
            text: prefix,
            style: baseStyle.copyWith(
              color: MensagensColors.green,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
        children.addAll(_parseInline(rest, baseStyle));
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

  (int lineStart, String lineText) _linhaAtual() {
    final pos = selection.isValid ? selection.start : text.length;
    final before = text.substring(0, pos);
    final lineStart = before.lastIndexOf('\n') + 1;
    final nextNl = text.indexOf('\n', lineStart);
    final lineEnd = nextNl == -1 ? text.length : nextNl;
    return (lineStart, text.substring(lineStart, lineEnd));
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

  bool get estaEmListaMarcadores {
    final (_, line) = _linhaAtual();
    return line.startsWith('• ') || line.startsWith('- ');
  }

  bool get estaEmListaOrdenada {
    final (_, line) = _linhaAtual();
    return _orderedListRegex.hasMatch(line);
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
        return normalizarParaMarkdown();
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
    return normalizarParaMarkdown();
  }

  /// Alterna marcador visual de tópico (`• `) no início da linha atual.
  String alternarListaLinha() {
    final pos = selection.isValid ? selection.start : text.length;
    final (lineStart, line) = _linhaAtual();

    if (line.startsWith('• ') || line.startsWith('- ')) {
      final novoTexto = text.replaceRange(lineStart, lineStart + 2, '');
      final novaPos = (pos - 2).clamp(lineStart, novoTexto.length);
      value = TextEditingValue(
        text: novoTexto,
        selection: TextSelection.collapsed(offset: novaPos),
      );
      return normalizarParaMarkdown();
    }

    final orderedMatch = _orderedListRegex.firstMatch(line);
    if (orderedMatch != null) {
      final oldLen = orderedMatch.group(1)!.length;
      final novoTexto = text.replaceRange(lineStart, lineStart + oldLen, '• ');
      final novaPos = (pos - oldLen + 2).clamp(lineStart, novoTexto.length);
      value = TextEditingValue(
        text: novoTexto,
        selection: TextSelection.collapsed(offset: novaPos),
      );
      return normalizarParaMarkdown();
    }

    final novoTexto = text.replaceRange(lineStart, lineStart, '• ');
    value = TextEditingValue(
      text: novoTexto,
      selection: TextSelection.collapsed(offset: pos + 2),
    );
    return normalizarParaMarkdown();
  }

  /// Alterna lista ordenada (`1. `, `2. `, ...) no início da linha atual.
  String alternarListaOrdenadaLinha() {
    final pos = selection.isValid ? selection.start : text.length;
    final (lineStart, line) = _linhaAtual();

    final orderedMatch = _orderedListRegex.firstMatch(line);
    if (orderedMatch != null) {
      final oldLen = orderedMatch.group(1)!.length;
      final novoTexto = text.replaceRange(lineStart, lineStart + oldLen, '');
      final novaPos = (pos - oldLen).clamp(lineStart, novoTexto.length);
      value = TextEditingValue(
        text: novoTexto,
        selection: TextSelection.collapsed(offset: novaPos),
      );
      return normalizarParaMarkdown();
    }

    var numero = 1;
    if (lineStart > 1) {
      final prevEnd = lineStart - 1;
      final prevStart = text.substring(0, prevEnd).lastIndexOf('\n') + 1;
      final prevLine = text.substring(prevStart, prevEnd);
      final prevMatch = _orderedListRegex.firstMatch(prevLine);
      if (prevMatch != null) {
        final prevNum = int.tryParse(
          prevMatch.group(1)!.replaceAll('.', '').trim(),
        );
        if (prevNum != null) numero = prevNum + 1;
      }
    }
    final prefixo = '$numero. ';

    if (line.startsWith('• ') || line.startsWith('- ')) {
      final novoTexto = text.replaceRange(lineStart, lineStart + 2, prefixo);
      final novaPos = (pos - 2 + prefixo.length).clamp(
        lineStart,
        novoTexto.length,
      );
      value = TextEditingValue(
        text: novoTexto,
        selection: TextSelection.collapsed(offset: novaPos),
      );
      return normalizarParaMarkdown();
    }

    final novoTexto = text.replaceRange(lineStart, lineStart, prefixo);
    value = TextEditingValue(
      text: novoTexto,
      selection: TextSelection.collapsed(offset: pos + prefixo.length),
    );
    return normalizarParaMarkdown();
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
    return normalizarParaMarkdown();
  }

  /// Converte marcadores visuais `• ` em sintaxe Markdown `- ` para envio/prévia.
  String normalizarParaMarkdown([String? fonte]) {
    final base = fonte ?? text;
    return base
        .split('\n')
        .map((l) => l.startsWith('• ') ? '- ${l.substring(2)}' : l)
        .join('\n');
  }
}
