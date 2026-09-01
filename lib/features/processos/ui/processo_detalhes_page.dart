import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/widgets/hero_header_publico.dart';
import '../providers/processos_provider.dart';
import '../models/processo.dart';
import '../utils/processo_date_formatter.dart';

const _processBlue = Color(0xFF2563EB);
const _cardBorder = Color(0xFFDDE4DF);
const _textPrimary = Color(0xFF333333);
const _textMuted = Color(0xFF697370);

class ProcessoDetalhesPage extends ConsumerStatefulWidget {
  final String idProcesso;
  final String captchaToken;
  final String captchaValue;

  const ProcessoDetalhesPage({
    super.key,
    required this.idProcesso,
    required this.captchaToken,
    required this.captchaValue,
  });

  @override
  ConsumerState<ProcessoDetalhesPage> createState() =>
      _ProcessoDetalhesPageState();
}

class _ProcessoDetalhesPageState extends ConsumerState<ProcessoDetalhesPage> {
  int _currentTabIndex = 0;

  String _formatDoc(String? doc) {
    if (doc == null || doc.isEmpty) return 'Documento não informado';
    final raw = doc.replaceAll(RegExp(r'\D'), '');
    if (raw.length == 11) {
      return '***.${raw.substring(3, 6)}.${raw.substring(6, 9)}-**';
    } else if (raw.length == 14) {
      return '${raw.substring(0, 2)}.${raw.substring(2, 5)}.${raw.substring(5, 8)}/${raw.substring(8, 12)}-${raw.substring(12, 14)}';
    }
    return doc;
  }

  String _formatLongText(String? text) {
    final raw = text?.trim();
    if (raw == null || raw.isEmpty) return 'Sem resumo detalhado disponível.';

    final normalized = raw
        .replaceAll(RegExp(r'\r\n?'), '\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();

    if (normalized.contains('\n')) return normalized;

    return normalized
        .replaceAllMapped(
          RegExp(r'([.!?])\s+(?=[A-ZÁÉÍÓÚÂÊÔÃÕÇ])'),
          (match) => '${match.group(1)}\n\n',
        )
        .trim();
  }

  String _formatContentText(String? text) {
    final formatted = _formatLongText(text);
    if (formatted == 'Sem resumo detalhado disponível.') return formatted;
    return formatted.split('\n').map(_sentenceCaseText).join('\n');
  }

  String _sentenceCaseText(String value) {
    final lower = value.trim().toLowerCase();
    final buffer = StringBuffer();
    var capitalizeNext = true;

    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      if (RegExp(r'[a-záéíóúâêôãõç]').hasMatch(char)) {
        buffer.write(capitalizeNext ? char.toUpperCase() : char);
        capitalizeNext = false;
      } else {
        buffer.write(char);
        if (RegExp(r'[.!?:;\n]').hasMatch(char)) {
          capitalizeNext = true;
        }
      }
    }

    return buffer
        .toString()
        .replaceAll(RegExp(r'\bmppb\b', caseSensitive: false), 'MPPB')
        .replaceAll(RegExp(r'\bmp\b', caseSensitive: false), 'MP')
        .replaceAll(RegExp(r'\bcnmp\b', caseSensitive: false), 'CNMP')
        .replaceAll(RegExp(r'\bcpf\b', caseSensitive: false), 'CPF')
        .replaceAll(RegExp(r'\bcnpj\b', caseSensitive: false), 'CNPJ');
  }

  String _capitalizeName(String value) {
    const lowercaseWords = {
      'a',
      'as',
      'ao',
      'aos',
      'da',
      'das',
      'de',
      'do',
      'dos',
      'e',
      'em',
      'na',
      'nas',
      'no',
      'nos',
    };

    final words = value.trim().toLowerCase().split(RegExp(r'\s+'));
    return words
        .asMap()
        .entries
        .map((entry) {
          final word = entry.value;
          if (word.isEmpty) return word;
          if (entry.key > 0 && lowercaseWords.contains(word)) return word;

          return word
              .split('-')
              .map((part) {
                if (part.isEmpty) return part;
                return '${part[0].toUpperCase()}${part.substring(1)}';
              })
              .join('-');
        })
        .join(' ');
  }

  IconData _getIconForMov(String? tipo) {
    final t = (tipo ?? '').toLowerCase();
    if (t.contains('distribu')) return Icons.share;
    if (t.contains('juntada')) return Icons.attach_file;
    if (t.contains('conclus')) return Icons.gavel;
    if (t.contains('despacho') || t.contains('decisão')) {
      return Icons.edit_document;
    }
    if (t.contains('arquiva')) return Icons.inventory_2;
    return Icons.radio_button_checked;
  }

