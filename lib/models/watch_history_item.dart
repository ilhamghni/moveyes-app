import '../models/movie.dart';

class WatchHistoryItem {
  final int id;
  final Movie movie;
  final int progress;
  final DateTime watchedAt;

  WatchHistoryItem({
    required this.id,
    required this.movie,
    required this.progress,
    required this.watchedAt,
  });
}
