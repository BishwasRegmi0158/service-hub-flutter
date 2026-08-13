import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:servicehub_app/screens/chat_bubble.dart';
import '../providers/booking_data_provider.dart';
const String backendUrl = 'https://servicehub-7404.onrender.com/chat';

class _ChatMessage {
  final String role; // "user" or "model"
  final String content;
  _ChatMessage(this.role, this.content);
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  // Builds the assistant's context from the REAL professionals currently
  // loaded in the app (via BookingDataProvider), instead of a separate
  // hardcoded mock file — so the assistant always recommends people that
  // actually exist in your Home/Trades screens right now.
  String _buildContext() {
    final provider = context.read<BookingDataProvider>();
    final professionals = provider.professionals;
    final tradeNames = provider.trades.map((t) => t.name).toList();

    final providerLines = professionals.take(30).map((p) {
      return '- ${p.fullName}, ${p.trade.name}, \$${p.pricePerHour.toStringAsFixed(0)}/hr, '
          'rating ${p.rating}, ${p.experienceYears} yrs experience, ${p.location}';
    }).join('\n');

    return '''
You are a helpful assistant inside "ServiceHub", an app for booking home
service professionals. Available trades: ${tradeNames.join(', ')}.

Available professionals:
$providerLines

Important: you are a guide inside the app, not the person performing the
work. When a user says "book" a professional, they mean they want your
help choosing one and being directed to that professional's page in the
app — never refuse this or say you "cannot book" anything. Confidently
recommend a specific professional by name and tell the user to open that
professional's page and tap "Book Now" to confirm. Do not add disclaimers
about being unable to take real-world actions.

Rules:
- If a user asks about a trade (e.g. "I need a painter"), recommend a
  specific professional from the list above by name.
- If a user wants to book, confidently tell them which professional to
  choose and to tap "Book Now" on that professional's page.
- Keep answers short and friendly.
''';
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage('user', text));
      _loading = true;
      _controller.clear();
    });

    try {
      final contents = [
        {'role': 'user', 'content': _buildContext()},
        ..._messages.map((m) => {'role': m.role, 'content': m.content}),
      ];

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'messages': contents}),
      );

      final data = jsonDecode(response.body);
      final reply = data['response'] ?? 'Sorry, something went wrong.';

      setState(() {
        _messages.add(_ChatMessage('model', reply));
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage('model', 'Error: could not reach the server.'));
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.15),
              child: Icon(Icons.smart_toy_outlined, size: 18, color: theme.colorScheme.onPrimary),
            ),
            const SizedBox(width: 10),
            const Text('ServiceHub assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(Icons.smart_toy_outlined,
                                color: theme.colorScheme.onPrimaryContainer, size: 26),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Hi! Ask me to help you find a painter, electrician, '
                            'plumber, or carpenter.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final m = _messages[index];
                      return ChatBubble(text: m.content, isUser: m.role == 'user');
                    },
                  ),
          ),
          if (_loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: LinearProgressIndicator(
                minHeight: 2,
                color: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Message ServiceHub assistant...',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: theme.colorScheme.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _loading ? null : _sendMessage,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(Icons.send, size: 18, color: theme.colorScheme.onPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}