  Color _getColorForMov(String? tipo) {
    final t = (tipo ?? '').toLowerCase();
    if (t.contains('distribu')) return Colors.orange[800]!;
    if (t.contains('juntada')) return _processBlue;
    if (t.contains('conclus')) return Colors.purple[700]!;
    if (t.contains('arquiva')) return Colors.grey[800]!;
    if (t.contains('despacho')) return Colors.teal[700]!;
    return _processBlue;
  }

  @override
  Widget build(BuildContext context) {
    final params = ProcessoDetalheParams(
      idProcesso: widget.idProcesso,
      captchaToken: widget.captchaToken,
      captchaValue: widget.captchaValue,
    );
    final detalhesAsync = ref.watch(processoDetalhesProvider(params));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: Column(
        children: [
          const HeroHeaderPublico(
            label: '',
            title: 'Detalhes do Processo',
            subtitle: '',
            icon: Icons.gavel,
          ),
          Expanded(
            child: detalhesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        err.toString().replaceAll('Exception: ', ''),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Voltar para Pesquisa'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (processo) => _buildContent(processo),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ProcessoDetalhe processo) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: const Color(0xFFF7F8F6),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _processBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  processo.classe ?? 'PROCESSO',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                processo.numeroProcesso ?? '',
                style: const TextStyle(
                  color: _processBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Origem: ${processo.numeroOrigem ?? 'Não informada'}',
                style: const TextStyle(color: Color(0xFF7A807D), fontSize: 14),
              ),
            ],
          ),
        ),

        Container(
          color: Colors.white,
          child: Row(
            children: [
              _buildTab(0, 'Movimentações', Icons.history),
              _buildTab(1, 'Interessados', Icons.groups),
              _buildTab(2, 'Resumo', Icons.info),
            ],
          ),
        ),

        // Content
        Expanded(
          child: IndexedStack(
            index: _currentTabIndex,
            children: [
              _buildMovimentacoes(processo),
              _buildInteressados(processo),
              _buildResumo(processo),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(int index, String title, IconData icon) {
    final isActive = _currentTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentTabIndex = index),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? _processBlue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: isActive ? _processBlue : Colors.grey[500]),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? _processBlue : Colors.grey[600],
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovimentacoes(ProcessoDetalhe processo) {
    if (processo.movimentos.isEmpty) {
      return const Center(child: Text('Nenhuma movimentação registrada.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: processo.movimentos.length,
      itemBuilder: (context, index) {
        final mov = processo.movimentos[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _getColorForMov(mov.tipo).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForMov(mov.tipo),
                    size: 18,
                    color: _getColorForMov(mov.tipo),
                  ),
                ),
                if (index < processo.movimentos.length - 1)
                  Container(
                    width: 2,
                    height: 40,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mov.tipo ?? 'Movimentação',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ProcessoDateFormatter.dateTime(mov.data, fallback: ''),
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  if (mov.complemento != null &&
                      mov.complemento!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: _cardBorder),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatContentText(mov.complemento),
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.42,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInteressados(ProcessoDetalhe processo) {
    if (processo.interessados.isEmpty) {
      return const Center(child: Text('Nenhum interessado registrado.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: processo.interessados.length,
      itemBuilder: (context, index) {
        final intp = processo.interessados[index];
        return Card(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _cardBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _processBlue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        intp.tipoParte ?? 'Interessado',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      intp.tipoPessoa ?? '',
                      style: const TextStyle(fontSize: 12, color: _textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _capitalizeName(intp.nome ?? ''),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _textPrimary,
                  ),
                ),
                if (intp.nomeSocial != null && intp.nomeSocial!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Nome Social: ${_capitalizeName(intp.nomeSocial!)}',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: _textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.badge, size: 14, color: _textMuted),
                      const SizedBox(width: 6),
                      Text(
                        _formatDoc(intp.documento),
                        style: const TextStyle(
                          fontSize: 13,
                          color: _textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResumo(ProcessoDetalhe processo) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _cardBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informações adicionais',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _textMuted,
                ),
              ),
              const Divider(height: 32, color: _cardBorder),

              const Text(
                'Data de Registro',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: _textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ProcessoDateFormatter.date(processo.dataRegistro),
                style: const TextStyle(fontSize: 15),
              ),

              const SizedBox(height: 20),

              const Text(
                'Órgão Responsável',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: _textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _sentenceCaseText(processo.promotoria ?? 'N/D'),
                style: const TextStyle(fontSize: 15),
              ),

              const SizedBox(height: 20),

              const Text(
                'Assunto',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: _textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _sentenceCaseText(processo.assuntoPrincipal ?? 'N/D'),
                style: const TextStyle(fontSize: 15),
              ),

              const SizedBox(height: 20),

              const Text(
                'Resumo / Objeto',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: _textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8F6),
                  border: Border.all(color: _cardBorder),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatContentText(processo.textoInformado),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.48,
                    color: _textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
