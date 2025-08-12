import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/german_word.dart';

/// This class handles loading the German words from a local JSON file
class WordRepository {
  /// Loads JSON file from assets and converts it into a List of GermanWord objects
  static Future<List<GermanWord>> loadWords() async {
    // Step 1: Load the raw JSON string from the assets folder
    final jsonString = await rootBundle.loadString('assets/words.json');

    // Step 2: Decode the JSON string into a List of dynamic maps
    final List<dynamic> jsonResponse = json.decode(jsonString);

    // Step 3: Convert each map into a GermanWord object
    return jsonResponse.map((data) => GermanWord.fromJson(data)).toList();
  }
}
