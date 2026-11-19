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
  final GlobalKey<AudioRecorderBarState> _audioRecorderKey =
      GlobalKey<AudioRecorderBarState>();

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
                child: Material(
                  color: Colors.transparent,
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
                    const SizedBox(height: 16),
                    const Text(
                      'Mídias e Anexos',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: MensagensColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AudioRecorderBar(
                      key: _audioRecorderKey,
                      ocultarBotaoInicial: true,
                      onAudioConfirmado: (arquivo, duracao) async {
                        await notifier.uploadAnexo(
                          arquivo,
                          duracaoSegundos: duracao,
                        );
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _MidiaActionTile(
                            icon: Icons.mic_none_rounded,
                            cor: MensagensColors.green,
                            titulo: 'Áudio',
                            subtitulo: 'Gravar voz',
                            enabled: !state.enviandoAnexo,
                            onTap: () =>
                                _audioRecorderKey.currentState?.iniciarGravacao(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MidiaActionTile(
                            icon: Icons.photo_camera_outlined,
                            cor: MensagensColors.blue,
                            titulo: 'Foto',
                            subtitulo: 'Galeria',
                            enabled: !state.enviandoAnexo,
                            onTap: () => _selecionarFotoOuVideo(video: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _MidiaActionTile(
                            icon: Icons.videocam_outlined,
                            cor: MensagensColors.orange,
                            titulo: 'Vídeo',
                            subtitulo: 'Galeria',
                            enabled: !state.enviandoAnexo,
                            onTap: () => _selecionarFotoOuVideo(video: true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MidiaActionTile(
                            icon: Icons.description_outlined,
                            cor: MensagensColors.red,
                            titulo: 'Documento',
                            subtitulo: 'PDF, Office, MD',
                            enabled: !state.enviandoAnexo,
                            onTap: _selecionarDocumento,
                          ),
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
                    const SizedBox(height: 18),
                    const Text(
                      'Agendamento e Validade',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: MensagensColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: MensagensColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: MensagensColors.border),
                      ),
                      child: Column(
                        children: [
                          _OpcaoTemporalRow(
                            icon: Icons.schedule_rounded,
                            titulo: 'Agendar envio',
                            valor: state.dataAgendamento == null
                                ? 'Envio imediato'
                                : DateFormat(
                                    'dd/MM/yyyy HH:mm',
                                  ).format(state.dataAgendamento!),
                            definido: state.dataAgendamento != null,
                            onTap: () async {
                              final dt = await _escolherDataHora(context);
                              if (dt != null) notifier.setDataAgendamento(dt);
                            },
                            onClear: state.dataAgendamento != null
                                ? () => notifier.setDataAgendamento(null)
                                : null,
                          ),
                          const Divider(
                            height: 1,
                            color: MensagensColors.border,
                          ),
                          _OpcaoTemporalRow(
                            icon: Icons.timer_off_outlined,
                            titulo: 'Expiração do aviso',
                            valor: state.dataExpiracao == null
                                ? 'Sem data de expiração'
                                : DateFormat(
                                    'dd/MM/yyyy HH:mm',
                                  ).format(state.dataExpiracao!),
                            definido: state.dataExpiracao != null,
                            onTap: () async {
                              final dt = await _escolherDataHora(context);
                              if (dt != null) notifier.setDataExpiracao(dt);
                            },
                            onClear: state.dataExpiracao != null
                                ? () => notifier.setDataExpiracao(null)
                                : null,
                          ),
                        ],
                      ),
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
          ),
        ],
      ),
    );
  }
}

class _MidiaActionTile extends StatelessWidget {
  const _MidiaActionTile({
    required this.icon,
    required this.cor,
    required this.titulo,
    required this.subtitulo,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final Color cor;
  final String titulo;
  final String subtitulo;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: MensagensColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: MensagensColors.border),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: cor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: cor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: MensagensColors.ink,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          subtitulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: MensagensColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OpcaoTemporalRow extends StatelessWidget {
  const _OpcaoTemporalRow({
    required this.icon,
    required this.titulo,
    required this.valor,
    required this.definido,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String titulo;
  final String valor;
  final bool definido;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: definido ? MensagensColors.green : MensagensColors.ink,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: MensagensColors.ink,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    valor,
                    style: TextStyle(
                      fontSize: 12,
                      color: definido
                          ? MensagensColors.green
                          : MensagensColors.muted,
                      fontWeight: definido ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Limpar',
                onPressed: onClear,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: MensagensColors.muted,
                ),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: MensagensColors.muted,
              ),
          ],
        ),
      ),
    );
  }
}
