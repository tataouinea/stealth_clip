import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'providers/stealth_text_provider.dart';
import 'widgets/stealth_input.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window settings
  await windowManager.ensureInitialized();
  await windowManager.setTitle('Stealth Clip');
  await windowManager.setMinimumSize(const Size(400, 600));
  await windowManager.setSize(const Size(400, 600));
  await windowManager.setResizable(false);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StealthTextProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Stealth Clip',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigoAccent,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.security,
                        size: 48,
                        color: Colors.indigoAccent,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Stealth Clip',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Securely store and copy sensitive text',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Consumer<StealthTextProvider>(
                        builder: (context, provider, child) {
                          return FilledButton.icon(
                            onPressed: provider.addNewEntry,
                            icon: const Icon(Icons.add),
                            label: const Text('Add New Entry'),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                const Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: StealthInput(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
