import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';

class StealthTextProvider extends ChangeNotifier {
  final SecureStorageService _storage = SecureStorageService();
  String _hiddenText = '';
  bool _isTextSaved = false;

  bool get isTextSaved => _isTextSaved;

  Future<void> saveText(String text) async {
    await _storage.saveText(text);
    _hiddenText = text;
    _isTextSaved = true;
    notifyListeners();
  }

  Future<void> copyToClipboard() async {
    final text = await _storage.getText();
    if (text != null && text.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: text));
    }
  }

  Future<void> clearText() async {
    await _storage.clearText();
    _hiddenText = '';
    _isTextSaved = false;
    notifyListeners();
  }
}
