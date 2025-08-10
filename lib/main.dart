import 'package:flutter/material.dart';
import 'data/word_list.dart'; // Importing wordfile dart list
import 'package:levelup/theme/app_text_styles.dart'; //Importing text_styles dart list

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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WordScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Word display screen
class WordScreen extends StatefulWidget {
  const WordScreen({super.key});

  @override
  State<WordScreen> createState() => _WordScreenState();
}

class _WordScreenState extends State<WordScreen> {
  int currentIndex = 0;

  void _showNextWord() {
    setState(() {
      currentIndex = (currentIndex + 1) % wordList.length;
    });
  }

  void _showSwipeDirection(String direction) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Swiped $direction'),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final word = wordList[currentIndex];
    print('Building WordScreen with word: ${word.word}');

    return Scaffold(
      appBar: AppBar(title: const Text('Wort des Tages')),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              _showSwipeDirection("Right to Left");
              _showNextWord();
            } else if (details.primaryVelocity! > 0) {
              _showSwipeDirection("Left to Right");
              setState(() {
                currentIndex =
                    (currentIndex - 1 + wordList.length) % wordList.length;
              });
            }
          }
        },
        child: Stack(
          children: [
            // Scrollable content
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${word.article} ${word.word}',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Translation: ${word.meaning}',
                    style: AppTextStyles.translation,
                  ),

                  // Divider before example sentences
                  const Divider(height: 40, thickness: 1.2),

                  Text('Example Sentences:', style: AppTextStyles.subtitle),
                  const SizedBox(height: 12),

                  SentenceItem(
                    label: 'Present',
                    german: word.examples['Present'] ?? 'N/A',
                    english: word.translations['Present'] ?? 'N/A',
                  ),
                  SentenceItem(
                    label: 'Simple Past',
                    german: word.examples['Simple Past'] ?? 'N/A',
                    english: word.translations['Simple Past'] ?? 'N/A',
                  ),
                  SentenceItem(
                    label: 'Perfect',
                    german: word.examples['Perfect'] ?? 'N/A',
                    english: word.translations['Perfect'] ?? 'N/A',
                  ),
                  const SizedBox(height: 80),
                  Center(
                    child: Text(
                      'Word ${currentIndex + 1} of ${wordList.length}',
                      style: AppTextStyles.pageCounter,
                    ),
                  ),
                  const SizedBox(
                    height: 120,
                  ), // extra space so FAB doesn’t overlap
                ],
              ),
            ),

            // Swipe direction arrows
            Positioned(
              left: 8,
              top: MediaQuery.of(context).size.height / 2 - 24,
              child: const Icon(Icons.arrow_back_ios, color: Colors.black26),
            ),
            Positioned(
              right: 8,
              top: MediaQuery.of(context).size.height / 2 - 24,
              child: const Icon(Icons.arrow_forward_ios, color: Colors.black26),
            ),
          ],
        ),
      ),

      // Fixed bottom button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _showNextWord,
        child: const Text('Next Word'),
      ),
    );
  }
}

// Reusable widget for example sentences
class SentenceItem extends StatelessWidget {
  final String label;
  final String german;
  final String english;

  const SentenceItem({
    super.key,
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
          Text('$label (German): $german', style: AppTextStyles.exampleGerman),
          Text('→ $english', style: AppTextStyles.exampleEnglish),
        ],
      ),
    );
  }
}
