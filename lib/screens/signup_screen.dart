import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trade.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'pending_approval_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _priceController = TextEditingController();
  final _bioController = TextEditingController();

  String _role = 'user'; // 'user' | 'provider'
  Trade _selectedTrade = Trades.all.first;

  bool _isSubmitting = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final result = await context.read<AuthProvider>().signup(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          role: _role,
          tradeId: _role == 'provider' ? _selectedTrade.id : null,
          pricePerHour: _role == 'provider' ? double.tryParse(_priceController.text) : null,
          bio: _role == 'provider' ? _bioController.text.trim() : null,
        );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _error = result.error;
    });

    if (result.success && result.needsApproval) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PendingApprovalScreen()));
    } else if (result.success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'user', label: Text('I need a service')),
                  ButtonSegment(value: 'provider', label: Text('I provide a service')),
                ],
                selected: {_role},
                onSelectionChanged: (s) => setState(() => _role = s.first),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your email' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.length < 4) ? 'Password must be at least 4 characters' : null,
              ),
              if (_role == 'provider') ...[
                const SizedBox(height: 14),
                DropdownButtonFormField<Trade>(
                  value: _selectedTrade,
                  decoration: const InputDecoration(labelText: 'Trade', border: OutlineInputBorder()),
                  items: Trades.all
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                      .toList(),
                  onChanged: (t) => setState(() => _selectedTrade = t!),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Price per hour (\$)', border: OutlineInputBorder()),
                  validator: (v) {
                    if (_role != 'provider') return null;
                    if (v == null || double.tryParse(v) == null) return 'Enter a valid hourly rate';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Short bio', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Provider accounts need admin approval before you can log in and '
                    'before your listing appears in the app.',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Sign Up'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                child: const Text('Already have an account? Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
