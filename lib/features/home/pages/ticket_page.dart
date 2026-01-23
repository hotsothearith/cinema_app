import 'package:flutter/material.dart';
import '../../../core/ui/blur_bg.dart';
import '../../../core/ui/glass_card.dart';

class TicketPage extends StatelessWidget {
  final Map<String, dynamic> bookingJson;
  const TicketPage({super.key, required this.bookingJson});

  @override
  Widget build(BuildContext context) {
    // Many APIs return {message, data:{...}}. We show both.
    final data = (bookingJson['data'] is Map<String, dynamic>) ? bookingJson['data'] as Map<String, dynamic> : bookingJson;

    final bookingId = data['id'] ?? data['booking_id'] ?? data['bookingId'] ?? '-';
    final showtimeId = data['showtime_id'] ?? data['showtimeId'] ?? '-';
    final seats = data['seat_numbers'] ?? data['seat_codes'] ?? data['seats'] ?? [];

    return BlurBackground(
      child: Scaffold(backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Your ticket')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.confirmation_number_outlined),
                          const SizedBox(width: 10),
                          Text('Booking Confirmed', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Booking ID: $bookingId', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text('Showtime ID: $showtimeId'),
                      const SizedBox(height: 6),
                      Text('Seats: ${seats is List ? seats.join(', ') : seats.toString()}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.qr_code_2, size: 120),
                        const SizedBox(height: 10),
                        Text('Show this at the counter', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('Back to Home'),
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
