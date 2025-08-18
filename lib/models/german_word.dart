/// A model class that represents one German word with its article, meaning,
/// example sentences (present, past, perfect), and English translations.
///
/// NEW (2025-08):
/// - JSON structure changed. Top-level is { "A1.1": [words...], ... }.
/// - Each word now has *example groups*: a List of groups,
///   each group contains 3 tenses (Present, Simple Past, Perfect),
///   and every tense bundles german+english together.
///   -> examplesGroups : List\<List\<ExampleItem>>
///
/// ExampleItem models one tense line inside a group.
class ExampleItem {
  final String label;   // e.g., "Present", "Simple Past", "Perfect"
  final String german;  // DE sentence
  final String english; // EN translation

  ExampleItem({
    required this.label,
    required this.german,
    required this.english,
  });

  factory ExampleItem.fromJson(Map<String, dynamic> json) {
    return ExampleItem(
      label: json['label'] ?? '',
      german: json['german'] ?? '',
      english: json['english'] ?? '',
    );
  }
}

/// One vocabulary entry (word + article + meaning + grouped examples)
class GermanWord {
  final String level;    // e.g., "A1.1"
  final String article;  // e.g., "der", "die", "das"
  final String word;     // e.g., "Hund"
  final String meaning;  // English meaning, e.g., "dog"

  /// NEW: List of example groups.
  /// Each group is a List\<ExampleItem> (usually 3 tenses).
  final List<List<ExampleItem>> examplesGroups;

  /// Constructor: creates a GermanWord object
  GermanWord({
    required this.level,
    required this.article,
    required this.word,
    required this.meaning,
    required this.examplesGroups,
  });

  /// Factory constructor to create a GermanWord object from JSON map
  /// when the level is already included in the map (older schema).
  factory GermanWord.fromJson(Map<String, dynamic> json) {
    // Backward-compat: if 'examples' is a Map<String,String>, convert it
    // into one single group of ExampleItems so older JSON still works.
    final examples = json['examples'];
    List<List<ExampleItem>> parsedGroups;

    if (examples is List) {
      // NEW schema: List of groups, each group is a List of maps
      parsedGroups = (examples)
          .map<List<ExampleItem>>((group) => (group as List)
              .map<ExampleItem>((e) => ExampleItem.fromJson(e))
              .toList())
          .toList();
    } else if (examples is Map) {
      // OLD schema fallback (one group, label->german; translations separate)
      final translations = Map<String, dynamic>.from(json['translations'] ?? {});
      final map = Map<String, dynamic>.from(examples);
      final items = map.entries.map((entry) {
        final label = entry.key;
        final german = entry.value?.toString() ?? '';
        final english = translations[label]?.toString() ?? 'N/A';
        return ExampleItem(label: label, german: german, english: english);
      }).toList();
      parsedGroups = [items];
    } else {
      parsedGroups = [];
    }

    return GermanWord(
      level: json['level'] ?? 'A1.1',
      article: json['article'] ?? '',
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      examplesGroups: parsedGroups,
    );
  }

  /// NEW: Factory for the new schema where the *level key* is provided
  /// by the repository (top-level JSON key), not inside the word map.
  factory GermanWord.fromJsonWithLevel(Map<String, dynamic> json, String level) {
    // We inject the level into the map so fromJson can stay simple.
    return GermanWord.fromJson({
      ...json,
      'level': level,
    });
  }
}
