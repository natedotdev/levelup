import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings page:
/// - Loads the currently saved CEFR level
/// - Shows all levels in a list with a checkmark on the active one
/// - On tap: saves the new level and pops with the result
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const List<String> levels = [
    'A1.1', 'A1.2',
    'A2.1', 'A2.2',
    'B1.1', 'B1.2',
    'B2.1', 'B2.2',
    'C1.1', 'C1.2',
    'C2.1', 'C2.2',
  ];

  String? _currentLevel;   // loaded from SharedPreferences
  bool _loading = true;    // show spinner until level is loaded

  @override
  void initState() {
    super.initState();
    _loadCurrentLevel();
  }

  Future<void> _loadCurrentLevel() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _currentLevel = prefs.getString('level'); // may be null the first time
      _loading = false;
    });
  }

  Future<void> _selectLevel(String level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('level', level);

    if (!mounted) return; // guard context usage after await
    Navigator.pop(context, level); // return selected level to caller
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: levels.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final level = levels[index];
                final isActive = level == _currentLevel;
                return Card(
                  child: ListTile(
                    title: Text(level),
                    trailing: isActive
                        ? const Icon(Icons.check, color: Colors.green)
                        : const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _selectLevel(level),
                  ),
                );
              },
            ),
    );
  }
}
