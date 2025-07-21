import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StealthEntry {
  final String label;
  final String text;

  StealthEntry({required this.label, required this.text});

  Map<String, dynamic> toJson() => {
    'label': label,
    'text': text,
  };

  factory StealthEntry.fromJson(Map<String, dynamic> json) => StealthEntry(
    label: json['label'],
    text: json['text'],
  );
}

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'stealth_entries';
  static const _initialized_key = 'initialized';

  Future<void> _initializeDefaultEntries() async {
    final List<StealthEntry> defaultEntries = [
      StealthEntry(label: 'Entry 1', text: ''),
      StealthEntry(label: 'Entry 2', text: ''),
      StealthEntry(label: 'Entry 3', text: ''),
    ];
    await saveEntries(defaultEntries);
    await _storage.write(key: _initialized_key, value: 'true');
  }

  Future<void> saveEntries(List<StealthEntry> entries) async {
    final jsonList = entries.map((e) => e.toJson()).toList();
    await _storage.write(key: _key, value: jsonEncode(jsonList));
  }

  Future<List<StealthEntry>> getEntries() async {
    // Check if this is first launch
    final initialized = await _storage.read(key: _initialized_key);
    if (initialized == null) {
      await _initializeDefaultEntries();
    }

    final jsonString = await _storage.read(key: _key);
    if (jsonString == null || jsonString.isEmpty) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => StealthEntry.fromJson(json)).toList();
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _key);
  }
}
