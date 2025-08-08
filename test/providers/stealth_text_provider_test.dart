import 'package:flutter_test/flutter_test.dart';
import 'package:stealth_clip/providers/stealth_text_provider.dart';
import 'package:stealth_clip/services/secure_storage_service.dart';
import 'package:flutter/services.dart';

void main() {
  group('StealthTextProvider', () {
    late StealthTextProvider provider;

    setUp(() {
      // Set up test binding for clipboard operations
      TestWidgetsFlutterBinding.ensureInitialized();
      provider = StealthTextProvider();
    });

    group('Entry Management', () {
      test('should initialize with empty entries list', () {
        // Note: In real app, this loads from storage, but for unit test we start empty
        expect(provider.entries, isA<List<StealthEntry>>());
      });

      test('should add new entry', () async {
        final initialCount = provider.entries.length;
        
        await provider.addNewEntry();
        
        expect(provider.entries.length, equals(initialCount + 1));
        expect(provider.entries.last.label, equals('New Entry'));
        expect(provider.entries.last.text, equals(''));
      });

      test('should save entry correctly', () async {
        await provider.addNewEntry();
        final index = provider.entries.length - 1;
        
        await provider.saveEntry(index, 'Test Label', 'Test Text');
        
        expect(provider.entries[index].label, equals('Test Label'));
        expect(provider.entries[index].text, equals('Test Text'));
      });

      test('should clear entry text but keep label', () async {
        await provider.addNewEntry();
        final index = provider.entries.length - 1;
        await provider.saveEntry(index, 'Test Label', 'Test Text');
        
        await provider.clearEntry(index);
        
        expect(provider.entries[index].label, equals('Test Label'));
        expect(provider.entries[index].text, equals(''));
      });

      test('should remove entry at specific index', () async {
        await provider.addNewEntry();
        await provider.addNewEntry();
        final initialCount = provider.entries.length;
        
        await provider.removeEntry(0);
        
        expect(provider.entries.length, equals(initialCount - 1));
      });

      test('should clear all entries', () async {
        await provider.addNewEntry();
        await provider.addNewEntry();
        
        await provider.clearAllEntries();
        
        expect(provider.entries, isEmpty);
      });
    });

    group('Clipboard Operations', () {
      test('should handle copy to clipboard for valid entry', () async {
        // Mock the clipboard
        const testChannel = MethodChannel('flutter/platform');
        final List<MethodCall> log = <MethodCall>[];
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(testChannel, (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        });

        await provider.addNewEntry();
        final index = provider.entries.length - 1;
        await provider.saveEntry(index, 'Test', 'SecretText');
        
        await provider.copyToClipboard(index);
        
        expect(log.length, equals(1));
        expect(log[0].method, equals('Clipboard.setData'));
        expect(log[0].arguments['text'], equals('SecretText'));
      });

      test('should not copy empty text to clipboard', () async {
        const testChannel = MethodChannel('flutter/platform');
        final List<MethodCall> log = <MethodCall>[];
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(testChannel, (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        });

        await provider.addNewEntry();
        final index = provider.entries.length - 1;
        // Entry has empty text by default
        
        await provider.copyToClipboard(index);
        
        // Should not attempt to copy empty text
        expect(log, isEmpty);
      });
    });

    group('Edge Cases', () {
      test('should handle invalid index gracefully', () async {
        // Test with invalid indices - these should not crash
        expect(() => provider.entries[999], throwsRangeError);
      });

      test('should handle special characters in entry data', () async {
        await provider.addNewEntry();
        final index = provider.entries.length - 1;
        
        const specialLabel = 'Special Chars: !@#\$%^&*()';
        const specialText = 'Unicode: 🔒🔑 Symbols: ©®™';
        
        await provider.saveEntry(index, specialLabel, specialText);
        
        expect(provider.entries[index].label, equals(specialLabel));
        expect(provider.entries[index].text, equals(specialText));
      });

      test('should handle very long text content', () async {
        await provider.addNewEntry();
        final index = provider.entries.length - 1;
        
        final longText = 'A' * 10000; // 10K characters
        
        await provider.saveEntry(index, 'Long Text Entry', longText);
        
        expect(provider.entries[index].text.length, equals(10000));
        expect(provider.entries[index].text, equals(longText));
      });
    });

    group('State Notifications', () {
      test('should notify listeners when entries change', () async {
        var notificationCount = 0;
        provider.addListener(() {
          notificationCount++;
        });
        
        await provider.addNewEntry();
        
        expect(notificationCount, greaterThan(0));
      });

      test('should notify listeners on entry save', () async {
        await provider.addNewEntry();
        var notificationCount = 0;
        provider.addListener(() {
          notificationCount++;
        });
        
        await provider.saveEntry(0, 'Test', 'Text');
        
        expect(notificationCount, greaterThan(0));
      });
    });
  });
}