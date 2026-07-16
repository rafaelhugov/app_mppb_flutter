import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/ferias_provider.dart';

class NovaSolicitacaoFeriasPage extends ConsumerStatefulWidget {
  const NovaSolicitacaoFeriasPage({super.key});

  @override
  ConsumerState<NovaSolicitacaoFeriasPage> createState() => _NovaSolicitacaoFeriasPageState();
}

class _NovaSolicitacaoFeriasPageState extends ConsumerState<NovaSolicitacaoFeriasPage> {
  final _formKey = GlobalKey<FormState>();
  
  String? _tipoSelecionado;
  DateTime? _dataInicio;
  DateTime? _dataFim;
  String? _justificativa;
  
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _tipos = [
    {'label': 'Gozo Regular', 'value': 'GO', 'icon': Icons.beach_access},
    {'label': 'Gozo Coletivo', 'value': 'GC', 'icon': Icons.groups},
    {'label': 'Antecipação', 'value': 'AN', 'icon': Icons.fast_forward},
    {'label': 'Indenização', 'value': 'IF', 'icon': Icons.payments},
    {'label': 'Conversão em Pecúnia', 'value': 'CF', 'icon': Icons.currency_exchange},
  ];

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart 
        ? (_dataInicio ?? DateTime.now()) 
        : (_dataFim ?? _dataInicio ?? DateTime.now());
        
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFC43922),
              onPrimary: Colors.white,
              onSurface: Color(0xFF342C25),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _dataInicio = picked;
          if (_dataFim != null && _dataFim!.isBefore(_dataInicio!)) {
            _dataFim = null;
          }
        } else {
          _dataFim = picked;
        }
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataInicio == null || _dataFim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione as datas de início e fim.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_dataFim!.isBefore(_dataInicio!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A data de fim deve ser posterior à data de início.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final data = {
      'tipo': _tipoSelecionado,
      'dataInicio': _dataInicio!.toIso8601String().substring(0, 10),
      'dataFim': _dataFim!.toIso8601String().substring(0, 10),
      'justificativa': _justificativa,
    };

    final success = await ref.read(feriasProvider.notifier).novaSolicitacao(data);

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação realizada com sucesso!'), backgroundColor: Colors.green),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao realizar solicitação.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDED4C5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF241D19),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFF8EA)),
          onPressed: () => context.pop(),
          tooltip: 'Voltar',
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nova Solicitação',
              style: TextStyle(color: Color(0xFFFFF8EA), fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Férias / Licença / Afastamento',
              style: TextStyle(color: Color(0xFFD8C5AA), fontSize: 12),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tipo de Solicitação
              _buildFormCard(
                title: 'TIPO DE SOLICITAÇÃO',
                icon: Icons.category,
                isRequired: true,
                child: DropdownButtonFormField<String>(
                  value: _tipoSelecionado,
                  decoration: _inputDecoration(),
                  items: _tipos.map((tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo['value'],
                      child: Row(
                        children: [
                          Icon(tipo['icon'], size: 18, color: const Color(0xFF8F2A1D)),
                          const SizedBox(width: 8),
                          Text(tipo['label'], style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _tipoSelecionado = val),
                  validator: (val) => val == null ? 'Selecione um tipo' : null,
                ),
              ),
              const SizedBox(height: 12),

              // Período
              _buildFormCard(
                title: 'PERÍODO DE GOZO',
                icon: Icons.date_range,
                isRequired: true,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: _inputDecoration().copyWith(
                            labelText: 'INÍCIO',
                            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF86715B)),
                          ),
                          child: Text(
                            _dataInicio != null ? DateFormat('dd/MM/yyyy').format(_dataInicio!) : 'Selecionar',
                            style: const TextStyle(fontSize: 14, color: Color(0xFF342C25)),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.east, size: 16, color: Colors.grey),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: _inputDecoration().copyWith(
                            labelText: 'FIM',
                            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF86715B)),
                          ),
                          child: Text(
                            _dataFim != null ? DateFormat('dd/MM/yyyy').format(_dataFim!) : 'Selecionar',
                            style: const TextStyle(fontSize: 14, color: Color(0xFF342C25)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Justificativa
              _buildFormCard(
                title: 'JUSTIFICATIVA (OPCIONAL)',
                icon: Icons.notes,
                isRequired: false,
                child: TextFormField(
                  decoration: _inputDecoration().copyWith(hintText: 'Descreva o motivo...'),
                  maxLines: 3,
                  onChanged: (val) => _justificativa = val,
                ),
              ),
              const SizedBox(height: 24),

              // Botões
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF73543E),
                        minimumSize: const Size(0, 48), // 48dp touch target
                      ),
                      child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC43922),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48), // 48dp touch target
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSubmitting 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Solicitar', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard({required String title, required IconData icon, required bool isRequired, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7EFE3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF9C7A54).withOpacity(0.35)),
        boxShadow: const [BoxShadow(color: Color(0x29432B1D), offset: Offset(0, 14), blurRadius: 30)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: Color(0xFF8F2A1D), width: 4)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: const Color(0xFF73543E)),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF73543E), letterSpacing: 0.5),
                  ),
                  if (isRequired)
                    const Text(' *', style: TextStyle(color: Color(0xFFB73520), fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFEFE3D1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFC5AD88)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFC5AD88)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD64222), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFB73520)),
      ),
    );
  }
}
