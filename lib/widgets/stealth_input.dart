import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stealth_text_provider.dart';

class StealthInput extends StatefulWidget {
  const StealthInput({super.key});

  @override
  State<StealthInput> createState() => _StealthInputState();
}

class _StealthInputState extends State<StealthInput> {
  final _controller = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StealthTextProvider>(
      builder: (context, provider, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!provider.isTextSaved)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _controller,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Enter sensitive text',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          provider.saveText(_controller.text);
                          _controller.clear();
                        }
                      },
                    ),
                  ),
                ),
              ),
            if (provider.isTextSaved) ...[
              const Text(
                '✓ Text saved securely',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      provider.copyToClipboard();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy to Clipboard'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: provider.clearText,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
