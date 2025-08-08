// Integration tests for Stealth Clip app
//
// This file contains widget tests that verify the main app functionality
// and user interactions with the Stealth Clip secure clipboard manager.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stealth_clip/main.dart';

void main() {
  group('Stealth Clip App Integration Tests', () {
    testWidgets('should display app title and main UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify main UI elements are present
      expect(find.text('Stealth Clip'), findsOneWidget);
      expect(find.text('Securely store and copy sensitive text'), findsOneWidget);
      expect(find.byIcon(Icons.security), findsOneWidget);
      expect(find.text('Add New Entry'), findsOneWidget);
    });

    testWidgets('should add new entry when Add New Entry button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tap the Add New Entry button
      await tester.tap(find.text('Add New Entry'));
      await tester.pumpAndSettle();

      // Should see at least one entry card
      expect(find.text('New Entry'), findsAtLeastNWidgets(1));
    });

    testWidgets('should show edit interface when edit button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Add an entry first
      await tester.tap(find.text('Add New Entry'));
      await tester.pumpAndSettle();

      // Tap edit button
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Should show edit interface
      expect(find.text('Label'), findsOneWidget);
      expect(find.text('Secret Value'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should save entry data when save button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Add an entry
      await tester.tap(find.text('Add New Entry'));
      await tester.pumpAndSettle();

      // Enter edit mode
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Enter label and text
      await tester.enterText(find.byType(TextField).first, 'My Password');
      await tester.enterText(find.byType(TextField).last, 'secret123');

      // Save the entry
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should show the updated label
      expect(find.text('My Password'), findsOneWidget);
      expect(find.text('✓ Value saved securely'), findsOneWidget);
    });

    testWidgets('should show copy button when entry has content', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Add and configure an entry
      await tester.tap(find.text('Add New Entry'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Test Entry');
      await tester.enterText(find.byType(TextField).last, 'test content');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should show copy button
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('should show snackbar when copy button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Set up an entry with content
      await tester.tap(find.text('Add New Entry'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Test Entry');
      await tester.enterText(find.byType(TextField).last, 'test content');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Tap copy button
      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();

      // Should show snackbar
      expect(find.text('Copied to clipboard'), findsOneWidget);
    });

    testWidgets('should allow multiple entries', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Add first entry
      await tester.tap(find.text('Add New Entry'));
      await tester.pumpAndSettle();

      // Add second entry
      await tester.tap(find.text('Add New Entry'));
      await tester.pumpAndSettle();

      // Should have two entries
      expect(find.text('New Entry'), findsNWidgets(2));
    });

    testWidgets('should show remove button when multiple entries exist', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Add multiple entries
      await tester.tap(find.text('Add New Entry'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add New Entry'));
      await tester.pumpAndSettle();

      // Should show remove buttons
      expect(find.byIcon(Icons.close), findsNWidgets(2));
    });

    testWidgets('should cancel edit when cancel button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Add entry and enter edit mode
      await tester.tap(find.text('Add New Entry'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Change text
      await tester.enterText(find.byType(TextField).first, 'Changed Label');

      // Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Should revert to original label
      expect(find.text('New Entry'), findsOneWidget);
      expect(find.text('Changed Label'), findsNothing);
    });

    testWidgets('should maintain dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Find the MaterialApp to check theme
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.brightness, equals(Brightness.dark));
    });
  });
}
