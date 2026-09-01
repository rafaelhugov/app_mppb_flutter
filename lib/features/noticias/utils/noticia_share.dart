import 'package:share_plus/share_plus.dart';

import '../models/noticia.dart';

Future<void> compartilharNoticia(Noticia noticia) async {
  final link = noticia.link?.trim();
  final parts = [
    noticia.titulo.trim(),
    if (link != null && link.isNotEmpty) link,
  ].where((part) => part.isNotEmpty).join('\n\n');

  if (parts.isEmpty) return;

  await SharePlus.instance.share(
    ShareParams(subject: noticia.titulo, text: parts),
  );
}
