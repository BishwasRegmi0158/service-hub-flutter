import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_data_provider.dart';
import 'booking_form_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BookingDataProvider>(
      builder: (context, provider, _) {
        final items = provider.cart;

        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Booking Queue',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${items.length} professional${items.length == 1 ? '' : 's'} ready to book',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: items.isEmpty ? null : provider.clearCart,
                      child: const Text('Clear all'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'Your booking queue is empty.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final professional = items[index];

                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: professional.photoUrl.isEmpty
                                      ? Container(
                                          width: 74,
                                          height: 74,
                                          color: const Color(0xFFF1F3F5),
                                          alignment: Alignment.center,
                                          child: const Icon(Icons.person_outline),
                                        )
                                      : Image.network(
                                          professional.photoUrl,
                                          width: 74,
                                          height: 74,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 74,
                                            height: 74,
                                            color: const Color(0xFFF1F3F5),
                                            alignment: Alignment.center,
                                            child: const Icon(Icons.person_outline),
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        professional.fullName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(professional.trade.icon, size: 14, color: Colors.grey.shade600),
                                          const SizedBox(width: 4),
                                          Text(
                                            professional.trade.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '\$${professional.pricePerHour.toStringAsFixed(0)}/hr',
                                        style: const TextStyle(
                                          color: Color(0xFF2563EB),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => provider.removeFromCart(professional.id),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              if (items.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Est. Total (${items.length} item${items.length == 1 ? '' : 's'})',
                            style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Text(
                            '\$${provider.cartTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingFormScreen(professionals: List.from(items)),
                              ),
                            );
                          },
                          child: const Text('Proceed to Booking'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
