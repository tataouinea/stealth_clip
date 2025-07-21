import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stealth_text_provider.dart';
import '../services/secure_storage_service.dart';

class StealthInput extends StatelessWidget {
  const StealthInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StealthTextProvider>(
      builder: (context, provider, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.entries.length,
              itemBuilder: (context, index) {
                return StealthEntryCard(
                  entry: provider.entries[index],
                  index: index,
                );
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: provider.addNewEntry,
              icon: const Icon(Icons.add),
              label: const Text('Add New Entry'),
            ),
          ],
        );
      },
    );
  }
}

class StealthEntryCard extends StatefulWidget {
  final StealthEntry entry;
  final int index;

  const StealthEntryCard({
    super.key,
    required this.entry,
    required this.index,
  });

  @override
  State<StealthEntryCard> createState() => _StealthEntryCardState();
}

class _StealthEntryCardState extends State<StealthEntryCard> {
  late TextEditingController _labelController;
  late TextEditingController _textController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.entry.label);
    _textController = TextEditingController(text: widget.entry.text);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<StealthTextProvider>();
    final hasValue = widget.entry.text.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditing) ...[
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Label',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Secret Value',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() => _isEditing = false);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      provider.saveEntry(
                        widget.index,
                        _labelController.text,
                        _textController.text,
                      );
                      setState(() => _isEditing = false);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.entry.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (hasValue) ...[
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        provider.copyToClipboard(widget.index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      tooltip: 'Copy to clipboard',
                    ),
                  ],
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => setState(() => _isEditing = true),
                    tooltip: 'Edit',
                  ),
                  if (provider.entries.length > 1)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => provider.removeEntry(widget.index),
                      tooltip: 'Remove entry',
                    ),
                ],
              ),
              if (hasValue)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    '✓ Value saved securely',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
