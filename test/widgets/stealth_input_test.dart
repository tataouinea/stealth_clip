import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stealth_clip/widgets/stealth_input.dart';
import 'package:stealth_clip/providers/stealth_text_provider.dart';
import 'package:stealth_clip/services/secure_storage_service.dart';

void main() {
  group('StealthInput Widget', () {
    late StealthTextProvider provider;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      provider = StealthTextProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<StealthTextProvider>.value(
            value: provider,
            child: const StealthInput(),
          ),
        ),
      );
    }

    testWidgets('should display empty list when no entries', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should not find any entry cards initially
      expect(find.byType(StealthEntryCard), findsNothing);
    });

    testWidgets('should display entry cards when entries exist', (WidgetTester tester) async {
      // Add some entries
      await provider.addNewEntry();
      await provider.addNewEntry();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should find entry cards
      expect(find.byType(StealthEntryCard), findsNWidgets(2));
    });

    testWidgets('should display correct entry labels', (WidgetTester tester) async {
      await provider.addNewEntry();
      await provider.saveEntry(0, 'Test Entry 1', 'Secret Text');

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Test Entry 1'), findsOneWidget);
    });
  });

  group('StealthEntryCard Widget', () {
    late StealthTextProvider provider;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      provider = StealthTextProvider();
    });

    Widget createTestWidgetWithEntry(StealthEntry entry, int index) {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<StealthTextProvider>.value(
            value: provider,
            child: StealthEntryCard(entry: entry, index: index),
          ),
        ),
      );
    }

    testWidgets('should display entry label', (WidgetTester tester) async {
      const entry = StealthEntry(label: 'Test Label', text: 'Secret');

      await tester.pumpWidget(createTestWidgetWithEntry(entry, 0));
      await tester.pumpAndSettle();

      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('should show copy button when entry has text', (WidgetTester tester) async {
      const entry = StealthEntry(label: 'Test Label', text: 'Secret');

      await tester.pumpWidget(createTestWidgetWithEntry(entry, 0));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('should not show copy button when entry has no text', (WidgetTester tester) async {
      const entry = StealthEntry(label: 'Test Label', text: '');

      await tester.pumpWidget(createTestWidgetWithEntry(entry, 0));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.copy), findsNothing);
    });

    testWidgets('should show edit button', (WidgetTester tester) async {
      const entry = StealthEntry(label: 'Test Label', text: '');

      await tester.pumpWidget(createTestWidgetWithEntry(entry, 0));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('should enter edit mode when edit button is tapped', (WidgetTester tester) async {
      const entry = StealthEntry(label: 'Test Label', text: '');

      await tester.pumpWidget(createTestWidgetWithEntry(entry, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Should show text fields in edit mode
      expect(find.byType(TextField), findsNWidgets(2)); // Label and text fields
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should show label and secret value fields in edit mode', (WidgetTester tester) async {
      const entry = StealthEntry(label: 'Test Label', text: 'Secret');

      await tester.pumpWidget(createTestWidgetWithEntry(entry, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Should find text fields with correct labels
      expect(find.text('Label'), findsOneWidget);
      expect(find.text('Secret Value'), findsOneWidget);
    });

    testWidgets('should cancel edit mode when cancel button is tapped', (WidgetTester tester) async {
      const entry = StealthEntry(label: 'Test Label', text: '');

      await tester.pumpWidget(createTestWidgetWithEntry(entry, 0));
      await tester.pumpAndSettle();

      // Enter edit mode
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Cancel edit mode
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Should exit edit mode
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('should show snackbar when copy button is tapped', (WidgetTester tester) async {
      const entry = StealthEntry(label: 'Test Label', text: 'Secret');

      await tester.pumpWidget(createTestWidgetWithEntry(entry, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump(); // Trigger snackbar

      expect(find.text('Copied to clipboard'), findsOneWidget);
    });

    testWidgets('should show remove button when multiple entries exist', (WidgetTester tester) async {
      // Add multiple entries to provider
      await provider.addNewEntry();
      await provider.addNewEntry();
      
      const entry = StealthEntry(label: 'Test Label', text: '');

      await tester.pumpWidget(createTestWidgetWithEntry(entry, 0));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should not show remove button when only one entry exists', (WidgetTester tester) async {
      // Add only one entry
      await provider.addNewEntry();
      
      const entry = StealthEntry(label: 'Test Label', text: '');

      await tester.pumpWidget(createTestWidgetWithEntry(entry, 0));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('should show secure message after saving', (WidgetTester tester) async {
      const entry = StealthEntry(label: 'Test Label', text: '');

      await tester.pumpWidget(createTestWidgetWithEntry(entry, 0));
      await tester.pumpAndSettle();

      // Enter edit mode
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Add some text
      await tester.enterText(find.byType(TextField).last, 'Secret Text');
      
      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should show secure message
      expect(find.text('✓ Value saved securely'), findsOneWidget);
    });

    testWidgets('should hide secure message after timeout', (WidgetTester tester) async {
      const entry = StealthEntry(label: 'Test Label', text: '');

      await tester.pumpWidget(createTestWidgetWithEntry(entry, 0));
      await tester.pumpAndSettle();

      // Enter edit mode and save
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField).last, 'Secret Text');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should show message initially
      expect(find.text('✓ Value saved securely'), findsOneWidget);

      // Wait for timeout (3 seconds)
      await tester.pump(const Duration(seconds: 4));

      // Message should be gone
      expect(find.text('✓ Value saved securely'), findsNothing);
    });
  });
}