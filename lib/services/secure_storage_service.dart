import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'stealth_text';

  Future<void> saveText(String text) async {
    await _storage.write(key: _key, value: text);
  }

  Future<String?> getText() async {
    return await _storage.read(key: _key);
  }

  Future<void> clearText() async {
    await _storage.delete(key: _key);
  }
}
