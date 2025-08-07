class GermanWord {
  final String article;
  final String word;
  final String meaning;
  final Map<String, String> examples;
  final Map<String, String> translations;

  GermanWord({
    required this.article,
    required this.word,
    required this.meaning,
    required this.examples,
    required this.translations,
  });
}

final List<GermanWord> wordList = [
  GermanWord(
    article: 'das',
    word: 'Buch',
    meaning: 'book',
    examples: {
      'Present': 'Ich lese das Buch.',
      'Simple Past': 'Ich las das Buch.',
      'Perfect': 'Ich habe das Buch gelesen.',
    },
    translations: {
      'Present': 'I read the book.',
      'Simple Past': 'I read the book (past).',
      'Perfect': 'I have read the book.',
    },
  ),
  GermanWord(
    article: 'der',
    word: 'Hund',
    meaning: 'dog',
    examples: {
      'Present': 'Der Hund bellt laut.',
      'Simple Past': 'Der Hund bellte laut.',
      'Perfect': 'Der Hund hat laut gebellt.',
    },
    translations: {
      'Present': 'The dog barks loudly.',
      'Simple Past': 'The dog barked loudly.',
      'Perfect': 'The dog has barked loudly.',
    },
  ),
];
