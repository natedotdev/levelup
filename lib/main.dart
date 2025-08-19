import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TEXT STYLES (your existing set)
import 'package:levelup/theme/app_text_styles.dart';

// REPO + MODELS (new exampleGroups shape)
import 'data/word_repository.dart';
import 'models/german_word.dart';

// ONBOARDING (unchanged API: returns chosen level)
import 'screens/onboarding_screen.dart';

// SETTINGS HOME (premium-style page: theme + level)
import 'screens/settings_home.dart';

// THEME
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

/// -----------------------------------------------------------
/// App bootstrap: ensure bindings, load ThemeController, then run
/// -----------------------------------------------------------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.init(); // load saved theme before runApp
  runApp(const LevelUpApp());
}

/// -----------------------------------------------------------
/// Main App entry (theme-aware)
/// -----------------------------------------------------------
class LevelUpApp extends StatelessWidget {
  const LevelUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // Rebuild MaterialApp when theme mode changes
      animation: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'LevelUp',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,        // premium light
          darkTheme: AppTheme.dark,     // premium dark
          themeMode: ThemeController.instance.value,
          home: const RootScreen(),     // decide onboarding or word screen
        );
      },
    );
  }
}

/// -----------------------------------------------------------
/// RootScreen → checks SharedPreferences
/// If no level → show Onboarding
/// If level exists → show WordScreen
/// -----------------------------------------------------------
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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

/// -----------------------------------------------------------
/// WordScreen → shows words filtered by chosen level
/// - Premium AppBar with Settings (⚙️)
/// - Swipe left/right to switch words
/// - Swipe up/down OR tap button to switch **example group**
/// - Content uses modern rounded **Cards**
/// - “Next Word” button fixed at the bottom
/// -----------------------------------------------------------
class WordScreen extends StatefulWidget {
  final String level;
  const WordScreen({super.key, required this.level});

  @override
  State<WordScreen> createState() => _WordScreenState();
}

class _WordScreenState extends State<WordScreen> {
  List<GermanWord> _words = [];
  int currentIndex = 0;     // which word we’re showing right now
  int _exampleIndex = 0;    // which example group of the current word
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
        _exampleIndex = 0;  // and the first example group
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
      _exampleIndex = 0; // reset example group when word changes
    });
  }

  /// Previous word (wrap around)
  void _showPreviousWord() {
    if (_words.isEmpty) return;
    setState(() {
      currentIndex = (currentIndex - 1 + _words.length) % _words.length;
      _exampleIndex = 0; // reset example group when word changes
    });
  }

  /// Next example group (wrap around)
  void _nextExample() {
    final groups = _words[currentIndex].exampleGroups;
    if (groups.isEmpty) return;
    setState(() {
      _exampleIndex = (_exampleIndex + 1) % groups.length;
    });
  }

  /// One place to define the AppBar so it is consistent across states
  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Wort des Tages – ${widget.level}'),
      actions: [
        // Theme toggle
        IconButton(
          tooltip: 'Toggle theme',
          icon: Icon(
            ThemeController.instance.value == ThemeMode.light
                ? Icons.dark_mode
                : Icons.light_mode,
          ),
          onPressed: ThemeController.instance.toggle,
        ),
        // Settings (⚙️) → premium settings home (theme + level)
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
          onPressed: () async {
            // Open the new settings hub (returns a picked level if changed)
            final newLevel = await Navigator.push<String>(
              context,
              MaterialPageRoute(builder: (_) => const SettingsHomeScreen()),
            );
            if (!mounted) return;

            if (newLevel != null && newLevel != widget.level) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('level', newLevel);

              if (!mounted) return;
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    final groups = word.exampleGroups;
    final bool hasGroups = groups.isNotEmpty;
    final group = hasGroups ? groups[_exampleIndex] : null;

    // GestureDetector on the whole screen:
    // - horizontal → change word
    // - vertical   → change example group
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // full-screen swipe area, no dead zones
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < 0) {
            _showNextWord();      // right-to-left
          } else if (details.primaryVelocity! > 0) {
            _showPreviousWord();  // left-to-right
          }
        }
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          _nextExample(); // swipe up/down → next example group
        }
      },

      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================================================
            // Word Card (title + translation) — premium rounded card
            // =========================================================
            Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${word.article} ${word.word}', style: AppTextStyles.title),
                    const SizedBox(height: 8),
                    Text('Translation: ${word.meaning}',
                        style: AppTextStyles.translation),
                  ],
                ),
              ),
            ),

            // =========================================================
            // Example Card (header + current example group)
            // =========================================================
            Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header + example group counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Example Sentences:', style: AppTextStyles.subtitle),
                        if (hasGroups)
                          Text(
                            'Example ${_exampleIndex + 1} of ${groups.length}',
                            style: AppTextStyles.subtitle,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tip: swipe up/down for next example group',
                      style: AppTextStyles.exampleEnglish,
                    ),
                    const SizedBox(height: 12),

                    if (!hasGroups) ...[
                      const Text('No example groups found'),
                    ] else ...[
                      SentenceItem(
                        label: 'Present',
                        german: group!.present.german,
                        english: group.present.english,
                      ),
                      SentenceItem(
                        label: 'Simple Past',
                        german: group.simplePast.german,
                        english: group.simplePast.english,
                      ),
                      SentenceItem(
                        label: 'Perfect',
                        german: group.perfect.german,
                        english: group.perfect.english,
                      ),

                      const SizedBox(height: 10),

                      // Next Example (small pill button in the card)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _nextExample,
                          icon: const Icon(Icons.south),
                          label: const Text('Next Example'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

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

/// -----------------------------------------------------------
/// Reusable Example Sentence widget (unchanged)
/// -----------------------------------------------------------
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
