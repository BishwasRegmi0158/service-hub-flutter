import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/professional.dart';
import '../models/booking_model.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_data_provider.dart';

// Accepts a LIST of professionals so it works for a single "Book Now"
// tap (list of 1) and for checking out the whole cart (list of many) —
// one shared name/address/date/time creates one Booking per professional.
class BookingFormScreen extends StatefulWidget {
  final List<Professional> professionals;
  const BookingFormScreen({super.key, required this.professionals});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id;

    final box = Hive.box('bookings');
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final timeStr = _selectedTime!.format(context);

    for (final professional in widget.professionals) {
      final booking = BookingModel(
        id: '${DateTime.now().millisecondsSinceEpoch}-${professional.id}',
        userId: userId,
        professionalId: professional.id,
        professionalName: professional.fullName,
        professionalPhoto: professional.photoUrl,
        tradeName: professional.trade.name,
        pricePerHour: professional.pricePerHour,
        customerName: _nameController.text.trim(),
        address: _addressController.text.trim(),
        date: dateStr,
        time: timeStr,
        notes: _notesController.text.trim(),
      );
      await box.add(booking.toMap());
    }

    if (widget.professionals.length > 1 && mounted) {
      context.read<BookingDataProvider>().clearCart();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(userId != null
            ? 'Booking confirmed and saved to your account!'
            : 'Booking confirmed! (Sign in from Profile to save bookings to an account)'),
      ),
    );

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final total = widget.professionals.fold(0.0, (sum, p) => sum + p.pricePerHour);

    return Scaffold(
      appBar: AppBar(title: const Text('Book Service')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ...widget.professionals.map(
                (p) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(backgroundImage: NetworkImage(p.photoUrl)),
                  title: Text(p.fullName, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(p.trade.name),
                  trailing: Text('\$${p.pricePerHour.toStringAsFixed(0)}/hr'),
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Est. Total', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              if (!auth.isLoggedIn)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "You're booking as a guest. Sign in from the Profile tab "
                    "to keep bookings tied to your account.",
                    style: TextStyle(fontSize: 12.5),
                  ),
                ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Your Name', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Service Address', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter an address' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_selectedDate == null ? 'Select Date' : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_selectedTime == null ? 'Select Time' : _selectedTime!.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: _pickTime,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes (optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _submitBooking,
                child: const Text('Confirm Booking', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
