import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';

class StealthTextProvider extends ChangeNotifier {
  final SecureStorageService _storage = SecureStorageService();
  List<StealthEntry> _entries = [];
  
  List<StealthEntry> get entries => _entries;
  
  StealthTextProvider() {
    _loadEntries();
  }
  
  Future<void> _loadEntries() async {
    _entries = await _storage.getEntries();
    notifyListeners();
  }

  Future<void> saveEntry(int index, String label, String text) async {
    _entries[index] = StealthEntry(label: label, text: text);
    await _storage.saveEntries(_entries);
    notifyListeners();
  }

  Future<void> copyToClipboard(int index) async {
    final text = _entries[index].text;
    if (text.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: text));
    }
  }

  Future<void> clearEntry(int index) async {
    _entries[index] = StealthEntry(label: _entries[index].label, text: '');
    await _storage.saveEntries(_entries);
    notifyListeners();
  }

  Future<void> addNewEntry() async {
    _entries.add(StealthEntry(label: 'New Entry', text: ''));
    await _storage.saveEntries(_entries);
    notifyListeners();
  }

  Future<void> removeEntry(int index) async {
    _entries.removeAt(index);
    await _storage.saveEntries(_entries);
    notifyListeners();
  }
}
