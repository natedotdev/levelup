import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/german_word.dart';

/// WordRepository is responsible for loading and preparing words
/// from the local JSON file (`assets/words.json`).
///
/// It hides the details of reading the asset and parsing JSON,
/// so the rest of the app can just call `WordRepository.loadWords()`
/// and get a list of `GermanWord` objects.
class WordRepository {
  /// Load words from assets/words.json
  ///
  /// - If [level] is not provided (null), it will return *all words*.
  /// - If [level] is provided (e.g., "A1.1"), it will return *only words*
  ///   that match that level.
  static Future<List<GermanWord>> loadWords({String? level}) async {
    // Load the raw string from assets/words.json
    final String jsonString = await rootBundle.loadString('assets/words.json');

    // Decode the raw string into a List of Maps (dynamic JSON objects)
    final List<dynamic> jsonData = json.decode(jsonString);

    // Convert each map into a GermanWord object
    final all = jsonData.map((item) => GermanWord.fromJson(item)).toList();

    // If no level filter is provided → return all words
    if (level == null) return all;

    // Otherwise, filter the words by the given level
    return all.where((w) => w.level == level).toList();
  }
}
