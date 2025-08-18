import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levelup/theme/app_text_styles.dart';

// NEW: repo + models
import 'data/word_repository.dart';
import 'models/german_word.dart';

// NEW: separate onboarding screen
import 'screens/onboarding_screen.dart';

// Settings screen
import 'screens/settings_screen.dart';

void main() {
  runApp(const LevelUpApp());
}

// -----------------------------------------------------------
// Main App entry
// -----------------------------------------------------------
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

  // Read the saved level once at startup
  Future<void> _loadLevel() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return; // guard before setState after an await
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
        if (!mounted) return;
        setState(() => _level = level);
      });
    }

    // If level already chosen → go to words
    return WordScreen(level: _level!);
  }
}

// -----------------------------------------------------------
// WordScreen → shows words filtered by chosen level
// - Unified AppBar (same in all states) with a Settings button
// - Swipe left/right to switch words
// - "Next Word" button fixed at the bottom
// -----------------------------------------------------------
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

  /// Load JSON + filter by level once per screen instance
  Future<void> _loadWords() async {
    try {
      final loaded = await WordRepository.loadWords(level: widget.level);
      if (!mounted) return;
      setState(() {
        _words = loaded;
        currentIndex = 0;   // always start at first item for a level
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  /// Next word (wrap around)
  void _showNextWord() {
    if (_words.isEmpty) return;
    setState(() {
      currentIndex = (currentIndex + 1) % _words.length;
    });
  }

  /// Previous word (wrap around)
  void _showPreviousWord() {
    if (_words.isEmpty) return;
    setState(() {
      currentIndex = (currentIndex - 1 + _words.length) % _words.length;
    });
  }

  /// One place to define the AppBar so it is consistent across states
  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Wort des Tages – ${widget.level}'),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
          onPressed: () async {
            // 1) Navigate to Settings (await result)
            final newLevel = await Navigator.push<String>(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );

            // 2) After an await, always check mounted before using context/state
            if (!mounted) return;

            // 3) Persist & rebuild if level changed
            if (newLevel != null && newLevel != widget.level) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('level', newLevel);

              if (!mounted) return; // extra safety before navigation
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => WordScreen(level: newLevel)),
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build one Scaffold with the **same AppBar** everywhere
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
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

  /// Body content split out for readability; we use the same AppBar for all cases
  Widget _buildBody(BuildContext context) {
    // Loading state
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (_error != null) {
      return Center(child: Text('Error loading words:\n$_error'));
    }

    // Empty state
    if (_words.isEmpty) {
      return const Center(child: Text('No words found for this level'));
    }

    // Normal state
    final word = _words[currentIndex];

    return GestureDetector(
      behavior: HitTestBehavior.opaque, // full-screen swipe area
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < 0) {
            _showNextWord();      // right-to-left
          } else if (details.primaryVelocity! > 0) {
            _showPreviousWord();  // left-to-right
          }
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Word + article
            Text('${word.article} ${word.word}', style: AppTextStyles.title),

            const SizedBox(height: 8),

            // Meaning/translation
            Text('Translation: ${word.meaning}', style: AppTextStyles.translation),

            // Divider before example sentences
            const Divider(height: 40, thickness: 1.2),

            // Example sentences header
            Text('Example Sentences:', style: AppTextStyles.subtitle),
            const SizedBox(height: 12),

            // Render all available tenses from JSON
            ...word.examples.entries.map((entry) {
              final tense = entry.key;                // e.g., "Present"
              final germanSentence = entry.value;     // current schema: String
              final englishSentence =
                  word.translations[tense] ?? 'N/A';  // match EN by tense
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

            // Spacer so the bottom button doesn’t overlap
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------
/* Reusable Example Sentence widget */
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
