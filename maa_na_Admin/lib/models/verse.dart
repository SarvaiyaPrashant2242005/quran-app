// Model for Verse and VerseData

class Verse {
  final String rank; // e.g. "#1"
  final String word; // e.g. "مِن"
  final String pronounce; // e.g. "Min"
  final String meaningEn; // e.g. "From"
  final String meaningUr; // e.g. "Se"
  final String times; // e.g. "3226 Times"
  final String arabic;
  final String english;
  final String urdu;

  const Verse({
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

  Verse copyWith({
    String? rank,
    String? word,
    String? pronounce,
    String? meaningEn,
    String? meaningUr,
    String? times,
    String? arabic,
    String? english,
    String? urdu,
  }) {
    return Verse(
      rank: rank ?? this.rank,
      word: word ?? this.word,
      pronounce: pronounce ?? this.pronounce,
      meaningEn: meaningEn ?? this.meaningEn,
      meaningUr: meaningUr ?? this.meaningUr,
      times: times ?? this.times,
      arabic: arabic ?? this.arabic,
      english: english ?? this.english,
      urdu: urdu ?? this.urdu,
    );
  }

  Map<String, dynamic> toMap() {
    return {
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

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      rank: map['rank']?.toString() ?? '',
      word: map['word']?.toString() ?? '',
      pronounce: map['pronounce']?.toString() ?? '',
      meaningEn: map['meaning_en']?.toString() ?? '',
      meaningUr: map['meaning_ur']?.toString() ?? '',
      times: map['times']?.toString() ?? '',
      arabic: map['arabic']?.toString() ?? '',
      english: map['english']?.toString() ?? '',
      urdu: map['urdu']?.toString() ?? '',
    );
  }
}

class VerseData {
  final int totalWords;
  final List<Verse> verses;

  const VerseData({required this.totalWords, required this.verses});

  VerseData copyWith({int? totalWords, List<Verse>? verses}) =>
      VerseData(totalWords: totalWords ?? this.totalWords, verses: verses ?? this.verses);

  Map<String, dynamic> toMap() => {
        'total_words': totalWords,
        'verses': verses.map((v) => v.toMap()).toList(),
      };

  factory VerseData.empty() => const VerseData(totalWords: 0, verses: []);

  factory VerseData.fromMap(Map<String, dynamic>? map) {
    if (map == null) return VerseData.empty();
    final rawVerses = (map['verses'] as List?) ?? [];
    final verses = rawVerses.map((e) => Verse.fromMap(Map<String, dynamic>.from(e as Map))).toList();
    final total = map['total_words'] is int
        ? map['total_words'] as int
        : int.tryParse(map['total_words']?.toString() ?? '') ?? verses.length;
    return VerseData(totalWords: total, verses: verses);
  }

  static List<Verse> withRanks(List<Verse> items) {
    return List.generate(items.length, (i) => items[i].copyWith(rank: '#${i + 1}'));
  }
}
