import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../seats/seats_provider.dart';
import '../../../core/ui/blur_bg.dart';

class SeatsPage extends StatelessWidget {
  final int showtimeId;
  const SeatsPage({super.key, required this.showtimeId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SeatsProvider(showtimeId)..fetchSeats(),
      child: const _SeatsView(),
    );
  }
}

class _SeatsView extends StatefulWidget {
  const _SeatsView();

  @override
  State<_SeatsView> createState() => _SeatsViewState();
}

class _SeatsViewState extends State<_SeatsView> {
  String _time = '13:00';

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SeatsProvider>();
    final seats = p.seats;
    final cs = Theme.of(context).colorScheme;

    return BlurBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Select Seats')),
        body: SafeArea(
          child: Column(
            children: [
              if (p.isLoading) const LinearProgressIndicator(),
              if (p.error != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(p.error!, style: TextStyle(color: cs.error)),
                ),

              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Screen arc
                    SizedBox(
                      height: 44,
                      child: CustomPaint(
                        painter: _ScreenPainter(color: cs.onSurface.withOpacity(0.25)),
                        child: const Center(child: Text('SCREEN')),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        _LegendDot(label: 'Reserved', state: _SeatState.booked),
                        SizedBox(width: 14),
                        _LegendDot(label: 'Available', state: _SeatState.available),
                        SizedBox(width: 14),
                        _LegendDot(label: 'Selected', state: _SeatState.selected),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: seats.length,
                    itemBuilder: (_, i) {
                      final seat = seats[i];
                      final selected = p.selectedIds.contains(seat.id);

                      final state = !seat.isAvailable
                          ? _SeatState.booked
                          : selected
                              ? _SeatState.selected
                              : _SeatState.available;

                      return _SeatTile(
                        label: seat.number.isEmpty ? '${seat.id}' : seat.number,
                        state: state,
                        onTap: () => p.toggleSeat(seat),
                      );
                    },
                  ),
                ),
              ),

              // Time selector + bottom bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Select Time', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: ['10:00', '11:45', '13:00', '14:45', '16:00'].map((t) {
                          final selected = t == _time;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ChoiceChip(
                              label: Text(t),
                              selected: selected,
                              onSelected: (_) => setState(() => _time = t),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    ClipRRect(
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
                              child: OutlinedButton(
                                onPressed: p.selectedIds.isEmpty ? null : () => p.clearSelection(),
                                child: const Text('Clear'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: p.selectedIds.isEmpty
                                    ? null
                                    : () {
                                        Navigator.of(context).pushNamed('/checkout', arguments: {
                                          'showtimeId': p.showtimeId,
                                          'seatIds': p.selectedIds.toList(),
                                          'seatLabels': p.selectedLabels,
                                        });
                                      },
                                child: Text('Book Ticket (${p.selectedIds.length})'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SeatState { available, selected, booked }

class _SeatTile extends StatelessWidget {
  final String label;
  final _SeatState state;
  final VoidCallback onTap;

  const _SeatTile({required this.label, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color bg;
    Color fg;
    switch (state) {
      case _SeatState.available:
        bg = cs.surface.withOpacity(0.10);
        fg = cs.onSurface;
        break;
      case _SeatState.selected:
        bg = cs.primary;
        fg = cs.onPrimary;
        break;
      case _SeatState.booked:
        bg = cs.surfaceVariant.withOpacity(0.25);
        fg = cs.outline;
        break;
    }

    return InkWell(
      onTap: state == _SeatState.booked ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
        ),
        child: Center(
          child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 12)),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  final _SeatState state;
  const _LegendDot({required this.label, required this.state});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color color;
    switch (state) {
      case _SeatState.available:
        color = cs.surface.withOpacity(0.18);
        break;
      case _SeatState.selected:
        color = cs.primary;
        break;
      case _SeatState.booked:
        color = cs.surfaceVariant.withOpacity(0.35);
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

class _ScreenPainter extends CustomPainter {
  final Color color;
  _ScreenPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = color;

    final rect = Rect.fromLTWH(0, 8, size.width, size.height);
    final path = Path();
    path.addArc(rect, math.pi, math.pi);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ScreenPainter oldDelegate) => oldDelegate.color != color;
}
