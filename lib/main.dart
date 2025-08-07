import 'package:flutter/material.dart';
import 'data/word_list.dart'; // Importing wordfile dart list 

void main() {
  runApp(LevelUpApp());
}

// Main app widget
class LevelUpApp extends StatelessWidget {
  const LevelUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LevelUp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WordScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Word display screen
class WordScreen extends StatelessWidget {
  const WordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final word = wordList[0]; // Use the first word for now
    print('Building WordScreen with word: ${word.word}'); // debug print

    return Scaffold(
      appBar: AppBar(
        title: Text('Wort des Tages'), // Word of the Day
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${word.article} ${word.word}',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Translation: ${word.meaning}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 24),
            Text('Example Sentences:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            SentenceItem(
              label: 'Present',
              german: word.examples['Present'] ?? 'No example available',
              english: word.translations['Present'] ?? 'No translation available',
            ),
            SentenceItem(
              label: 'Simple Past',
              german: word.examples['Simple Past'] ?? 'No example available',
              english: word.translations['Simple Past'] ?? 'No translation available',
            ),
            SentenceItem(
              label: 'Perfect',
              german: word.examples['Perfect'] ?? 'No example available',
              english: word.translations['Perfect'] ?? 'No translation available',
            ),
          ],
        ),
      ),
    );
  }
}


// Reusable widget for example sentences
class SentenceItem extends StatelessWidget {
  final String label;
  final String german;
  final String english;

  const SentenceItem({super.key, 
    required this.label,
    required this.german,
    required this.english,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label (German): $german', style: TextStyle(fontSize: 16)),
          Text('→ $english', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
