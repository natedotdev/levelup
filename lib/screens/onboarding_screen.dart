import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  final Function(String) onLevelSelected;

  const OnboardingScreen({super.key, required this.onLevelSelected});

  @override
  Widget build(BuildContext context) {
    final levels = [
      'A1.1', 'A1.2',
      'A2.1', 'A2.2',
      'B1.1', 'B1.2',
      'C1.1', 'C2.2'
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Choose your level")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: levels.map((level) {
          return Card(
            child: ListTile(
              title: Text(level),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => onLevelSelected(level),
            ),
          );
        }).toList(),
      ),
    );
  }
}
