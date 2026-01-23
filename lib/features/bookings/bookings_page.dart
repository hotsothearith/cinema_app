import 'package:flutter/material.dart';
import '../../core/ui/blur_bg.dart';
import '../../core/ui/glass_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'bookings_provider.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<BookingsProvider>().fetchMyBookings());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BookingsProvider>();

    return BlurBackground(
      child: Scaffold(backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Bookings'),
        actions: [
          IconButton(
            onPressed: p.isLoading ? null : () => p.fetchMyBookings(),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (p.isLoading) const LinearProgressIndicator(),
              if (p.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(p.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: p.bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final b = p.bookings[i];
                    final dt = b.createdAt == null ? '' : DateFormat('yyyy-MM-dd HH:mm').format(b.createdAt!);
                    final seats = b.seatNumbers.isEmpty ? '-' : b.seatNumbers.join(', ');
                    return GlassCard(
                      child: ListTile(
                        title: Text('Booking #${b.id}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                        subtitle: Text('Showtime: ${b.showtimeId}\nSeats: $seats\n$dt'),
                        isThreeLine: true,
                        leading: const Icon(Icons.confirmation_number_outlined),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
      ),
    );
  }
}
