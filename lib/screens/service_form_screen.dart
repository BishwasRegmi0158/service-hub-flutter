import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/professional.dart';
import '../../models/trade.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_data_provider.dart';
import '../../utils/image_helper.dart';

class ServiceFormScreen extends StatefulWidget {
  final Professional? existing;
  const ServiceFormScreen({super.key, this.existing});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _priceController;
  late final TextEditingController _experienceController;
  late final TextEditingController _bioController;
  late Trade _selectedTrade;
  String _photoData = ''; // base64 data URI, or existing network URL
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _priceController = TextEditingController(text: p?.pricePerHour.toStringAsFixed(0) ?? '');
    _experienceController = TextEditingController(text: p?.experienceYears.toString() ?? '');
    _bioController = TextEditingController(text: p?.bio ?? '');
    _selectedTrade = p?.trade ?? Trades.all.first;
    _photoData = p?.photoUrl ?? '';
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 900,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final mimeType = picked.mimeType ?? 'image/jpeg';
    setState(() => _photoData = 'data:$mimeType;base64,${base64Encode(bytes)}');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final bookingData = context.read<BookingDataProvider>();
    final auth = context.read<AuthProvider>();

    if (_isEditing) {
      final updated = widget.existing!.copyWith(
        pricePerHour: double.tryParse(_priceController.text) ?? widget.existing!.pricePerHour,
        experienceYears: int.tryParse(_experienceController.text) ?? widget.existing!.experienceYears,
        bio: _bioController.text.trim(),
        photoUrl: _photoData,
        trade: _selectedTrade,
      );
      await bookingData.updateProfessional(updated);
    } else {
      final user = auth.currentUser!;
      final nameParts = user.name.trim().split(' ');
      final newProfessional = Professional(
        id: 'prov-${DateTime.now().millisecondsSinceEpoch}',
        firstName: nameParts.first,
        lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
        photoUrl: _photoData,
        email: user.email,
        phone: '',
        city: '',
        state: '',
        trade: _selectedTrade,
        rating: 0,
        pricePerHour: double.tryParse(_priceController.text) ?? 0,
        experienceYears: int.tryParse(_experienceController.text) ?? 0,
        bio: _bioController.text.trim(),
        ownerUserId: user.id,
        isApproved: user.isApprovedProvider,
      );
      await bookingData.addProfessional(newProfessional);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Service' : 'Add Service')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: professionalPhotoWidget(_photoData, height: 140, width: 140),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
                          child: const Icon(Icons.edit, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(_photoData.isEmpty ? 'Choose photo' : 'Change photo'),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<Trade>(
                value: _selectedTrade,
                decoration: const InputDecoration(labelText: 'Trade', border: OutlineInputBorder()),
                items: Trades.all.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                onChanged: (t) => setState(() => _selectedTrade = t!),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Price per hour (\$)', border: OutlineInputBorder()),
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter a valid hourly rate' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Years of experience', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Bio', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_isEditing ? 'Save changes' : 'Add service'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}