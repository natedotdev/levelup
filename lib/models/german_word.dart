/// A model class that represents one German word with its article, meaning,
/// level, and **groups** of example sentences (each group contains
/// Present, Simple Past, Perfect with both German + English).
class GermanWord {
  final String level;     // e.g., "A1.1"
  final String article;   // "der", "die", "das"
  final String word;      // e.g., "Tisch"
  final String meaning;   // e.g., "table"

  /// Multiple example groups, each with the three tenses.
  final List<ExampleGroup> exampleGroups;

  GermanWord({
    required this.level,
    required this.article,
    required this.word,
    required this.meaning,
    required this.exampleGroups,
  });

  /// Factory that matches the **current** words.json shape:
  /// {
  ///   "article": "der",
  ///   "word": "Tisch",
  ///   "meaning": "table",
  ///   "examples": [
  ///     [ {label:"Present",german:"...",english:"..."}, {label:"Simple Past",...}, {label:"Perfect",...} ],
  ///     [ ... another group ... ],
  ///     ...
  ///   ]
  /// }
  factory GermanWord.fromJson(Map<String, dynamic> json) {
    final raw = json['examples'];
    final List<ExampleGroup> groups = [];

    if (raw is List) {
      for (final group in raw) {
        // Each group is expected to be a List of 3 maps with label/german/english
        if (group is List) {
          ExampleSentence? present;
          ExampleSentence? simplePast;
          ExampleSentence? perfect;

          for (final item in group) {
            if (item is Map<String, dynamic>) {
              final label = (item['label'] ?? '').toString().trim();
              final sent = ExampleSentence.fromJson(item);
              if (label == 'Present') {
                present = sent;
              } else if (label == 'Simple Past') {
                simplePast = sent;
              } else if (label == 'Perfect') {
                perfect = sent;
              }
            }
          }

          // Only add if we actually found at least one sentence
          if (present != null || simplePast != null || perfect != null) {
            groups.add(ExampleGroup(
              present: present ?? const ExampleSentence(german: '', english: ''),
              simplePast: simplePast ?? const ExampleSentence(german: '', english: ''),
              perfect: perfect ?? const ExampleSentence(german: '', english: ''),
            ));
          }
        }
      }
    }

    return GermanWord(
      level: json['level'] ?? 'A1.1',
      article: json['article'] ?? '',
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      exampleGroups: groups,
    );
  }
}

/// One group of examples (Present / Simple Past / Perfect).
class ExampleGroup {
  final ExampleSentence present;
  final ExampleSentence simplePast;
  final ExampleSentence perfect;

  ExampleGroup({
    required this.present,
    required this.simplePast,
    required this.perfect,
  });
}

/// Single example sentence with its English translation.
class ExampleSentence {
  final String german;
  final String english;

  const ExampleSentence({required this.german, required this.english});

  factory ExampleSentence.fromJson(Map<String, dynamic> json) {
    return ExampleSentence(
      german: (json['german'] ?? '').toString(),
      english: (json['english'] ?? '').toString(),
    );
  }
}
