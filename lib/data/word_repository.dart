import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/german_word.dart';

/// WordRepository is responsible for loading and preparing words
/// from the local JSON file (`assets/words.json`).
///
/// JSON shape (top-level grouped by level):
/// {
///   "A1.1": [ { word... }, { word... } ],
///   "A1.2": [ ... ],
///   ...
/// }
class WordRepository {
  static Future<List<GermanWord>> loadWords({String? level}) async {
    // Load the raw string from assets/words.json
    final String jsonString = await rootBundle.loadString('assets/words.json');

    // Decode to Map<String, dynamic>
    final Map<String, dynamic> data = json.decode(jsonString);

    // Option 1: Only one level requested → just parse that list
    if (level != null && data[level] is List) {
      final list = (data[level] as List)
          .map((item) => GermanWord.fromJson({...item, 'level': level}))
          .toList();
      return list;
    }

    // Option 2: Parse ALL levels into one flat list
    final List<GermanWord> all = [];
    data.forEach((lvl, arr) {
      if (arr is List) {
        for (final item in arr) {
          all.add(GermanWord.fromJson({...item, 'level': lvl}));
        }
      }
    });
    return all;
  }
}
