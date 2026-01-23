import 'package:flutter/material.dart';
import '../../../core/ui/blur_bg.dart';
import '../../../core/ui/glass_card.dart';
import 'package:provider/provider.dart';
import '../../auth/login_page.dart';
import '../../auth/auth_provider.dart';
import '../../bookings/bookings_provider.dart';

class CheckoutPage extends StatelessWidget {
  final int showtimeId;
  final List<int> seatIds;
  final List<String> seatLabels;

  const CheckoutPage({
    super.key,
    required this.showtimeId,
    required this.seatIds,
    required this.seatLabels,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bookings = context.watch<BookingsProvider>();

    return BlurBackground(
      child: Scaffold(backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Checkout')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Summary', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      Text('Showtime ID: $showtimeId'),
                      const SizedBox(height: 6),
                      Text('Seats: ${seatLabels.join(', ')}'),
                      const SizedBox(height: 6),
                      Text('Total seats: ${seatIds.length}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              if (bookings.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(bookings.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: bookings.isLoading
                      ? null
                      : () async {
                          if (!auth.isLoggedIn) {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()));
                            return;
                          }

                          final res = await bookings.createBooking(showtimeId: showtimeId, seatIds: seatIds);
                          if (!context.mounted) return;
                          if (res != null) {
                            Navigator.of(context).pushNamed('/ticket', arguments: res);
                          }
                        },
                  icon: const Icon(Icons.lock_outline),
                  label: bookings.isLoading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Confirm booking'),
                ),
              ),
            ],
          ),
        ),
      ),
    )
      );
  }
}
