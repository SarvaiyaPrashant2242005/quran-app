import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_verse_admin/controllers/verse_controller.dart';
import 'package:quran_verse_admin/models/verse.dart';
import 'package:quran_verse_admin/widgets/app_background.dart';
import 'package:quran_verse_admin/services/firestore_service.dart';
import 'package:quran_verse_admin/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rank = TextEditingController();
  final _word = TextEditingController();
  final _wordNode = FocusNode();
  final _pronounce = TextEditingController();
  final _meaningEn = TextEditingController();
  final _meaningUr = TextEditingController();
  final _times = TextEditingController();
  final _arabic = TextEditingController();
  final _english = TextEditingController();
  final _urdu = TextEditingController();

  @override
  void dispose() {
    _rank.dispose();
    _word.dispose();
    _wordNode.dispose();
    _pronounce.dispose();
    _meaningEn.dispose();
    _meaningUr.dispose();
    _times.dispose();
    _arabic.dispose();
    _english.dispose();
    _urdu.dispose();
    super.dispose();
  }

  void _clear() {
    _rank.clear();
    _word.clear();
    _pronounce.clear();
    _meaningEn.clear();
    _meaningUr.clear();
    _times.clear();
    _arabic.clear();
    _english.clear();
    _urdu.clear();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VerseController>();
    // Autofill rank based on current count, always kept in sync
    _rank.text = '#${controller.data.verses.length + 1}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: AppBackground(
        child: controller.loading
            ? Center(child: Image.asset('assets/images/loader.gif', height: 64))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 3,
                      color: Colors.black.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _text(
                                'Rank (auto-filled)',
                                _rank,
                                readOnly: true,
                                suffixText: '#${controller.data.verses.length + 1}',
                              ),
                              _text('Word (Arabic)', _word, required: true, focusNode: _wordNode),
                              _text('Pronounce (e.g. Min)', _pronounce, required: true),
                              _text('Meaning (EN)', _meaningEn, required: true),
                              _text('Meaning (UR)', _meaningUr, required: true),
                              _text('Times (e.g. 3226 Times)', _times, required: true),
                              _text('Arabic Verse', _arabic, required: true, maxLines: 3),
                              _text('English', _english, required: true, maxLines: 3),
                              _text('Urdu', _urdu, required: true, maxLines: 3),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: controller.loading
                                        ? null
                                        : () async {
                                            if (_formKey.currentState!.validate()) {
                                              final verse = Verse(
                                                rank: _rank.text,
                                                word: _word.text,
                                                pronounce: _pronounce.text,
                                                meaningEn: _meaningEn.text,
                                                meaningUr: _meaningUr.text,
                                                times: _times.text,
                                                arabic: _arabic.text,
                                                english: _english.text,
                                                urdu: _urdu.text,
                                              );
                                              try {
                                                await controller.addVerse(verse);
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Word added')));
                                                }
                                                _clear();
                                              } catch (e) {
                                                final msg = e is DuplicateWordException ? e.message : 'Failed to add word';
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                                                }
                                              }
                                            }
                                          },
                                    label: const Text('Add'),
                                  ),
                                  const SizedBox(width: 12),
                                
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _text(String label, TextEditingController c, {bool required = false, int maxLines = 1, bool readOnly = false, String? suffixText, FocusNode? focusNode}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        focusNode: focusNode,
        maxLines: maxLines,
        readOnly: readOnly,
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          suffixText: suffixText,
        ),
      ),
    );
  }
}
