import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stealth_clip/main.dart';
import 'package:stealth_clip/providers/stealth_text_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:stealth_clip/services/secure_storage_service.dart';
import 'mocks.mocks.dart';

void main() {
  late MockStealthTextProvider mockProvider;

  setUp(() {
    mockProvider = MockStealthTextProvider();
    when(mockProvider.entries).thenReturn([]);
  });

  testWidgets('Adds and removes an entry', (WidgetTester tester) async {
    // Provide the mock to the widget tree
    await tester.pumpWidget(
      ChangeNotifierProvider<StealthTextProvider>.value(
        value: mockProvider,
        child: const MaterialApp(
          home: MainScreen(),
        ),
      ),
    );

    // Verify that no entries are displayed initially
    expect(find.byType(ListTile), findsNothing);

    // Simulate adding a new entry
    when(mockProvider.addNewEntry()).thenAnswer((_) async {
      when(mockProvider.entries).thenReturn([
        StealthEntry(label: 'New Entry', text: ''),
      ]);
      // We need to manually trigger a state change notification
      // In a real app, this is done by the provider itself
      (mockProvider as ChangeNotifier).notifyListeners();
    });

    // Tap the "Add New Entry" button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump(); // Rebuild the widget after state change

    // Verify that a new entry is displayed
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('New Entry'), findsOneWidget);

    // Simulate removing the entry
    when(mockProvider.removeEntry(0)).thenAnswer((_) async {
      when(mockProvider.entries).thenReturn([]);
      (mockProvider as ChangeNotifier).notifyListeners();
    });

    // Tap the "Remove" button
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    // Verify that the entry is removed
    expect(find.byType(ListTile), findsNothing);
  });
}
