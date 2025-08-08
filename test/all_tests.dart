// Test suite runner for Stealth Clip
// This file imports and runs all test suites to provide comprehensive coverage

// Import all test files
import 'main_test.dart' as main_tests;
import 'models/stealth_entry_test.dart' as model_tests;
import 'services/secure_storage_service_test.dart' as service_tests;
import 'providers/stealth_text_provider_test.dart' as provider_tests;
import 'widgets/stealth_input_test.dart' as widget_tests;
import 'widget_test.dart' as integration_tests;

void main() {
  // Run all test suites
  main_tests.main();
  model_tests.main();
  service_tests.main();
  provider_tests.main();
  widget_tests.main();
  integration_tests.main();
}