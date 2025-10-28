import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/verse_data.dart';

class LocalDataService {
  static const String assetPath = 'assets/data.json';
  static const String prefsKey = 'verse_data_json';
  static const String learnedKey = 'learned_indices';
  static const String lastIndexKey = 'last_index';

  Future<bool> localExists() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(prefsKey);
  }

  // Seed local file from bundled asset if missing
  Future<void> ensureSeeded() async {
    final exists = await localExists();
    if (!exists) {
      final assetStr = await rootBundle.loadString(assetPath);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefsKey, assetStr);
    }
  }

  // Force reset local file from asset
  Future<void> resetFromAsset() async {
    final assetStr = await rootBundle.loadString(assetPath);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsKey, assetStr);
  }

  Future<VerseData> readLocal() async {
    await ensureSeeded();
    final prefs = await SharedPreferences.getInstance();
    String? content = prefs.getString(prefsKey);
    if (content == null || content.trim().isEmpty || content.trim() == '{}') {
      // fallback to asset
      final assetStr = await rootBundle.loadString(assetPath);
      await prefs.setString(prefsKey, assetStr);
      content = assetStr;
    }
    return VerseData.fromJson(json.decode(content) as Map<String, dynamic>);
  }

  Future<void> writeLocal(VerseData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsKey, json.encode(data.toJson()));
  }

  Future<int> getLocalTotalWords() async {
    try {
      final data = await readLocal();
      return data.totalWords;
    } catch (_) {
      return 0;
    }
  }

  // Learning progress helpers
  Future<Set<int>> loadLearnedIndices() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(learnedKey) ?? const <String>[];
    return list
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .toSet();
  }

  Future<void> saveLearnedIndices(Set<int> indices) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      learnedKey,
      indices.map((e) => e.toString()).toList(),
    );
  }

  Future<int?> loadLastIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final i = prefs.getInt(lastIndexKey);
    return i;
  }

  Future<void> saveLastIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(lastIndexKey, index);
  }

  Future<void> resetLearningProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(learnedKey);
    await prefs.remove(lastIndexKey);
  }
}
