import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings page:
/// - Lets the user pick a CEFR level
/// - Saves the choice (SharedPreferences: 'level')
/// - Pops back and returns the chosen level as result to the caller
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<String> levels = [
    'A1.1', 'A1.2',
    'A2.1', 'A2.2',
    'B1.1', 'B1.2',
    'B2.1', 'B2.2',
    'C1.1', 'C1.2',
    'C2.1', 'C2.2',
  ];

  Future<void> _selectLevel(BuildContext context, String level) async {
    // Persist the new level so RootScreen also picks it on next app start
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('level', level);

    // Guard context usage after await (fixes use_build_context_synchronously)
    if (!context.mounted) return;

    // Return the chosen level to the previous screen
    Navigator.pop(context, level);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: levels.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final level = levels[index];
          return Card(
            child: ListTile(
              title: Text(level),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _selectLevel(context, level),
            ),
          );
        },
      ),
    );
  }
}
