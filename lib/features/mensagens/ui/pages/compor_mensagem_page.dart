import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
import '../widgets/rich_markdown_controller.dart';
import '../widgets/seletor_destinatarios_sheet.dart';

class ComporMensagemPage extends ConsumerStatefulWidget {
  const ComporMensagemPage({super.key});

  @override
  ConsumerState<ComporMensagemPage> createState() => _ComporMensagemPageState();
}

class _ComporMensagemPageState extends ConsumerState<ComporMensagemPage> {
  final TextEditingController _tituloCtrl = TextEditingController();
  final RichMarkdownEditingController _conteudoCtrl =
      RichMarkdownEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final GlobalKey<AudioRecorderBarState> _audioRecorderKey =
      GlobalKey<AudioRecorderBarState>();
  bool _previewMarkdown = false;

  @override
  void initState() {
    super.initState();
    _conteudoCtrl.addListener(_onCursorOrTextChanged);
  }

  void _onCursorOrTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _conteudoCtrl.removeListener(_onCursorOrTextChanged);
    _tituloCtrl.dispose();
    _conteudoCtrl.dispose();
    super.dispose();
  }

  void _alternarEnvoltorio(String token) {
    final novoTexto = _conteudoCtrl.alternarEnvoltorio(token);
    ref.read(envioMensagemProvider.notifier).setConteudo(novoTexto);
  }

  void _alternarLista() {
    final novoTexto = _conteudoCtrl.alternarListaLinha();
    ref.read(envioMensagemProvider.notifier).setConteudo(novoTexto);
  }

  void _alternarListaOrdenada() {
    final novoTexto = _conteudoCtrl.alternarListaOrdenadaLinha();
    ref.read(envioMensagemProvider.notifier).setConteudo(novoTexto);
  }

  void _inserirLink() {
    final novoTexto = _conteudoCtrl.inserirLink();
    ref.read(envioMensagemProvider.notifier).setConteudo(novoTexto);
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

  ThemeData _pickerTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      colorScheme: const ColorScheme.light(
        primary: MensagensColors.brandDark,
        onPrimary: Colors.white,
        secondary: MensagensColors.green,
        onSecondary: Colors.white,
        surface: MensagensColors.surface,
        onSurface: MensagensColors.ink,
        surfaceContainerHigh: MensagensColors.surface,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: MensagensColors.surface,
        headerBackgroundColor: MensagensColors.brandDark,
        headerForegroundColor: Colors.white,
        todayBorder: const BorderSide(color: MensagensColors.green),
        todayForegroundColor: const WidgetStatePropertyAll(MensagensColors.green),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: MensagensColors.surface,
        dialHandColor: MensagensColors.brandDark,
        dialBackgroundColor: MensagensColors.background,
        hourMinuteColor: MensagensColors.background,
        hourMinuteTextColor: MensagensColors.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MensagensColors.ink,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Future<DateTime?> _escolherDataHora(
    BuildContext context, {
    DateTime? referenciaInicial,
    DateTime? dataMinima,
  }) async {
    final agora = DateTime.now();
    final min = dataMinima ?? agora;
    final inicial = referenciaInicial != null && referenciaInicial.isAfter(min)
        ? referenciaInicial
        : min.add(const Duration(hours: 1));
    final firstDate = DateTime(min.year, min.month, min.day);
    final data = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: firstDate,
      lastDate: agora.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: _pickerTheme(ctx),
        child: child!,
      ),
    );
    if (data == null || !context.mounted) return null;
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(inicial),
      builder: (ctx, child) => Theme(
        data: _pickerTheme(ctx),
        child: child!,
      ),
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
            title: 'Novo Comunicado',
            subtitle: '',
            icon: Icons.send_rounded,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                8,
                horizontalPadding,
                bottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionCard(
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
                                size: 20,
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
                          'Prioridade',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _tituloCtrl,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: MensagensColors.ink,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Título do comunicado (opcional)',
                            floatingLabelStyle: const TextStyle(
                              color: MensagensColors.brandDark,
                              fontWeight: FontWeight.w700,
                            ),
                            filled: true,
                            fillColor: MensagensColors.background,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: MensagensColors.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: MensagensColors.brandDark,
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: notifier.setTitulo,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: MensagensColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: MensagensColors.border),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: const BoxDecoration(
                                  color: MensagensColors.surface,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(13),
                                  ),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: MensagensColors.border,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _FormatActionButton(
                                      tooltip: 'Negrito',
                                      icon: Icons.format_bold_rounded,
                                      ativo: _conteudoCtrl.estaEnvolvido('**'),
                                      onTap: () => _alternarEnvoltorio('**'),
                                    ),
                                    _FormatActionButton(
                                      tooltip: 'Itálico',
                                      icon: Icons.format_italic_rounded,
                                      ativo: _conteudoCtrl.estaEnvolvido('*') &&
                                          !_conteudoCtrl.estaEnvolvido('**'),
                                      onTap: () => _alternarEnvoltorio('*'),
                                    ),
                                    _FormatActionButton(
                                      tooltip: 'Tachado',
                                      icon: Icons.format_strikethrough_rounded,
                                      ativo: _conteudoCtrl.estaEnvolvido('~~'),
                                      onTap: () => _alternarEnvoltorio('~~'),
                                    ),
                                    _FormatActionButton(
                                      tooltip: 'Lista com marcadores',
                                      icon: Icons.format_list_bulleted_rounded,
                                      ativo: _conteudoCtrl.estaEmListaMarcadores,
                                      onTap: _alternarLista,
                                    ),
                                    _FormatActionButton(
                                      tooltip: 'Lista ordenada',
                                      icon: Icons.format_list_numbered_rounded,
                                      ativo: _conteudoCtrl.estaEmListaOrdenada,
                                      onTap: _alternarListaOrdenada,
                                    ),
                                    _FormatActionButton(
                                      tooltip: 'Link',
                                      icon: Icons.link_rounded,
                                      onTap: _inserirLink,
                                    ),
                                    const Spacer(),
                                    TextButton.icon(
                                      style: TextButton.styleFrom(
                                        foregroundColor: _previewMarkdown
                                            ? MensagensColors.green
                                            : MensagensColors.muted,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        minimumSize: const Size(0, 32),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () => setState(
                                        () =>
                                            _previewMarkdown = !_previewMarkdown,
                                      ),
                                      icon: Icon(
                                        _previewMarkdown
                                            ? Icons.edit_outlined
                                            : Icons.visibility_outlined,
                                        size: 16,
                                      ),
                                      label: Text(
                                        _previewMarkdown ? 'Editar' : 'Prévia',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_previewMarkdown)
                                Container(
                                  width: double.infinity,
                                  constraints: const BoxConstraints(minHeight: 112),
                                  padding: const EdgeInsets.all(14),
                                  child: _conteudoCtrl.text.trim().isEmpty
                                      ? const Text(
                                          'Nada para pré-visualizar.',
                                          style: TextStyle(
                                            color: MensagensColors.muted,
                                            fontSize: 13.5,
                                          ),
                                        )
                                      : MarkdownBody(
                                          data: _conteudoCtrl
                                              .normalizarParaMarkdown(),
                                          styleSheet: MarkdownStyleSheet(
                                            p: const TextStyle(
                                              fontSize: 14,
                                              height: 1.4,
                                              color: MensagensColors.ink,
                                            ),
                                          ),
                                        ),
                                )
                              else
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    textSelectionTheme: TextSelectionThemeData(
                                      cursorColor: MensagensColors.brandDark,
                                      selectionColor: MensagensColors.green
                                          .withValues(alpha: 0.22),
                                      selectionHandleColor:
                                          MensagensColors.brandDark,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _conteudoCtrl,
                                    cursorColor: MensagensColors.brandDark,
                                    maxLines: 5,
                                    minLines: 4,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      color: MensagensColors.ink,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText:
                                          'Digite sua mensagem institucional...',
                                      hintStyle: TextStyle(
                                        color: MensagensColors.muted,
                                        fontSize: 13.5,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(14),
                                    ),
                                    onChanged: (v) => notifier.setConteudo(
                                      _conteudoCtrl.processarAlteracaoUsuario(v),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _MessengerAttachButton(
                                icon: Icons.mic_rounded,
                                cor: MensagensColors.green,
                                label: 'Áudio',
                                enabled: !state.enviandoAnexo,
                                onTap: () => _audioRecorderKey.currentState
                                    ?.iniciarGravacao(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MessengerAttachButton(
                                icon: Icons.photo_camera_rounded,
                                cor: MensagensColors.blue,
                                label: 'Foto',
                                enabled: !state.enviandoAnexo,
                                onTap: () =>
                                    _selecionarFotoOuVideo(video: false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MessengerAttachButton(
                                icon: Icons.videocam_rounded,
                                cor: MensagensColors.orange,
                                label: 'Vídeo',
                                enabled: !state.enviandoAnexo,
                                onTap: () =>
                                    _selecionarFotoOuVideo(video: true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MessengerAttachButton(
                                icon: Icons.description_rounded,
                                cor: MensagensColors.red,
                                label: 'Arquivo',
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
                          const SizedBox(height: 14),
                          const Text(
                            'Mídias e Anexos Adicionados',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                              color: MensagensColors.ink,
                            ),
                          ),
                          const SizedBox(height: 6),
                          for (final a in state.anexos)
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: MensagensColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: MensagensColors.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.attachment_rounded,
                                    color: MensagensColors.ink,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          a.nomeOriginal,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12.5,
                                            color: MensagensColors.ink,
                                          ),
                                        ),
                                        Text(
                                          '${a.categoria.apiValue} • ${a.tamanhoFormatado}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: MensagensColors.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: MensagensColors.red,
                                      size: 18,
                                    ),
                                    onPressed: () =>
                                        notifier.removerAnexo(a.id),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: MensagensColors.green.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.verified_user_outlined,
                                  color: MensagensColors.green,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Confirmar ciência',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: MensagensColors.ink,
                                      ),
                                    ),
                                    SizedBox(height: 1),
                                    Text(
                                      'Destinatário precisa clicar em Ciente',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: MensagensColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: state.exigeCiencia,
                                onChanged: notifier.setExigeCiencia,
                                activeThumbColor: Colors.white,
                                activeTrackColor: MensagensColors.green,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: const Color(0xFFD0D5DD),
                                trackOutlineColor: const WidgetStatePropertyAll(
                                  Colors.transparent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1,
                          color: MensagensColors.border,
                        ),
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
                            if (dt == null || !context.mounted) return;
                            final limpouExp = notifier.setDataAgendamento(dt);
                            if (limpouExp) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'A data de expiração foi limpa porque era menor que 1h após o novo agendamento.',
                                  ),
                                ),
                              );
                            }
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
                              ? 'Sem data de expiração (mín. +1h após envio)'
                              : DateFormat(
                                  'dd/MM/yyyy HH:mm',
                                ).format(state.dataExpiracao!),
                          definido: state.dataExpiracao != null,
                          onTap: () async {
                            final base = notifier.dataBaseEnvio();
                            final dt = await _escolherDataHora(
                              context,
                              dataMinima: base,
                              referenciaInicial: base.add(
                                const Duration(hours: 24),
                              ),
                            );
                            if (dt == null || !context.mounted) return;
                            final ok = notifier.setDataExpiracao(dt);
                            if (!ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'A expiração deve ter pelo menos 1 hora de margem após o envio.',
                                  ),
                                ),
                              );
                            }
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
                  const SizedBox(height: 16),
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
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
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
      child: Material(color: Colors.transparent, child: child),
    );
  }
}

class _FormatActionButton extends StatelessWidget {
  const _FormatActionButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.ativo = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool ativo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 2),
      decoration: BoxDecoration(
        color: ativo
            ? MensagensColors.green.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 18,
          color: ativo ? MensagensColors.green : MensagensColors.ink,
        ),
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _MessengerAttachButton extends StatelessWidget {
  const _MessengerAttachButton({
    required this.icon,
    required this.cor,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final Color cor;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: MensagensColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: MensagensColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: cor, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: MensagensColors.ink,
                ),
              ),
            ],
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: (definido ? MensagensColors.green : MensagensColors.ink)
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: definido ? MensagensColors.green : MensagensColors.ink,
              ),
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
                      fontSize: 11.5,
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
