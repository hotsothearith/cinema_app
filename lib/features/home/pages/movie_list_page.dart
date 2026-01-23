import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/movie.dart';
import '../../movies/movies_provider.dart';
import '../../../core/ui/blur_bg.dart';
import '../widgets/movie_poster_tile.dart';

class MovieListPage extends StatefulWidget {
  const MovieListPage({super.key});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<MoviesProvider>();
      if (p.movies.isEmpty) p.fetchMovies();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MoviesProvider>();
    final cs = Theme.of(context).colorScheme;

    final q = _search.text.trim().toLowerCase();
    final movies = q.isEmpty
        ? p.movies
        : p.movies.where((m) => m.title.toLowerCase().contains(q)).toList();

    final featured = movies.take(5).toList();
    final latest = movies.skip(0).toList();

    return BlurBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Cinema'),
          actions: [
            IconButton(
              onPressed: p.isLoading ? null : () => p.fetchMovies(),
              icon: const Icon(Icons.refresh),
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Find your next movie',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Search movies...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 14),
                if (p.isLoading) const LinearProgressIndicator(),
                if (p.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(p.error!, style: TextStyle(color: cs.error)),
                  ),
                const SizedBox(height: 12),

                // Featured carousel
                if (featured.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Featured',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      TextButton(
                        onPressed: () {},
                        child: const Text(''),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 220,
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.78),
                      itemCount: featured.length,
                      itemBuilder: (_, i) {
                        final m = featured[i];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: MoviePosterTile(
                            movie: m,
                            large: true,
                            onTap: () => Navigator.of(context).pushNamed('/movie-detail', arguments: m.id),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Latest Movies',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    Text('${movies.length}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: cs.onSurface.withOpacity(0.7))),
                  ],
                ),
                const SizedBox(height: 10),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => p.fetchMovies(),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: latest.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final m = latest[i];
                        return MoviePosterTile(
                          movie: m,
                          onTap: () => Navigator.of(context).pushNamed('/movie-detail', arguments: m.id),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
