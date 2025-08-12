import 'package:flutter/material.dart';
import 'package:levelup/theme/app_text_styles.dart';

// NEW: use your JSON loader + model instead of word_list.dart
import 'data/word_repository.dart';
import 'models/german_word.dart';

void main() {
  runApp(const LevelUpApp());
}

// Main app widget
class LevelUpApp extends StatelessWidget {
  const LevelUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LevelUp',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WordScreen(),
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
  // STATE THAT REPLACED wordList FROM word_list.dart
  List<GermanWord> _words = [];   // all words loaded from JSON
  int currentIndex = 0;           // which word we’re showing right now
  bool _loading = true;           // show spinner until JSON is loaded
  String? _error;                 // capture load errors

  @override
  void initState() {
    super.initState();
    _loadWords(); // kick off JSON loading as soon as the screen mounts
  }

  /// Load words from assets/words.json via WordRepository
  Future<void> _loadWords() async {
    try {
      final loaded = await WordRepository.loadWords();
      setState(() {
        _words = loaded;
        currentIndex = 0;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  /// Advance to next word (wrap around at the end)
  void _showNextWord() {
    if (_words.isEmpty) return;
    setState(() {
      currentIndex = (currentIndex + 1) % _words.length;
    });
  }

  /// Go to previous word (wrap to last when at index 0)
  void _showPreviousWord() {
    if (_words.isEmpty) return;
    setState(() {
      currentIndex = (currentIndex - 1 + _words.length) % _words.length;
    });
  }

  /// Small visual hint in a Snackbar for swipe direction (optional)
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
    // Loading state
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wort des Tages')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Error state
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wort des Tages')),
        body: Center(child: Text('Error loading words:\n$_error')),
      );
    }

    // Empty data state (JSON loaded but no items)
    if (_words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wort des Tages')),
        body: const Center(child: Text('No words found in assets/words.json')),
      );
    }

    // Normal display state
    final word = _words[currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Wort des Tages')),

      // Keep your swipe gestures exactly as before
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              _showSwipeDirection("Right to Left");
              _showNextWord();
            } else if (details.primaryVelocity! > 0) {
              _showSwipeDirection("Left to Right");
              _showPreviousWord();
            }
          }
        },

        child: Stack(
          children: [
            // Scrollable content (unchanged layout & styles)
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Word + article
                  Text(
                    '${word.article} ${word.word}',
                    style: AppTextStyles.title,
                  ),

                  const SizedBox(height: 8),

                  // Meaning/translation
                  Text(
                    'Translation: ${word.meaning}',
                    style: AppTextStyles.translation,
                  ),

                  // Divider before example sentences
                  const Divider(height: 40, thickness: 1.2),

                  // Example sentences header
                  Text('Example Sentences:', style: AppTextStyles.subtitle),
                  const SizedBox(height: 12),

                  // Dynamically render ALL examples found in JSON.
                  // This replaces the fixed Present/Simple Past/Perfect widgets.
                  ...word.examples.entries.map((entry) {
                    final tense = entry.key;                    // e.g. "Present"
                    final germanSentence = entry.value;         // the DE sentence
                    final englishSentence =
                        word.translations[tense] ?? 'N/A';      // matching EN
                    return SentenceItem(
                      label: tense,
                      german: germanSentence,
                      english: englishSentence,
                    );
                  }),

                  const SizedBox(height: 80),

                  // Page counter (kept same style key you used)
                  Center(
                    child: Text(
                      'Word ${currentIndex + 1} of ${_words.length}',
                      style: AppTextStyles.pageCounter,
                    ),
                  ),

                  // Spacer so the bottom FAB doesn’t overlap text
                  const SizedBox(height: 120),
                ],
              ),
            ),

            // Swipe direction hint arrows (unchanged)
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

      // Fixed bottom button (unchanged style/position)
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

// Reusable widget for example sentences (unchanged)
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
