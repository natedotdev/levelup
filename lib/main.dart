import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levelup/theme/app_text_styles.dart';

// NEW: repo + models
import 'data/word_repository.dart';
import 'models/german_word.dart';

// NEW: separate onboarding screen
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const LevelUpApp());
}

// Main App entry
class LevelUpApp extends StatelessWidget {
  const LevelUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LevelUp',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RootScreen(), // decide onboarding or word screen
      debugShowCheckedModeBanner: false,
    );
  }
}

// -----------------------------------------------------------
// RootScreen → checks SharedPreferences
// If no level → show Onboarding
// If level exists → show WordScreen
// -----------------------------------------------------------
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  String? _level;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLevel();
  }

  Future<void> _loadLevel() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _level = prefs.getString('level');
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Loading state (first app start)
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If no level chosen → go to onboarding
    if (_level == null) {
      return OnboardingScreen(onLevelSelected: (level) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('level', level);
        setState(() => _level = level);
      });
    }

    // If level already chosen → go to words
    return WordScreen(level: _level!);
  }
}

// WordScreen → shows words filtered by chosen level
class WordScreen extends StatefulWidget {
  final String level;
  const WordScreen({super.key, required this.level});

  @override
  State<WordScreen> createState() => _WordScreenState();
}

class _WordScreenState extends State<WordScreen> {
  List<GermanWord> _words = [];
  int currentIndex = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  /// Load JSON + filter by level
  Future<void> _loadWords() async {
    try {
      final loaded = await WordRepository.loadWords(level: widget.level);
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

  /// Next word
  void _showNextWord() {
    if (_words.isEmpty) return;
    setState(() {
      currentIndex = (currentIndex + 1) % _words.length;
    });
  }

  /// Previous word
  void _showPreviousWord() {
    if (_words.isEmpty) return;
    setState(() {
      currentIndex = (currentIndex - 1 + _words.length) % _words.length;
    });
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

    // Empty state
    if (_words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wort des Tages')),
        body: const Center(child: Text('No words found for this level')),
      );
    }

    // Normal state
    final word = _words[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Wort des Tages – ${widget.level}')),

      // Wrap entire screen with GestureDetector → full screen swipe works
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              _showNextWord();
            } else if (details.primaryVelocity! > 0) {
              _showPreviousWord();
            }
          }
        },

        // Scrollable content
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Word
              Text('${word.article} ${word.word}', style: AppTextStyles.title),

              const SizedBox(height: 8),

              // Translation
              Text('Translation: ${word.meaning}', style: AppTextStyles.translation),

              const Divider(height: 40, thickness: 1.2),

              // Examples
              Text('Example Sentences:', style: AppTextStyles.subtitle),
              const SizedBox(height: 12),

              ...word.examples.entries.map((entry) {
                final tense = entry.key;
                final germanSentence = entry.value;
                final englishSentence = word.translations[tense] ?? 'N/A';
                return SentenceItem(
                  label: tense,
                  german: germanSentence,
                  english: englishSentence,
                );
              }),

              const SizedBox(height: 80),

              // Page counter
              Center(
                child: Text(
                  'Word ${currentIndex + 1} of ${_words.length}',
                  style: AppTextStyles.pageCounter,
                ),
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),

      // Bottom button
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

// Reusable Example Sentence widget
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
