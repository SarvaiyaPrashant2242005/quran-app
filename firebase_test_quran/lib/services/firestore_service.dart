import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/verse_data.dart';

class FirestoreService {
  Future<VerseData?> fetchRemoteData() async {
    final db = FirebaseFirestore.instance;
    final doc = await db
        .collection('verse_data')
        .doc('main')
        .get(const GetOptions(source: Source.server));
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;

    // Handle three cases:
    // 1) data field is a Map (preferred)
    // 2) data field is a JSON String (decode)
    // 3) whole document itself is the structure
    Map<String, dynamic>? map;

    final dynamic inner = data['data'];
    if (inner is Map<String, dynamic>) {
      map = Map<String, dynamic>.from(inner);
    } else if (inner is String) {
      try {
        final decoded = json.decode(inner);
        if (decoded is Map<String, dynamic>) {
          map = decoded;
        } else {
          return null; // invalid JSON structure
        }
      } catch (_) {
        return null; // invalid JSON string
      }
    } else if (data.containsKey('total_words') || data.containsKey('verses')) {
      // Document itself is the structure
      map = Map<String, dynamic>.from(data);
    } else {
      // Unknown structure
      return null;
    }

    return VerseData.fromJson(map);
  }
}
