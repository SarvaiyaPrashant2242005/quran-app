import 'package:flutter/material.dart';
import 'package:quran_verse_admin/models/verse.dart';
import 'package:quran_verse_admin/services/firestore_service.dart';

class VerseController extends ChangeNotifier {
  VerseData _data = VerseData.empty();
  bool _loading = false;
  String? _error;

  VerseData get data => _data;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> init() async {
    _setLoading(true);
    try {
      _data = await FirestoreService.instance.fetchVerseData();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  Future<void> addVerse(Verse verse) async {
    _setLoading(true);
    try {
      _data = await FirestoreService.instance.addVerse(_data, verse);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateVerse(int index, Verse verse) async {
    _setLoading(true);
    try {
      _data = await FirestoreService.instance.updateVerse(_data, index, verse);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteVerse(int index) async {
    _setLoading(true);
    try {
      _data = await FirestoreService.instance.deleteVerse(_data, index);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> save() async {
    await FirestoreService.instance.save(_data);
  }
}
