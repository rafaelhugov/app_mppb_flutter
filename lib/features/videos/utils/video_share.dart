import 'package:share_plus/share_plus.dart';
import '../models/video_item.dart';

Future<void> compartilharVideo(VideoItem video) async {
  final text = '${video.titulo}\n\nAssista no canal oficial do MPPB:\n${video.youtubeUrl}';

  await SharePlus.instance.share(
    ShareParams(subject: video.titulo, text: text),
  );
}
