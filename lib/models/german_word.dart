/// A model class that represents one German word with its article, meaning,
/// level, and **groups** of example sentences (each group contains
/// Present, Simple Past, Perfect with both German + English).
class GermanWord {
  final String level;     // e.g., "A1.1"
  final String article;   // e.g., "der", "die", "das"
  final String word;      // e.g., "Hund"
  final String meaning;   // English meaning, e.g., "dog"

  /// Multiple example groups, each with the three tenses.
  final List<ExampleGroup> exampleGroups;

  /// Constructor: creates a GermanWord object
  GermanWord({
    required this.level,
    required this.article,
    required this.word,
    required this.meaning,
    required this.exampleGroups,
  });

  /// Factory constructor to create a GermanWord object from JSON map.
  ///
  /// Supports BOTH shapes:
  /// 1) Preferred:
  ///    { "exampleGroups": [ { "Present": {...}, "Simple Past": {...}, "Perfect": {...} }, ... ] }
  ///
  /// 2) Your current assets/words.json:
  ///    { "examples": [
  ///        [ {label:'Present',german:'...',english:'...'},
  ///          {label:'Simple Past',...},
  ///          {label:'Perfect',...} ],
  ///        ...
  ///      ] }
  factory GermanWord.fromJson(Map<String, dynamic> json) {
    List<ExampleGroup> groups = [];

    // Preferred: exampleGroups
    final eg = json['exampleGroups'];
    if (eg is List) {
      for (final g in eg) {
        if (g is Map<String, dynamic>) {
          groups.add(ExampleGroup.fromJson(g));
        }
      }
    }
    // Back-compat: examples (list of lists with {label,german,english})
    else if (json['examples'] is List) {
      final rawGroups = (json['examples'] as List);
      for (final g in rawGroups) {
        if (g is List) {
          ExampleSentence? present;
          ExampleSentence? simplePast;
          ExampleSentence? perfect;

          for (final s in g) {
            if (s is Map<String, dynamic>) {
              final lbl = (s['label'] ?? '').toString().trim();
              final sent = ExampleSentence.fromJson(s);
              if (lbl == 'Present') {
                present = sent;
              } else if (lbl == 'Simple Past') {
                simplePast = sent;
              } else if (lbl == 'Perfect') {
                perfect = sent;
              }
            }
          }

          if (present != null && simplePast != null && perfect != null) {
            groups.add(ExampleGroup(
              present: present,
              simplePast: simplePast,
              perfect: perfect,
            ));
          }
        }
      }
    }

    return GermanWord(
      level: (json['level'] ?? 'A1.1').toString(),
      article: (json['article'] ?? '').toString(),
      word: (json['word'] ?? '').toString(),
      meaning: (json['meaning'] ?? '').toString(),
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

  factory ExampleGroup.fromJson(Map<String, dynamic> json) {
    return ExampleGroup(
      present: ExampleSentence.fromJson(json['Present'] ?? const {}),
      simplePast: ExampleSentence.fromJson(json['Simple Past'] ?? const {}),
      perfect: ExampleSentence.fromJson(json['Perfect'] ?? const {}),
    );
  }
}

/// Single example sentence with its English translation.
class ExampleSentence {
  final String german;
  final String english;

  ExampleSentence({required this.german, required this.english});

  factory ExampleSentence.fromJson(Map<String, dynamic> json) {
    return ExampleSentence(
      german: (json['german'] ?? '').toString(),
      english: (json['english'] ?? '').toString(),
    );
  }
}
