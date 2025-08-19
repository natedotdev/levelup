import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_screen.dart'; // your existing level picker

/// /// A top-level Settings hub:
/// - Shows current level
/// - Lets user change level (navigates to SettingsScreen)
/// - (Appearance) placeholder; we’ll wire real theming later
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
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final lvl = prefs.getString('level');
    if (!mounted) return;
    setState(() => _currentLevel = lvl ?? 'Not set');
  }

  Future<void> _pickLevel() async {
    final picked = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );

    if (picked == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('level', picked);

    if (!mounted) return;
    setState(() => _currentLevel = picked);

    // IMPORTANT: return to caller (WordScreen) with the new level
    Navigator.pop(context, picked);
  }

  void _appearanceToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appearance control coming soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'Appearance',
            subtitle: 'Dark mode',
            leading: const Icon(Icons.dark_mode, size: 22),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: _appearanceToast,
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Learning level',
            subtitle: _currentLevel,
            leading: const Icon(Icons.school, size: 22),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: _pickLevel,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget leading;
  final Widget trailing;
  final VoidCallback onTap;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
