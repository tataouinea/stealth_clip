# Stealth Clip Tests

This directory contains comprehensive tests for the Stealth Clip application.

## Test Structure

### Unit Tests
- **`models/stealth_entry_test.dart`**: Tests for the StealthEntry data model, including JSON serialization/deserialization
- **`services/secure_storage_service_test.dart`**: Tests for the SecureStorageService class and related functionality
- **`providers/stealth_text_provider_test.dart`**: Tests for the StealthTextProvider state management

### Widget Tests
- **`widgets/stealth_input_test.dart`**: Tests for the StealthInput and StealthEntryCard widgets
- **`widget_test.dart`**: Integration tests for the main app functionality

### App Tests
- **`main_test.dart`**: Tests for the main app initialization

### Test Runner
- **`all_tests.dart`**: Runs all test suites together

## Running Tests

To run all tests:
```bash
flutter test
```

To run a specific test file:
```bash
flutter test test/models/stealth_entry_test.dart
```

To run tests with coverage:
```bash
flutter test --coverage
```

## Test Coverage

The tests cover:
- ✅ Data model serialization/deserialization
- ✅ State management (Provider pattern)
- ✅ Widget rendering and interactions
- ✅ User workflows (add, edit, save, copy, remove entries)
- ✅ Edge cases (empty data, special characters, long content)
- ✅ Clipboard operations
- ✅ UI state changes and notifications

## Test Types

1. **Unit Tests**: Test individual functions and classes in isolation
2. **Widget Tests**: Test UI components and user interactions
3. **Integration Tests**: Test complete user workflows

## Mocking

Some tests use mocked dependencies where external services (like secure storage) cannot be easily tested in isolation. The tests focus on testing the application logic while mocking system dependencies.