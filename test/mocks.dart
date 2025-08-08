import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:stealth_clip/providers/stealth_text_provider.dart';
import 'package:stealth_clip/services/secure_storage_service.dart';

@GenerateMocks([
  SecureStorageService,
  FlutterSecureStorage,
  StealthTextProvider,
])
void main() {}
