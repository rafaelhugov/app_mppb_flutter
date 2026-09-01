import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OuvidoriaSucessoPage extends StatelessWidget {
  final String protocolo;

  const OuvidoriaSucessoPage({super.key, required this.protocolo});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dataHora = DateFormat('dd/MM/yyyy HH:mm').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFFDED4C5),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(82, 56, 41, 0.20),
              Color.fromRGBO(82, 56, 41, 0),
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF8F2A1D),
                  size: 100,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Manifestação Enviada!',
                  style: TextStyle(
                    color: Color(0xFF3A241D),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sua manifestação foi registrada com sucesso. Guarde o número do seu protocolo para futuras consultas:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF73543E),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EFE3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color.fromRGBO(214, 169, 47, 0.5)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(36, 18, 12, 0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'PROTOCOLO',
                        style: TextStyle(
                          color: Color(0xFF8F2A1D),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        protocolo,
                        style: const TextStyle(
                          color: Color(0xFF3A241D),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Registrado em $dataHora',
                  style: const TextStyle(
                    color: Color(0xFF73543E),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8F2A1D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'VOLTAR AO INÍCIO',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
