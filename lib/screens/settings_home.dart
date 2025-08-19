// lib/screens/settings_home.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme controller (uses .value to read and .set(ThemeMode) to change)
import 'package:levelup/theme/theme_controller.dart';

// Your existing simple level picker screen
import 'package:levelup/screens/settings_screen.dart';

/// SettingsHomeScreen = small hub for premium-feel settings:
/// - Appearance (System / Light / Dark)
/// - Learning level (opens your existing level picker)
///
/// NOTE: When a *new level* is picked, this screen pops with that level
/// so the caller (WordScreen) can reload words immediately.
class SettingsHomeScreen extends StatefulWidget {
  const SettingsHomeScreen({super.key});

  @override
  State<SettingsHomeScreen> createState() => _SettingsHomeScreenState();
}

class _SettingsHomeScreenState extends State<SettingsHomeScreen> {
  String _currentLevel = 'Not set';

  @override
  void initState() {
    super.initState();
    _loadLevel();
  }

  Future<void> _loadLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final lvl = prefs.getString('level');
    if (!mounted) return;
    setState(() => _currentLevel = lvl ?? 'Not set');
  }

  // --- Appearance -----------------------------------------------------------

  String _labelForMode(ThemeMode m) {
    switch (m) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  Future<void> _pickTheme() async {
    final current = ThemeController.instance.value;

    final ThemeMode? chosen = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;

        ListTile tile(ThemeMode mode, IconData icon, String label) {
          final selected = mode == current;
          return ListTile(
            leading: Icon(icon, color: cs.primary),
            title: Text(label),
            trailing: selected ? Icon(Icons.check, color: cs.primary) : null,
            onTap: () => Navigator.pop(ctx, mode),
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              tile(ThemeMode.system, Icons.phone_iphone, 'System'),
              tile(ThemeMode.light, Icons.light_mode, 'Light'),
              tile(ThemeMode.dark, Icons.dark_mode, 'Dark'),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (chosen != null) {
      await ThemeController.instance.set(chosen);
      if (!mounted) return;
      setState(() {}); // refresh subtitle text
    }
  }

  // --- Level ---------------------------------------------------------------

  Future<void> _pickLevel() async {
    // Open your existing level picker; it returns a String? (level)
    final newLevel = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );

    if (!mounted) return;
    if (newLevel != null && newLevel != _currentLevel) {
      // Persist + update local subtitle
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('level', newLevel);
      if (!mounted) return;
      setState(() => _currentLevel = newLevel);

      // Bubble the new level up to WordScreen so it can reload words
      Navigator.pop(context, newLevel);
    }
  }

  // --- UI ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            elevation: 2,
            color: cs.surface,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              leading: Icon(Icons.dark_mode, size: 22, color: cs.primary),
              title: const Text('Appearance'),
              subtitle: Text(_labelForMode(ThemeController.instance.value)),
              trailing: Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant),
              onTap: _pickTheme,
            ),
          ),
          Card(
            elevation: 2,
            color: cs.surface,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              leading: Icon(Icons.school, size: 22, color: cs.primary),
              title: const Text('Learning level'),
              subtitle: Text(_currentLevel),
              trailing: Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant),
              onTap: _pickLevel,
            ),
          ),
        ],
      ),
    );
  }
}