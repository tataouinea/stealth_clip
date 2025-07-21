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

  Future<void> saveEntries(List<StealthEntry> entries) async {
    final jsonList = entries.map((e) => e.toJson()).toList();
    await _storage.write(key: _key, value: jsonEncode(jsonList));
  }

  Future<List<StealthEntry>> getEntries() async {
    final jsonString = await _storage.read(key: _key);
    if (jsonString == null || jsonString.isEmpty) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => StealthEntry.fromJson(json)).toList();
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _key);
  }
}
