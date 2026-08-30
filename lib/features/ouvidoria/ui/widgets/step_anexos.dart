import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/ouvidoria_provider.dart';
import '../../../../models/attachment_model.dart';

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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3A241D)),
        ),
        const SizedBox(height: 8),
        const Text(
          '• Quantidade máxima de arquivos: 4\n• Formatos recomendados: PDF, DOCX, XLSX, JPG, PNG',
          style: TextStyle(color: Color(0xFF73543E)),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: anexos.length >= 4
              ? null
              : () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    allowMultiple: true,
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'jpg', 'jpeg', 'png', 'zip'],
                  );

                  if (result != null) {
                    for (var file in result.files) {
                      if (file.path != null) {
                        notifier.addAttachment(AttachmentModel(
                          path: file.path!,
                          name: file.name,
                          sizeInBytes: file.size,
                        ));
                      }
                    }
                  }
                },
          icon: const Icon(Icons.attach_file),
          label: const Text('Selecionar Arquivos'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF8F2A1D),
            side: const BorderSide(color: Color(0xFF8F2A1D)),
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
                leading: const Icon(Icons.insert_drive_file, color: Color(0xFF8F2A1D)),
                title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(file.formattedSize),
                trailing: IconButton(
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
