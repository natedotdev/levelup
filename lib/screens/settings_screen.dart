import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings page:
/// - Lets the user pick a CEFR level
/// - Saves the choice (SharedPreferences: 'level')
/// - Pops back and returns the chosen level as result to the caller
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const List<String> levels = [
    'A1.1','A1.2','A2.1','A2.2','B1.1','B1.2','B2.1','B2.2','C1.1','C1.2','C2.1','C2.2',
  ];

  String? _currentLevel;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _currentLevel = prefs.getString('level');
      _loading = false;
    });
  }

  Future<void> _selectLevel(String level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('level', level);
    if (!mounted) return;
    Navigator.pop(context, level); // return to caller with selected level
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: levels.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final level = levels[index];
          final isActive = level == _currentLevel;
          return Card(
            elevation: isActive ? 1.5 : 0,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: ListTile(
              dense: true,
              visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              title: Text(
                level,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Theme.of(context).colorScheme.primary : null,
                ),
              ),
              trailing: isActive
                  ? const Icon(Icons.check_rounded, size: 18)
                  : const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => _selectLevel(level),
            ),
          );
        },
      ),
    );
  }
}
