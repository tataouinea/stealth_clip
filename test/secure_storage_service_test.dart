import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stealth_clip/services/secure_storage_service.dart';
import 'mocks.mocks.dart';

void main() {
  late SecureStorageService service;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    service = SecureStorageService(storage: mockStorage);
  });

  group('SecureStorageService', () {
    test('getEntries returns default entries on first launch', () async {
      String? entriesJson;

      when(mockStorage.read(key: 'initialized')).thenAnswer((_) async => null);
      when(mockStorage.write(key: 'initialized', value: 'true')).thenAnswer((_) async {});
      when(mockStorage.write(key: 'stealth_entries', value: anyNamed('value')))
          .thenAnswer((invocation) async {
        entriesJson = invocation.namedArguments[const Symbol('value')];
      });
      when(mockStorage.read(key: 'stealth_entries')).thenAnswer((_) async => entriesJson);

      final entries = await service.getEntries();

      expect(entries.length, 3);
      expect(entries.first.label, 'Entry 1');
      verify(mockStorage.write(key: 'initialized', value: 'true')).called(1);
    });

    test('getEntries returns saved entries', () async {
      final testEntries = [StealthEntry(label: 'test', text: 'secret')];
      final json = jsonEncode(testEntries.map((e) => e.toJson()).toList());
      when(mockStorage.read(key: 'initialized')).thenAnswer((_) async => 'true');
      when(mockStorage.read(key: 'stealth_entries')).thenAnswer((_) async => json);

      final entries = await service.getEntries();

      expect(entries.length, 1);
      expect(entries.first.label, 'test');
      expect(entries.first.text, 'secret');
    });

    test('saveEntries saves entries to storage', () async {
      final testEntries = [StealthEntry(label: 'test', text: 'secret')];
      final json = jsonEncode(testEntries.map((e) => e.toJson()).toList());
      when(mockStorage.write(key: 'stealth_entries', value: json)).thenAnswer((_) async {});

      await service.saveEntries(testEntries);

      verify(mockStorage.write(key: 'stealth_entries', value: json)).called(1);
    });

    test('clearAll clears all entries from storage', () async {
      when(mockStorage.delete(key: 'stealth_entries')).thenAnswer((_) async {});
      when(mockStorage.delete(key: 'initialized')).thenAnswer((_) async {});

      await service.clearAll();

      verify(mockStorage.delete(key: 'stealth_entries')).called(1);
      verify(mockStorage.delete(key: 'initialized')).called(1);
    });
  });
}
