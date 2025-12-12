import 'dart:convert';

class Verse {
  final String rank;
  final String word;
  final String pronounce;
  final String meaningEn;
  final String meaningUr;
  final String times;
  final String arabic;
  final String english;
  final String urdu;

  Verse({
    required this.rank,
    required this.word,
    required this.pronounce,
    required this.meaningEn,
    required this.meaningUr,
    required this.times,
    required this.arabic,
    required this.english,
    required this.urdu,
  });

  factory Verse.fromJson(Map<String, dynamic> json) => Verse(
        rank: (json['rank'] ?? '').toString(),
        word: (json['word'] ?? '').toString(),
        pronounce: (json['pronounce'] ?? '').toString(),
        meaningEn: (json['meaning_en'] ?? '').toString(),
        meaningUr: (json['meaning_ur'] ?? '').toString(),
        times: (json['times'] ?? '').toString(),
        arabic: (json['arabic'] ?? '').toString(),
        english: (json['english'] ?? '').toString(),
        urdu: (json['urdu'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'word': word,
        'pronounce': pronounce,
        'meaning_en': meaningEn,
        'meaning_ur': meaningUr,
        'times': times,
        'arabic': arabic,
        'english': english,
        'urdu': urdu,
      };
}

class VerseData {
  final int totalWords;
  final List<Verse> verses;

  VerseData({required this.totalWords, required this.verses});

  factory VerseData.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) {
        final i = int.tryParse(v);
        if (i != null) return i;
        final d = double.tryParse(v);
        if (d != null) return d.toInt();
      }
      return 0;
    }

    List<dynamic> ensureList(dynamic v) {
      if (v == null) return const [];
      if (v is List) return v;
      if (v is String) {
        try {
          final decoded = jsonDecode(v);
          if (decoded is List) return decoded;
        } catch (_) {}
      }
      return const [];
    }

    final total = parseInt(json.containsKey('total_words')
        ? json['total_words']
        : json['totalWords']);
    final list = ensureList(json['verses'])
        .map((e) => Verse.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return VerseData(totalWords: total, verses: list);
  }

  Map<String, dynamic> toJson() => {
        'total_words': totalWords,
        'verses': verses.map((e) => e.toJson()).toList(),
      };

  static VerseData fromJsonString(String source) =>
      VerseData.fromJson(json.decode(source) as Map<String, dynamic>);
  String toJsonString() => json.encode(toJson());
}
