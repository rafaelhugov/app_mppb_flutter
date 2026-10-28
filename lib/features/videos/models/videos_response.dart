import 'video_item.dart';

class VideosResponse {
  final VideoItem? liveAtiva;
  final List<VideoItem> videos;
  final int total;

  const VideosResponse({
    this.liveAtiva,
    this.videos = const [],
    this.total = 0,
  });

  factory VideosResponse.fromJson(Map<String, dynamic> json) {
    VideoItem? live;
    if (json['liveAtiva'] != null && json['liveAtiva'] is Map<String, dynamic>) {
      live = VideoItem.fromJson(json['liveAtiva'] as Map<String, dynamic>);
    }

    final rawList = json['videos'] as List<dynamic>? ?? [];
    final list = rawList
        .whereType<Map<String, dynamic>>()
        .map((item) => VideoItem.fromJson(item))
        .toList();

    return VideosResponse(
      liveAtiva: live,
      videos: list,
      total: json['total'] as int? ?? list.length,
    );
  }
}
