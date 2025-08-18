import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/german_word.dart';

/// WordRepository is responsible for loading and preparing words
/// from the local JSON file (`assets/words.json`).
///
/// JSON SHAPE (NEW):
/// {
///   "A1.1": [ {word}, {word}, ... ],
///   "A1.2": [ {word}, ... ],
///   ...
/// }
///
/// - If [level] is provided, we only parse that level's list.
/// - If [level] is null, we flatten ALL levels into one List\<GermanWord>.
class WordRepository {
  /// Load words from assets/words.json
  ///
  /// - If [level] is not provided (null), it will return *all words* across all levels.
  /// - If [level] is provided (e.g., "A1.1"), it will return *only words*
  ///   that match that level.
  static Future<List<GermanWord>> loadWords({String? level}) async {
    // Load the raw string from assets/words.json
    final String jsonString = await rootBundle.loadString('assets/words.json');

    // Decode into a Map<String, dynamic> (levels → list of words)
    final Map<String, dynamic> root = json.decode(jsonString);

    // Helper that converts a raw word map into GermanWord with the provided level key
    List<GermanWord> parseWordsForLevel(String lvl) {
      final list = root[lvl];
      if (list is List) {
        return list
            .map<GermanWord>((w) => GermanWord.fromJsonWithLevel(
                  Map<String, dynamic>.from(w as Map),
                  lvl,
                ))
            .toList();
      }
      return <GermanWord>[];
    }

    if (level != null) {
      // Only parse the requested level
      return parseWordsForLevel(level);
    }

    // No level filter → flatten ALL levels
    final List<GermanWord> all = [];
    for (final entry in root.entries) {
      final lvl = entry.key;
      final parsed = parseWordsForLevel(lvl);
      all.addAll(parsed);
    }
    return all;
  }
}
