import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trade.dart';
import '../providers/booking_data_provider.dart';
import '../widgets/professional_card.dart';

class TradeProfessionalsScreen extends StatelessWidget {
  final Trade trade;
  const TradeProfessionalsScreen({super.key, required this.trade});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingDataProvider>();
    final results = provider.byTrade(trade.id);

    return Scaffold(
      appBar: AppBar(title: Text(trade.name)),
      body: provider.isLoading && provider.professionals.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : results.isEmpty
              ? Center(child: Text('No ${trade.name.toLowerCase()}s available right now.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: results.length,
                  itemBuilder: (context, index) => ProfessionalCard(professional: results[index]),
                ),
    );
  }
}
