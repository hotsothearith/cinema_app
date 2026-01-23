import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/movie.dart';
import '../../movies/movies_provider.dart';
import '../../../core/ui/blur_bg.dart';
import '../../../core/ui/glass_card.dart';

class MovieDetailPage extends StatefulWidget {
  final int movieId;
  const MovieDetailPage({super.key, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  Movie? _movie;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = context.read<MoviesProvider>();
    final m = await p.fetchMovieDetail(widget.movieId);
    setState(() {
      _movie = m;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final m = _movie;

    return BlurBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : m == null
                  ? Center(child: Text('Movie not found', style: TextStyle(color: cs.error)))
                  : Stack(
                      children: [
                        CustomScrollView(
                          slivers: [
                            SliverAppBar(
                              pinned: true,
                              expandedHeight: 320,
                              leading: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              actions: const [
                                SizedBox(width: 8),
                                _AppIconButton(icon: Icons.share_outlined),
                                SizedBox(width: 10),
                              ],
                              title: Text(m.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                              flexibleSpace: FlexibleSpaceBar(
                                background: _PosterHeader(url: m.posterUrl),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        if (m.rating != null)
                                          _Tag(text: '★ ${m.rating!.toStringAsFixed(1)}'),
                                        if (m.durationMinutes != null)
                                          _Tag(text: '${m.durationMinutes} min'),
                                        if (m.genre != null && m.genre!.isNotEmpty)
                                          _Tag(text: m.genre!),
                                        if (m.releaseDate != null)
                                          _Tag(text: DateFormat('yyyy-MM-dd').format(m.releaseDate!)),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text('Story',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                                    const SizedBox(height: 10),
                                    GlassCard(
                                      child: Text(
                                        (m.description == null || m.description!.trim().isEmpty)
                                            ? 'No description yet.'
                                            : m.description!,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text('Sessions',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Choose date & time in the next step.',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: cs.onSurface.withOpacity(0.75),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Bottom reservation bar
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cs.surface.withOpacity(0.16),
                                border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: () => Navigator.of(context).pushNamed('/showtimes', arguments: m.id),
                                      child: const Text('Reservation'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

class _PosterHeader extends StatelessWidget {
  final String? url;
  const _PosterHeader({this.url});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (url != null && url!.isNotEmpty)
          CachedNetworkImage(
            imageUrl: url!,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: cs.surfaceVariant.withOpacity(0.4)),
            errorWidget: (_, __, ___) => Container(color: cs.surfaceVariant.withOpacity(0.4)),
          )
        else
          Container(
            color: cs.surfaceVariant.withOpacity(0.4),
            child: const Center(child: Icon(Icons.movie_outlined, size: 64)),
          ),
        // gradient overlay
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.15),
                Colors.black.withOpacity(0.75),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.primary.withOpacity(0.18)),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _AppIconButton extends StatelessWidget {
  final IconData icon;
  const _AppIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: () {},
      ),
    );
  }
}
