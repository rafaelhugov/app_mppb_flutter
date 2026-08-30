import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ouvidoria_provider.dart';
import 'widgets/step_identificacao.dart';
import 'widgets/step_classificacao.dart';
import 'widgets/step_relato.dart';
import 'widgets/step_anexos.dart';
import 'widgets/step_revisao_envio.dart';
import 'ouvidoria_sucesso_page.dart';

class OuvidoriaPage extends ConsumerWidget {
  const OuvidoriaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ouvidoriaProvider);
    final notifier = ref.read(ouvidoriaProvider.notifier);

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              sliver: SliverToBoxAdapter(
                child: _buildStepper(context, state, notifier),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 120 + MediaQuery.paddingOf(context).bottom),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color.fromRGBO(214, 169, 47, 0.24)),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(255, 221, 132, 0.14),
            offset: Offset(0, -1),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF241D19),
            Color(0xFF3A241D),
            Color(0xFF8F2A1D),
          ],
          stops: [0.0, 0.46, 1.0],
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 24, 20, 44),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE5B84C), Color(0xFFA96A1D)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color.fromRGBO(255, 222, 142, 0.44)),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(36, 18, 12, 0.30),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(Icons.record_voice_over, color: Color(0xFF211713), size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'ATENDIMENTO AO CIDADÃO',
                  style: TextStyle(
                    color: Color(0xFFE3C474),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Ouvidoria',
                  style: TextStyle(
                    color: Color(0xFFFFF8EA),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        color: Color.fromRGBO(0, 0, 0, 0.22),
                        blurRadius: 12,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Registre sua manifestação de forma segura.',
                  style: TextStyle(
                    color: Color(0xFFD8C5AA),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(BuildContext context, OuvidoriaState state, OuvidoriaNotifier notifier) {
    return Material(
      color: const Color(0xFFF7EFE3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color.fromRGBO(156, 122, 84, 0.35)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF8F2A1D)),
        ),
        child: Stepper(
          margin: const EdgeInsets.all(0),
          physics: const NeverScrollableScrollPhysics(),
          currentStep: state.currentStep,
          onStepContinue: () {
            if (state.currentStep == 4) {
              _submit(context, state, notifier);
            } else {
              final error = notifier.nextStep();
              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
              }
            }
          },
          onStepCancel: () => notifier.previousStep(),
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Row(
                children: [
                  if (state.currentStep < 4)
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8F2A1D),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Próximo'),
                    ),
                  if (state.currentStep == 4)
                    ElevatedButton(
                      onPressed: state.isSubmitting ? null : details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8F2A1D),
                        foregroundColor: Colors.white,
                      ),
                      child: state.isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Enviar Manifestação'),
                    ),
                  if (state.currentStep > 0 && !state.isSubmitting)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Voltar', style: TextStyle(color: Color(0xFF73543E))),
                    ),
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Identificação', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF73543E))),
              content: const StepIdentificacao(),
              isActive: state.currentStep >= 0,
              state: state.currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Classificação', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF73543E))),
              content: const StepClassificacao(),
              isActive: state.currentStep >= 1,
              state: state.currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Relato', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF73543E))),
              content: const StepRelato(),
              isActive: state.currentStep >= 2,
              state: state.currentStep > 2 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Anexos', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF73543E))),
              content: const StepAnexos(),
              isActive: state.currentStep >= 3,
              state: state.currentStep > 3 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Revisão e Envio', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF73543E))),
              content: const StepRevisaoEnvio(),
              isActive: state.currentStep >= 4,
              state: state.currentStep == 4 ? StepState.editing : StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context, OuvidoriaState state, OuvidoriaNotifier notifier) async {
    // Validation
    if (state.requestModel.captchaId == null || state.requestModel.userEnteredCaptchaCode == null || state.requestModel.userEnteredCaptchaCode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, informe o código do Captcha.')));
      return;
    }

    final protocolo = await notifier.submit();
    if (protocolo != null) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OuvidoriaSucessoPage(protocolo: protocolo),
          ),
        );
      }
    } else {
      if (context.mounted && state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        notifier.clearError();
      }
    }
  }
}
