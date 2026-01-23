class Movie {
  final int id;
  final String title;
  final String? description;
  final String? posterUrl;
  final String? genre;
  final double? rating;
  final int? durationMinutes;
  final DateTime? releaseDate;

  Movie({
    required this.id,
    required this.title,
    this.description,
    this.posterUrl,
    this.genre,
    this.rating,
    this.durationMinutes,
    this.releaseDate,
  });

  static Movie fromJson(Map<String, dynamic> j) {
    dynamic v(String k) => j[k];
    double? toDouble(dynamic x) => x == null ? null : (x is num ? x.toDouble() : double.tryParse(x.toString()));
    int? toInt(dynamic x) => x == null ? null : (x is num ? x.toInt() : int.tryParse(x.toString()));
    DateTime? toDate(dynamic x) {
      if (x == null) return null;
      try { return DateTime.parse(x.toString()); } catch (_) { return null; }
    }

    return Movie(
      id: toInt(v('id')) ?? 0,
      title: (v('title') ?? v('name') ?? '').toString(),
      description: v('description')?.toString(),
      posterUrl: (v('poster_url') ?? v('posterUrl') ?? v('poster'))?.toString(),
      genre: v('genre')?.toString(),
      rating: toDouble(v('rating')),
      durationMinutes: toInt(v('duration_minutes') ?? v('duration') ?? v('durationMinutes')),
      releaseDate: toDate(v('release_date') ?? v('releaseDate')),
    );
  }
}
