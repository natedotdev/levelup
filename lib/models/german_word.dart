  /// A model class that represents one German word with its article, meaning,
  /// example sentences (present, past, perfect), and English translations.
  class GermanWord {
    final String level;             // e.g., "A1.1"
    final String article; // e.g., "der", "die", "das"
    final String word; // e.g., "Hund"
    final String meaning; // English meaning, e.g., "dog"

    /// Example sentences in different tenses
    /// Keys: "Present", "Simple Past", "Perfect"
    final Map<String, String> examples;

    /// English translations for each example sentence
    final Map<String, String> translations;

    /// Constructor: creates a GermanWord object
    GermanWord({
      required this.level,
      required this.article,
      required this.word,
      required this.meaning,
      required this.examples,
      required this.translations,
    });

    /// Factory constructor to create a GermanWord object from JSON map
    factory GermanWord.fromJson(Map<String, dynamic> json) {
      return GermanWord(
        level: json['level'] ?? 'A1.1',
        article: json['article'] ?? '',
        word: json['word'] ?? '',
        meaning: json['meaning'] ?? '',
        examples: Map<String, String>.from(json['examples'] ?? {}),
        translations: Map<String, String>.from(json['translations'] ?? {}),
      );
    }
  }
