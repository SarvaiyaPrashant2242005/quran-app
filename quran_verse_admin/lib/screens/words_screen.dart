import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_verse_admin/controllers/verse_controller.dart';
import 'package:quran_verse_admin/models/verse.dart';
import 'package:quran_verse_admin/widgets/app_background.dart';

class WordsScreen extends StatefulWidget {
  const WordsScreen({super.key});

  @override
  State<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends State<WordsScreen> {
  @override
  void initState() {
    super.initState();
    // Always fetch fresh data when opening the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VerseController>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VerseController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Words'),
        actions: [
          IconButton(
            onPressed: controller.loading ? null : () => controller.init(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
         
        ],
      ),
      body: AppBackground(
        child: controller.loading
            ? Center(child: Image.asset('assets/images/loader.gif', height: 64))
            : RefreshIndicator(
                onRefresh: () => context.read<VerseController>().init(),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.data.verses.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Total Words: ${controller.data.totalWords}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      );
                    }
                    final v = controller.data.verses[index - 1];
                    return Card(
                      child: ListTile(
                        title: Text('${v.rank} • ${v.word}'),
                        subtitle: Text('${v.pronounce} • ${v.meaningEn} • ${v.times}'),
                        onTap: () => _openDetail(context, controller, index - 1, v),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final ok = await _confirm(context, 'Delete this word?');
                            if (ok) {
                              await controller.deleteVerse(index - 1);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
      // Add FAB moved to Home screen
    );
  }

  Future<void> _openDetail(BuildContext context, VerseController controller, int index, Verse? v) async {
    final result = await showDialog<Verse>(
      context: context,
      builder: (_) => _VerseDialog(initial: v),
    );
    if (result == null) return;
    if (index == -1) {
      await controller.addVerse(result);
    } else {
      await controller.updateVerse(index, result.copyWith(rank: '#${index + 1}'));
    }
  }

  Future<bool> _confirm(BuildContext ctx, String msg) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
        ],
      ),
    );
    return ok ?? false;
  }
}

class _VerseDialog extends StatefulWidget {
  final Verse? initial;
  const _VerseDialog({required this.initial});

  @override
  State<_VerseDialog> createState() => _VerseDialogState();
}

class _VerseDialogState extends State<_VerseDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _rank = TextEditingController(text: widget.initial?.rank ?? '');
  late final TextEditingController _word = TextEditingController(text: widget.initial?.word ?? '');
  late final TextEditingController _pronounce = TextEditingController(text: widget.initial?.pronounce ?? '');
  late final TextEditingController _meaningEn = TextEditingController(text: widget.initial?.meaningEn ?? '');
  late final TextEditingController _meaningUr = TextEditingController(text: widget.initial?.meaningUr ?? '');
  late final TextEditingController _times = TextEditingController(text: widget.initial?.times ?? '');
  late final TextEditingController _arabic = TextEditingController(text: widget.initial?.arabic ?? '');
  late final TextEditingController _english = TextEditingController(text: widget.initial?.english ?? '');
  late final TextEditingController _urdu = TextEditingController(text: widget.initial?.urdu ?? '');

  @override
  void dispose() {
    _rank.dispose();
    _word.dispose();
    _pronounce.dispose();
    _meaningEn.dispose();
    _meaningUr.dispose();
    _times.dispose();
    _arabic.dispose();
    _english.dispose();
    _urdu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Word Detail'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _text('Rank (optional)', _rank),
                _text('Word', _word, required: true),
                _text('Pronounce', _pronounce, required: true),
                _text('Meaning (EN)', _meaningEn, required: true),
                _text('Meaning (UR)', _meaningUr, required: true),
                _text('Times', _times, required: true),
                _text('Arabic', _arabic, required: true, maxLines: 3),
                _text('English', _english, required: true, maxLines: 3),
                _text('Urdu', _urdu, required: true, maxLines: 3),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                Verse(
                  rank: _rank.text,
                  word: _word.text,
                  pronounce: _pronounce.text,
                  meaningEn: _meaningEn.text,
                  meaningUr: _meaningUr.text,
                  times: _times.text,
                  arabic: _arabic.text,
                  english: _english.text,
                  urdu: _urdu.text,
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _text(String label, TextEditingController c, {bool required = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Field',
        ).copyWith(labelText: label),
      ),
    );
  }
}
