import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/connectivity_provider.dart';
import '../../../core/ui/main_layout.dart';
import '../../../core/ui/widgets/hero_header_publico.dart';
import '../providers/ouvidoria_provider.dart';
import 'widgets/step_identificacao.dart';
import 'widgets/step_classificacao.dart';
import 'widgets/step_relato.dart';
import 'widgets/step_anexos.dart';
import 'widgets/step_revisao_envio.dart';
import 'widgets/ouvidoria_form_style.dart';
import 'ouvidoria_sucesso_page.dart';

class OuvidoriaPage extends ConsumerWidget {
  const OuvidoriaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ouvidoriaProvider);
    final notifier = ref.read(ouvidoriaProvider.notifier);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: OuvidoriaFormStyle.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(connectivityProvider.notifier).refresh();
          await notifier.recarregarDadosIniciais();
          if (state.currentStep >= 4) {
            await notifier.loadCaptcha();
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              sliver: SliverToBoxAdapter(
                child: _buildStepper(context, state, notifier),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: MainLayout.contentBottomPadding(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const HeroHeaderPublico(
      label: '',
      title: 'Ouvidoria',
      subtitle: '',
      icon: Icons.record_voice_over,
    );
  }

  Widget _buildStepper(
    BuildContext context,
    OuvidoriaState state,
    OuvidoriaNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OuvidoriaStepProgress(currentStep: state.currentStep),
          const SizedBox(height: 14),
          _SlidingStepContent(
            currentStep: state.currentStep,
            child: _OuvidoriaStepCard(
              key: ValueKey<int>(state.currentStep),
              child: _buildCurrentStep(state.currentStep),
            ),
          ),
          _buildStepControls(context, state, notifier),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(int currentStep) {
    return switch (currentStep) {
      0 => const StepIdentificacao(),
      1 => const StepClassificacao(),
      2 => const StepRelato(),
      3 => const StepAnexos(),
      _ => const StepRevisaoEnvio(),
    };
  }

  Widget _buildStepControls(
    BuildContext context,
    OuvidoriaState state,
    OuvidoriaNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (state.currentStep < 4)
            ElevatedButton(
              onPressed: () {
                final error = notifier.nextStep();
                if (error != null) {
                  _showValidationWarning(context, error);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: OuvidoriaFormStyle.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(106, 42),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Próximo'),
            ),
          if (state.currentStep == 4)
            ElevatedButton(
              onPressed: state.isSubmitting
                  ? null
                  : () => _submit(context, state, notifier),
              style: ElevatedButton.styleFrom(
                backgroundColor: OuvidoriaFormStyle.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(150, 42),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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
          if (state.currentStep > 0 && !state.isSubmitting) ...[
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: notifier.previousStep,
              icon: const Icon(Icons.arrow_back_rounded, size: 17),
              label: const Text(
                'Voltar',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: OuvidoriaFormStyle.ink,
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0x66343A40)),
                minimumSize: const Size(102, 42),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _submit(
    BuildContext context,
    OuvidoriaState state,
    OuvidoriaNotifier notifier,
  ) async {
    // Validation
    if (state.requestModel.captchaId == null ||
        state.requestModel.userEnteredCaptchaCode == null ||
        state.requestModel.userEnteredCaptchaCode!.isEmpty) {
      _showValidationWarning(
        context,
        'Por favor, informe o código do Captcha.',
      );
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
        _showValidationWarning(context, state.errorMessage!);
        notifier.clearError();
      }
    }
  }

  void _showValidationWarning(BuildContext context, String message) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        final top = MediaQuery.paddingOf(context).top + 64;
        return Positioned(
          top: top,
          right: 14,
          left: 86,
          child: IgnorePointer(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: OuvidoriaFormStyle.accent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x2A101828),
                      offset: Offset(0, 8),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                    const SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}

class _SlidingStepContent extends StatelessWidget {
  final int currentStep;
  final Widget child;

  const _SlidingStepContent({required this.currentStep, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.12, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(key: ValueKey<int>(currentStep), child: child),
    );
  }
}

class _OuvidoriaStepProgress extends StatelessWidget {
  final int currentStep;

  const _OuvidoriaStepProgress({required this.currentStep});

  static const _labels = [
    'Identif.',
    'Classif.',
    'Relato',
    'Anexos',
    'Revisão',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OuvidoriaFormStyle.border),
      ),
      child: Row(
        children: List.generate(_labels.length, (index) {
          final selected = index == currentStep;
          final completed = index < currentStep;
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: selected ? 26 : 22,
                  height: selected ? 26 : 22,
                  decoration: BoxDecoration(
                    color: selected || completed
                        ? OuvidoriaFormStyle.accent
                        : const Color(0xFFE1E5E3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: completed
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 15,
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : OuvidoriaFormStyle.muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _labels[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected
                        ? OuvidoriaFormStyle.ink
                        : OuvidoriaFormStyle.muted,
                    fontSize: 8.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _OuvidoriaStepCard extends StatelessWidget {
  final Widget child;

  const _OuvidoriaStepCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OuvidoriaFormStyle.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: OuvidoriaFormStyle.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10101828),
            offset: Offset(0, 8),
            blurRadius: 18,
          ),
        ],
      ),
      child: child,
    );
  }
}
