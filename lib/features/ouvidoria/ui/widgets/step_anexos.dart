import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/ouvidoria_provider.dart';
import '../../../../models/attachment_model.dart';
import 'ouvidoria_form_style.dart';

class StepAnexos extends ConsumerWidget {
  const StepAnexos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ouvidoriaProvider);
    final notifier = ref.read(ouvidoriaProvider.notifier);
    final anexos = state.requestModel.anexos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Anexos (Opcional)',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: OuvidoriaFormStyle.ink,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '• Quantidade máxima de arquivos: 4\n• Formatos recomendados: PDF, DOCX, XLSX, JPG, PNG',
          style: TextStyle(color: OuvidoriaFormStyle.muted, height: 1.35),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: anexos.length >= 4
              ? null
              : () async {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(
                        allowMultiple: true,
                        type: FileType.custom,
                        allowedExtensions: [
                          'pdf',
                          'doc',
                          'docx',
                          'xls',
                          'xlsx',
                          'jpg',
                          'jpeg',
                          'png',
                          'zip',
                        ],
                      );

                  if (result != null) {
                    for (var file in result.files) {
                      if (file.path != null) {
                        notifier.addAttachment(
                          AttachmentModel(
                            path: file.path!,
                            name: file.name,
                            sizeInBytes: file.size,
                          ),
                        );
                      }
                    }
                  }
                },
          icon: const Icon(Icons.attach_file),
          label: const Text('Selecionar Arquivos'),
          style: OutlinedButton.styleFrom(
            foregroundColor: OuvidoriaFormStyle.accent,
            side: const BorderSide(color: OuvidoriaFormStyle.accent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (anexos.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: anexos.length,
            itemBuilder: (context, index) {
              final file = anexos[index];
              return ListTile(
                leading: const Icon(
                  Icons.insert_drive_file,
                  color: OuvidoriaFormStyle.accent,
                ),
                title: Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(file.formattedSize),
                trailing: IconButton(
                  tooltip: 'Remover anexo',
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => notifier.removeAttachment(file),
                ),
              );
            },
          ),
      ],
    );
  }
}
