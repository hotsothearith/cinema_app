import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../showtimes/showtimes_provider.dart';
import '../../movies/movies_provider.dart';
import '../../../core/ui/blur_bg.dart';
import '../../../core/ui/glass_card.dart';

class ShowtimesPage extends StatefulWidget {
  final int movieId;
  const ShowtimesPage({super.key, required this.movieId});

  @override
  State<ShowtimesPage> createState() => _ShowtimesPageState();
}

class _ShowtimesPageState extends State<ShowtimesPage> {
  DateTime _day = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p = context.read<ShowtimesProvider>();
      if (p.all.isEmpty) await p.fetchShowtimes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final movies = context.watch<MoviesProvider>();
    final showtimesProvider = context.watch<ShowtimesProvider>();
    final cs = Theme.of(context).colorScheme;

    final movie = movies.movies.firstWhere(
      (m) => m.id == widget.movieId,
      orElse: () => movies.movies.isNotEmpty ? movies.movies.first : null as dynamic,
    );

    final all = showtimesProvider.forMovie(widget.movieId);

    // Filter by selected day (local)
    final dayItems = all.where((s) {
      final d = s.startsAt;
      return d.year == _day.year && d.month == _day.month && d.day == _day.day;
    }).toList();

    final days = List.generate(7, (i) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day).add(Duration(days: i));
    });

    return BlurBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(movie?.title ?? 'Showtimes')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (showtimesProvider.isLoading) const LinearProgressIndicator(),
                if (showtimesProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(showtimesProvider.error!, style: TextStyle(color: cs.error)),
                  ),
                const SizedBox(height: 12),

                // Day selector pills
                SizedBox(
                  height: 70,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: days.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final d = days[i];
                      final selected = d.year == _day.year && d.month == _day.month && d.day == _day.day;
                      return _DayPill(
                        date: d,
                        selected: selected,
                        onTap: () => setState(() => _day = d),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),

                Expanded(
                  child: dayItems.isEmpty
                      ? Center(
                          child: Text(
                            'No showtimes for this date.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.75)),
                          ),
                        )
                      : ListView.separated(
                          itemCount: dayItems.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final s = dayItems[i];
                            final time = DateFormat('HH:mm').format(s.startsAt);
                            final date = DateFormat('EEE, MMM d').format(s.startsAt);
                            final cinemaName = s.cinema?.name ?? 'Cinema #${s.cinemaId}';
                            final priceText = s.price == null ? '' : '\$${s.price!.toStringAsFixed(2)}';

                            return GlassCard(
                              onTap: () => Navigator.of(context).pushNamed('/seats', arguments: s.id),
                              child: Row(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: cs.primary.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: cs.primary.withOpacity(0.20)),
                                    ),
                                    child: Center(
                                      child: Text(time,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(fontWeight: FontWeight.w900)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(cinemaName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(fontWeight: FontWeight.w900)),
                                        const SizedBox(height: 6),
                                        Text('$date • $priceText',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: cs.onSurface.withOpacity(0.75),
                                                )),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                            );
                          },
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

class _DayPill extends StatelessWidget {
  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  const _DayPill({required this.date, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label1 = DateFormat('EEE').format(date);
    final label2 = DateFormat('d').format(date);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 78,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selected ? cs.primary.withOpacity(0.26) : cs.surface.withOpacity(0.08),
          border: Border.all(
            color: selected ? cs.primary.withOpacity(0.28) : cs.outlineVariant.withOpacity(0.22),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label1, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 2),
            Text(label2, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
