import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stealth_clip/providers/stealth_text_provider.dart';
import 'package:stealth_clip/services/secure_storage_service.dart';
import 'mocks.mocks.dart';

void main() {
  late StealthTextProvider provider;
  late MockSecureStorageService mockStorageService;

  setUp(() {
    mockStorageService = MockSecureStorageService();
    when(mockStorageService.getEntries()).thenAnswer((_) async => []);
    provider = StealthTextProvider(storage: mockStorageService);
  });

  group('StealthTextProvider', () {
    test('initial entries are loaded from storage', () async {
      final entries = [StealthEntry(label: 'test', text: 'text')];
      when(mockStorageService.getEntries()).thenAnswer((_) async => entries);

      // Re-initialize provider to test loading
      provider = StealthTextProvider(storage: mockStorageService);

      // Need to wait for the async constructor to complete
      await Future.delayed(Duration.zero);

      expect(provider.entries, equals(entries));
      verify(mockStorageService.getEntries()).called(2);
    });

    test('addNewEntry adds a new entry and saves', () async {
      when(mockStorageService.saveEntries(any)).thenAnswer((_) async {});

      final initialCount = provider.entries.length;
      await provider.addNewEntry();

      expect(provider.entries.length, equals(initialCount + 1));
      expect(provider.entries.last.label, equals('New Entry'));
      verify(mockStorageService.saveEntries(provider.entries)).called(1);
    });

    test('removeEntry removes an entry and saves', () async {
      final entry = StealthEntry(label: 'test', text: 'text');
      provider.entries.add(entry);
      when(mockStorageService.saveEntries(any)).thenAnswer((_) async {});

      await provider.removeEntry(0);

      expect(provider.entries, isEmpty);
      verify(mockStorageService.saveEntries(provider.entries)).called(1);
    });

    test('saveEntry updates an entry and saves', () async {
      final entry = StealthEntry(label: 'test', text: 'text');
      provider.entries.add(entry);
      when(mockStorageService.saveEntries(any)).thenAnswer((_) async {});

      await provider.saveEntry(0, 'updated label', 'updated text');

      expect(provider.entries.first.label, equals('updated label'));
      expect(provider.entries.first.text, equals('updated text'));
      verify(mockStorageService.saveEntries(provider.entries)).called(1);
    });

    test('clearEntry clears entry text and saves', () async {
      final entry = StealthEntry(label: 'test', text: 'text');
      provider.entries.add(entry);
      when(mockStorageService.saveEntries(any)).thenAnswer((_) async {});

      await provider.clearEntry(0);

      expect(provider.entries.first.text, isEmpty);
      verify(mockStorageService.saveEntries(provider.entries)).called(1);
    });

    test('clearAllEntries clears all entries and storage', () async {
      final entry = StealthEntry(label: 'test', text: 'text');
      provider.entries.add(entry);
      when(mockStorageService.clearAll()).thenAnswer((_) async {});

      await provider.clearAllEntries();

      expect(provider.entries, isEmpty);
      verify(mockStorageService.clearAll()).called(1);
    });
  });
}
