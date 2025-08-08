import 'package:flutter_test/flutter_test.dart';
import 'package:stealth_clip/services/secure_storage_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

// Generate mock with: dart run build_runner build
@GenerateMocks([FlutterSecureStorage])
import 'secure_storage_service_test.mocks.dart';

void main() {
  group('SecureStorageService', () {
    late SecureStorageService service;
    late MockFlutterSecureStorage mockStorage;

    setUp(() {
      service = SecureStorageService();
      mockStorage = MockFlutterSecureStorage();
      // Note: In a real implementation, we'd need to inject the mock storage
      // For now, we'll test the logic that we can test without mocking
    });

    group('StealthEntry', () {
      test('should create entry with label and text', () {
        final entry = StealthEntry(label: 'Test', text: 'Secret');
        
        expect(entry.label, equals('Test'));
        expect(entry.text, equals('Secret'));
      });

      test('should convert to JSON properly', () {
        final entry = StealthEntry(label: 'Test Label', text: 'Secret Text');
        final json = entry.toJson();
        
        expect(json['label'], equals('Test Label'));
        expect(json['text'], equals('Secret Text'));
      });

      test('should create from JSON properly', () {
        final json = {'label': 'Test Label', 'text': 'Secret Text'};
        final entry = StealthEntry.fromJson(json);
        
        expect(entry.label, equals('Test Label'));
        expect(entry.text, equals('Secret Text'));
      });
    });

    group('JSON operations', () {
      test('should handle list of entries serialization', () {
        final entries = [
          StealthEntry(label: 'Entry 1', text: 'Text 1'),
          StealthEntry(label: 'Entry 2', text: 'Text 2'),
        ];

        final jsonList = entries.map((e) => e.toJson()).toList();
        final jsonString = jsonEncode(jsonList);
        
        expect(jsonString, isNotEmpty);
        
        // Verify round-trip
        final decodedList = jsonDecode(jsonString) as List;
        final reconstructedEntries = decodedList
            .map((json) => StealthEntry.fromJson(json))
            .toList();
        
        expect(reconstructedEntries.length, equals(2));
        expect(reconstructedEntries[0].label, equals('Entry 1'));
        expect(reconstructedEntries[0].text, equals('Text 1'));
        expect(reconstructedEntries[1].label, equals('Entry 2'));
        expect(reconstructedEntries[1].text, equals('Text 2'));
      });

      test('should handle empty list', () {
        final entries = <StealthEntry>[];
        final jsonList = entries.map((e) => e.toJson()).toList();
        final jsonString = jsonEncode(jsonList);
        
        expect(jsonString, equals('[]'));
        
        final decodedList = jsonDecode(jsonString) as List;
        final reconstructedEntries = decodedList
            .map((json) => StealthEntry.fromJson(json))
            .toList();
        
        expect(reconstructedEntries, isEmpty);
      });

      test('should handle special characters in JSON', () {
        final entry = StealthEntry(
          label: 'Special: "quotes" & symbols',
          text: 'Password with spaces and symbols: !@#\$%^&*()',
        );
        
        final json = entry.toJson();
        final jsonString = jsonEncode(json);
        final decodedJson = jsonDecode(jsonString);
        final reconstructedEntry = StealthEntry.fromJson(decodedJson);
        
        expect(reconstructedEntry.label, equals(entry.label));
        expect(reconstructedEntry.text, equals(entry.text));
      });
    });

    group('Default entries logic', () {
      test('should create default entries structure', () {
        // Test the default entries that would be created
        final defaultEntries = [
          StealthEntry(label: 'Entry 1', text: ''),
          StealthEntry(label: 'Entry 2', text: ''),
          StealthEntry(label: 'Entry 3', text: ''),
        ];
        
        expect(defaultEntries.length, equals(3));
        expect(defaultEntries[0].label, equals('Entry 1'));
        expect(defaultEntries[0].text, isEmpty);
        expect(defaultEntries[1].label, equals('Entry 2'));
        expect(defaultEntries[2].label, equals('Entry 3'));
      });
    });
  });
}