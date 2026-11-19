import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/ui/main_layout.dart';
import '../../../../core/ui/widgets/hero_header_publico.dart';
import '../../models/mensagem_aviso_model.dart';
import '../../providers/envio_mensagem_provider.dart';
import '../../providers/permissao_mensagens_provider.dart';
import '../widgets/audio_recorder_bar.dart';
import '../widgets/mensagens_theme.dart';
import '../widgets/seletor_destinatarios_sheet.dart';

class ComporMensagemPage extends ConsumerStatefulWidget {
  const ComporMensagemPage({super.key});

  @override
  ConsumerState<ComporMensagemPage> createState() => _ComporMensagemPageState();
}

class _ComporMensagemPageState extends ConsumerState<ComporMensagemPage> {
  final TextEditingController _tituloCtrl = TextEditingController();
  final TextEditingController _conteudoCtrl = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _conteudoCtrl.dispose();
    super.dispose();
  }

  Future<void> _selecionarFotoOuVideo({required bool video}) async {
    final XFile? midia = video
        ? await _imagePicker.pickVideo(source: ImageSource.gallery)
        : await _imagePicker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
          );
    if (midia == null) return;
    await ref
        .read(envioMensagemProvider.notifier)
        .uploadAnexo(File(midia.path));
  }

  Future<void> _selecionarDocumento() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
        'odt', 'ods', 'odp', 'txt', 'csv', 'md', 'jpg', 'jpeg', 'png', 'mp4', 'm4a', 'mp3',
      ],
    );
    final path = result?.files.single.path;
    if (path == null) return;
    await ref.read(envioMensagemProvider.notifier).uploadAnexo(File(path));
  }

  Future<DateTime?> _escolherDataHora(BuildContext context) async {
    final agora = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: agora.add(const Duration(hours: 1)),
      firstDate: agora,
      lastDate: agora.add(const Duration(days: 365)),
    );
    if (data == null || !context.mounted) return null;
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(agora.add(const Duration(hours: 1))),
    );
    if (hora == null) return null;
    return DateTime(data.year, data.month, data.day, hora.hour, hora.minute);
  }

  Future<void> _publicar() async {
    final enviada = await ref.read(envioMensagemProvider.notifier).enviar();
    if (!mounted || enviada == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enviada.statusPublicacao == 'AGENDADA'
              ? 'Aviso agendado com sucesso!'
              : 'Aviso enviado para ${enviada.totalDestinatarios} destinatário(s)!',
        ),
      ),
    );
    Navigator.of(context).pop(enviada);
  }

  @override
  Widget build(BuildContext context) {
    final podeEnviar =
        ref.watch(podeEnviarMensagensProvider).asData?.value ?? false;
    if (!podeEnviar) {
      return const Scaffold(
        backgroundColor: MensagensColors.background,
        body: Column(
          children: [
            HeroHeaderPublico(
              label: '',
              title: 'Novo Aviso',
              subtitle: '',
              icon: Icons.send_rounded,
            ),
            Expanded(
              child: Center(
                child: Text('Você não possui permissão para enviar avisos.'),
              ),
            ),
          ],
        ),
      );
    }

    final state = ref.watch(envioMensagemProvider);
    final notifier = ref.read(envioMensagemProvider.notifier);
    final horizontalPadding = MainLayout.horizontalPadding(context);
    final bottomPadding = MainLayout.contentBottomPadding(context);

    return Scaffold(
      backgroundColor: MensagensColors.background,
      body: Column(
        children: [
          const HeroHeaderPublico(
            label: '',
            title: 'Novo Aviso Institucional',
            subtitle: '',
            icon: Icons.send_rounded,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                bottomPadding,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MensagensColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: MensagensColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D101828),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SeletorDestinatariosWidget(),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: MensagensColors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: MensagensColors.green.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            color: MensagensColors.green,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.calculandoPrevia
                                  ? 'Calculando prévia de destinatários...'
                                  : 'Alcance estimado: ${state.totalEstimado ?? 0} destinatário(s) ativo(s)',
                              style: const TextStyle(
                                color: MensagensColors.green,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Prioridade do Aviso',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: MensagensColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    MensagensSegmentedPillBar<PrioridadeMensagem>(
                      maxWidth: double.infinity,
                      selectedValue: state.prioridade,
                      onSelected: notifier.setPrioridade,
                      items: const [
                        MensagensSegmentItem(
                          value: PrioridadeMensagem.normal,
                          label: 'Normal',
                        ),
                        MensagensSegmentItem(
                          value: PrioridadeMensagem.importante,
                          label: 'Importante',
                        ),
                        MensagensSegmentItem(
                          value: PrioridadeMensagem.urgente,
                          label: 'Urgente',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: MensagensColors.green,
                      title: const Text(
                        'Exigir confirmação explícita de ciência ("Ciente")',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: MensagensColors.ink,
                        ),
                      ),
                      value: state.exigeCiencia,
                      onChanged: notifier.setExigeCiencia,
                    ),
                    const Divider(color: MensagensColors.border),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _tituloCtrl,
                      decoration: InputDecoration(
                        labelText:
                            'Título (opcional quando enviar mídia/áudio)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: notifier.setTitulo,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _conteudoCtrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText:
                            'Mensagem de texto (opcional quando enviar mídia/áudio)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: notifier.setConteudo,
                    ),
                    const SizedBox(height: 14),
                    AudioRecorderBar(
                      onAudioConfirmado: (arquivo, duracao) async {
                        await notifier.uploadAnexo(
                          arquivo,
                          duracaoSegundos: duracao,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: MensagensColors.ink,
                            side: const BorderSide(
                              color: MensagensColors.border,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: state.enviandoAnexo
                              ? null
                              : () => _selecionarFotoOuVideo(video: false),
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: const Text('Foto'),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: MensagensColors.ink,
                            side: const BorderSide(
                              color: MensagensColors.border,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: state.enviandoAnexo
                              ? null
                              : () => _selecionarFotoOuVideo(video: true),
                          icon: const Icon(Icons.videocam_outlined),
                          label: const Text('Vídeo'),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: MensagensColors.ink,
                            side: const BorderSide(
                              color: MensagensColors.border,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed:
                              state.enviandoAnexo ? null : _selecionarDocumento,
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Documento (PDF, Office, MD...)'),
                        ),
                      ],
                    ),
                    if (state.enviandoAnexo) ...[
                      const SizedBox(height: 10),
                      const LinearProgressIndicator(
                        color: MensagensColors.green,
                      ),
                    ],
                    if (state.anexos.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Mídias e Anexos Adicionados',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: MensagensColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      for (final a in state.anexos)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.attachment,
                            color: MensagensColors.ink,
                          ),
                          title: Text(
                            a.nomeOriginal,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${a.categoria.apiValue} • ${a.tamanhoFormatado}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: MensagensColors.red,
                            ),
                            onPressed: () => notifier.removerAnexo(a.id),
                          ),
                        ),
                    ],
                    const Divider(height: 24, color: MensagensColors.border),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: MensagensColors.ink,
                              side: const BorderSide(
                                color: MensagensColors.border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              final dt = await _escolherDataHora(context);
                              if (dt != null) notifier.setDataAgendamento(dt);
                            },
                            icon: const Icon(Icons.schedule),
                            label: Text(
                              state.dataAgendamento == null
                                  ? 'Agendar envio'
                                  : 'Agendado: ${DateFormat('dd/MM HH:mm').format(state.dataAgendamento!)}',
                            ),
                          ),
                        ),
                        if (state.dataAgendamento != null)
                          IconButton(
                            onPressed: () => notifier.setDataAgendamento(null),
                            icon: const Icon(Icons.clear),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: MensagensColors.ink,
                              side: const BorderSide(
                                color: MensagensColors.border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              final dt = await _escolherDataHora(context);
                              if (dt != null) notifier.setDataExpiracao(dt);
                            },
                            icon: const Icon(Icons.timer_off_outlined),
                            label: Text(
                              state.dataExpiracao == null
                                  ? 'Definir expiração'
                                  : 'Expira: ${DateFormat('dd/MM HH:mm').format(state.dataExpiracao!)}',
                            ),
                          ),
                        ),
                        if (state.dataExpiracao != null)
                          IconButton(
                            onPressed: () => notifier.setDataExpiracao(null),
                            icon: const Icon(Icons.clear),
                          ),
                      ],
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage!,
                        style: const TextStyle(
                          color: MensagensColors.red,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MensagensColors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: state.enviandoMensagem ? null : _publicar,
                        icon: state.enviandoMensagem
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(
                          state.dataAgendamento != null
                              ? 'Confirmar Agendamento'
                              : 'Enviar Aviso Agora',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
