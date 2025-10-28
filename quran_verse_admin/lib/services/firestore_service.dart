import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quran_verse_admin/models/verse.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('verse_data');
  DocumentReference<Map<String, dynamic>> get _doc => _col.doc('main');

  String _norm(String s) => s.trim().toLowerCase();

  Future<VerseData> fetchVerseData() async {
    final snap = await _doc.get();
    if (!snap.exists) {
      return VerseData.empty();
    }
    final data = snap.data();
    final content = data?['data'] as Map<String, dynamic>?;
    final parsed = VerseData.fromMap(content);
    // auto-correct rank order and total_words
    final normalized = parsed.copyWith(
      totalWords: parsed.verses.length,
      verses: VerseData.withRanks(parsed.verses),
    );
    await _save(normalized); // keep the database consistent
    return normalized;
  }

  Future<VerseData> addVerse(VerseData current, Verse verse) async {
    // prevent duplicates by word or pronounce (case-insensitive)
    final w = _norm(verse.word);
    final p = _norm(verse.pronounce);
    final exists = current.verses.any((v) => _norm(v.word) == w || _norm(v.pronounce) == p);
    if (exists) {
      throw DuplicateWordException('Word or pronounce already exists');
    }
    final updatedList = List<Verse>.from(current.verses)..add(verse);
    final normalized = VerseData(
      totalWords: updatedList.length,
      verses: VerseData.withRanks(updatedList),
    );
    await _save(normalized);
    return normalized;
  }

  Future<VerseData> updateVerse(VerseData current, int index, Verse verse) async {
    final updated = List<Verse>.from(current.verses);
    if (index < 0 || index >= updated.length) return current;
    // prevent duplicates excluding current index
    final w = _norm(verse.word);
    final p = _norm(verse.pronounce);
    final exists = updated.asMap().entries.any((e) =>
        e.key != index && (_norm(e.value.word) == w || _norm(e.value.pronounce) == p));
    if (exists) {
      throw DuplicateWordException('Word or pronounce already exists');
    }
    updated[index] = verse;
    final normalized = VerseData(
      totalWords: updated.length,
      verses: VerseData.withRanks(updated),
    );
    await _save(normalized);
    return normalized;
  }

  Future<VerseData> deleteVerse(VerseData current, int index) async {
    final updated = List<Verse>.from(current.verses);
    if (index < 0 || index >= updated.length) return current;
    updated.removeAt(index);
    final normalized = VerseData(
      totalWords: updated.length,
      verses: VerseData.withRanks(updated),
    );
    await _save(normalized);
    return normalized;
  }

  Future<void> _save(VerseData data) async {
    await _doc.set({'data': data.toMap()}, SetOptions(merge: true));
  }

  Future<void> save(VerseData data) => _save(data);
}

class DuplicateWordException implements Exception {
  final String message;
  DuplicateWordException(this.message);
  @override
  String toString() => message;
}
