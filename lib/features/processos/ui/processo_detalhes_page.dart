import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/processos_provider.dart';
import '../models/processo.dart';

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
  ConsumerState<ProcessoDetalhesPage> createState() => _ProcessoDetalhesPageState();
}

class _ProcessoDetalhesPageState extends ConsumerState<ProcessoDetalhesPage> {
  int _currentTabIndex = 0;

  String _formatDate(String? dataString) {
    if (dataString == null || dataString.isEmpty) return '';
    final parts = dataString.split('T');
    final dateParts = parts[0].split('-');
    if (dateParts.length == 3) {
      final timePart = parts.length > 1 ? ' ${parts[1].substring(0, 5)}' : '';
      return '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}$timePart';
    }
    return dataString;
  }

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

  IconData _getIconForMov(String? tipo) {
    final t = (tipo ?? '').toLowerCase();
    if (t.contains('distribu')) return Icons.share;
    if (t.contains('juntada')) return Icons.attach_file;
    if (t.contains('conclus')) return Icons.gavel;
    if (t.contains('despacho') || t.contains('decisão')) return Icons.edit_document;
    if (t.contains('arquiva')) return Icons.inventory_2;
    return Icons.radio_button_checked;
  }

  Color _getColorForMov(String? tipo) {
    final t = (tipo ?? '').toLowerCase();
    if (t.contains('distribu')) return Colors.orange[800]!;
    if (t.contains('juntada')) return Colors.blue[700]!;
    if (t.contains('conclus')) return Colors.purple[700]!;
    if (t.contains('arquiva')) return Colors.grey[800]!;
    if (t.contains('despacho')) return Colors.teal[700]!;
    return const Color(0xFF0044CC);
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
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Detalhes do Processo'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: detalhesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  err.toString().replaceAll('Exception: ', ''),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Voltar para Pesquisa'),
                )
              ],
            ),
          ),
        ),
        data: (processo) => _buildContent(processo),
      ),
    );
  }

  Widget _buildContent(ProcessoDetalhe processo) {
    return Column(
      children: [
        // Header Info
        Container(
          width: double.infinity,
          color: const Color(0xFF1976D2),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  processo.classe ?? 'PROCESSO',
                  style: const TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                processo.numeroProcesso ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                'Origem: ${processo.numeroOrigem ?? 'Não informada'}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        
        // Tabs
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
                color: isActive ? const Color(0xFF1976D2) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: isActive ? const Color(0xFF1976D2) : Colors.grey[500]),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? const Color(0xFF1976D2) : Colors.grey[600],
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
                    color: _getColorForMov(mov.tipo).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getIconForMov(mov.tipo), size: 18, color: _getColorForMov(mov.tipo)),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF333333)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(mov.data),
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  if (mov.complemento != null && mov.complemento!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        mov.complemento!,
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
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
        final isAuthor = intp.tipoParte == 'Autor';
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAuthor ? Colors.blue[800] : Colors.grey[600],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        intp.tipoParte ?? 'Interessado',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(intp.tipoPessoa ?? '', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  intp.nome ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (intp.nomeSocial != null && intp.nomeSocial!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Nome Social: ${intp.nomeSocial}', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54)),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.badge, size: 14, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(_formatDoc(intp.documento), style: const TextStyle(fontSize: 13, color: Colors.black87)),
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
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('INFORMAÇÕES ADICIONAIS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              const Divider(height: 32),
              
              const Text('Data de Registro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 4),
              Text(_formatDate(processo.dataRegistro), style: const TextStyle(fontSize: 15)),
              
              const SizedBox(height: 20),
              
              const Text('Órgão Responsável', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 4),
              Text(processo.promotoria ?? 'N/D', style: const TextStyle(fontSize: 15)),
              
              const SizedBox(height: 20),

              const Text('Assunto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 4),
              Text(processo.assuntoPrincipal ?? 'N/D', style: const TextStyle(fontSize: 15)),
              
              const SizedBox(height: 20),

              const Text('Resumo / Objeto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  processo.textoInformado ?? 'Sem resumo detalhado disponível.',
                  style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
