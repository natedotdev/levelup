import 'package:flutter/material.dart';

void main() {
  runApp(const LevelUpApp());
}

class LevelUpApp extends StatelessWidget {
  const LevelUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LevelUp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy word of the day
    final String word = "das Buch";
    final String translation = "book";
    final List<Map<String, String>> sentences = [
      {
        'tense': 'Present',
        'german': 'Ich lese das Buch.',
        'english': 'I read the book.',
      },
      {
        'tense': 'Simple Past',
        'german': 'Ich las das Buch.',
        'english': 'I read the book (past).',
      },
      {
        'tense': 'Perfect',
        'german': 'Ich habe das Buch gelesen.',
        'english': 'I have read the book.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Word of the Day'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              word,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Translation: $translation',
              style: const TextStyle(fontSize: 18),
            ),
            const Divider(height: 32),
            const Text(
              'Example Sentences',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...sentences.map((s) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${s['tense']} (German): ${s['german']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '→ ${s['english']}',
                      style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 12),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
