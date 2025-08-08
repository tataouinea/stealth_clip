import 'package:flutter_test/flutter_test.dart';
import 'package:stealth_clip/services/secure_storage_service.dart';

void main() {
  group('StealthEntry', () {
    test('should create StealthEntry with required fields', () {
      const label = 'Test Label';
      const text = 'Test Text';
      
      final entry = StealthEntry(label: label, text: text);
      
      expect(entry.label, equals(label));
      expect(entry.text, equals(text));
    });

    test('should serialize to JSON correctly', () {
      const entry = StealthEntry(label: 'Test Label', text: 'Secret Text');
      
      final json = entry.toJson();
      
      expect(json, isA<Map<String, dynamic>>());
      expect(json['label'], equals('Test Label'));
      expect(json['text'], equals('Secret Text'));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'label': 'Test Label',
        'text': 'Secret Text',
      };
      
      final entry = StealthEntry.fromJson(json);
      
      expect(entry.label, equals('Test Label'));
      expect(entry.text, equals('Secret Text'));
    });

    test('should handle empty values', () {
      const entry = StealthEntry(label: '', text: '');
      
      final json = entry.toJson();
      final deserializedEntry = StealthEntry.fromJson(json);
      
      expect(deserializedEntry.label, equals(''));
      expect(deserializedEntry.text, equals(''));
    });

    test('should handle special characters and unicode', () {
      const entry = StealthEntry(
        label: 'Special Characters: !@#$%^&*()',
        text: 'Unicode: 😀🔒🔑 and symbols: ©®™',
      );
      
      final json = entry.toJson();
      final deserializedEntry = StealthEntry.fromJson(json);
      
      expect(deserializedEntry.label, equals('Special Characters: !@#$%^&*()'));
      expect(deserializedEntry.text, equals('Unicode: 😀🔒🔑 and symbols: ©®™'));
    });
  });
}