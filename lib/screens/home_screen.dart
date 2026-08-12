import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_data_provider.dart';
import '../widgets/professional_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingDataProvider>();

    // Search matches either the professional's name or their trade.
    final filtered = _query.isEmpty
        ? provider.professionals
        : provider.professionals.where((p) {
            final q = _query.toLowerCase();
            return p.fullName.toLowerCase().contains(q) ||
                p.trade.name.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('ServiceHub')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search professionals or trades...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF1F3F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody(provider, filtered)),
        ],
      ),
    );
  }

  Widget _buildBody(BookingDataProvider provider, List filtered) {
    if (provider.isLoading && provider.professionals.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.professionals.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text('Failed to load professionals.\n${provider.errorMessage}', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: provider.fetchProfessionals, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (filtered.isEmpty) {
      return const Center(child: Text('No professionals found.'));
    }

    return RefreshIndicator(
      onRefresh: provider.fetchProfessionals,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, index) => ProfessionalCard(professional: filtered[index]),
      ),
    );
  }
}
