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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
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
  final _searchController = TextEditingController();

  late AnimationController _searchAnimController;
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _searchController.addListener(() {
      setState(() {});
    });
  }

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
    _searchController.dispose();
    _searchAnimController.dispose();
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

  void _toggleSearchBar() {
    if (_isSearchExpanded) {
      _searchAnimController.reverse();
      _searchController.clear();
    } else {
      _searchAnimController.forward();
    }
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VerseController>();
    if (controller.data != null && controller.data!.verses.isNotEmpty) {
      _rank.text = '#${controller.data!.verses.length + 1}';
    } else {
      _rank.text = '#1';
    }

    final searchQuery = _searchController.text.toLowerCase();
    final filteredVerses = controller.data.verses.where((v) {
      return v.word.toLowerCase().contains(searchQuery) ||
          v.arabic.toLowerCase().contains(searchQuery) ||
          v.meaningEn.toLowerCase().contains(searchQuery) ||
          v.meaningUr.toLowerCase().contains(searchQuery) ||
          v.english.toLowerCase().contains(searchQuery) ||
          v.urdu.toLowerCase().contains(searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        elevation: 0,
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
            : LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  if (!isWide) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildForm(controller),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _buildTable(filteredVerses),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: SingleChildScrollView(
                            child: _buildForm(controller),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildForm(VerseController controller) {
    return Card(
      elevation: 8,
      color: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _text(
                'Rank (auto-filled)',
                _rank,
                readOnly: true,
                suffixText: '#${controller.data?.verses.length ?? 0 + 1}',
              ),
              _text('Word (Arabic)', _word, required: true, focusNode: _wordNode),
              _text('Pronounce (e.g. Min)', _pronounce, required: true),
              _text('Meaning (EN)', _meaningEn, required: true),
              _text('Meaning (UR)', _meaningUr, required: true),
              _text('Times (e.g. 3226 Times)', _times, required: true),
              _text('Arabic Verse', _arabic, required: true, maxLines: 3),
              _text('English', _english, required: true, maxLines: 3),
              _text('Urdu', _urdu, required: true, maxLines: 3),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Word added successfully'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                                _clear();
                              } catch (e) {
                                final msg = e is DuplicateWordException ? e.message : 'Failed to add word';
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(msg),
                                      backgroundColor: Colors.red.shade700,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Word'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable(List<Verse> verses) {
    return Card(
      elevation: 8,
      color: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Words List',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                SizeTransition(
                  sizeFactor: _searchAnimController,
                  axis: Axis.horizontal,
                  axisAlignment: 1,
                  child: SizedBox(
                    width: 300,
                    child: _buildAnimatedSearchField(),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isSearchExpanded
                        ? Colors.blue.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                  child: IconButton(
                    icon: AnimatedIcon(
                      icon: AnimatedIcons.search_ellipsis,
                      progress: _searchAnimController,
                      color: Colors.white,
                    ),
                    onPressed: _toggleSearchBar,
                    tooltip: _isSearchExpanded ? 'Close search' : 'Open search',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final total = constraints.maxWidth;
                  final hashCol = 95.0;
                  final spacing = 32.0 * 3;
                  final available = total - hashCol - spacing;
                  final arabicW = available * 0.28;
                  final englishW = available * 0.36;
                  final urduW = available * 0.36;

                  return SingleChildScrollView(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: DataTable(
                        columnSpacing: 32,
                        dataRowHeight: 80,
                        headingRowHeight: 56,
                        columns: const [
                          DataColumn(label: Text('Hash #')),
                          DataColumn(label: Text('Arabic')),
                          DataColumn(label: Text('English')),
                          DataColumn(label: Text('Urdu')),
                        ],
                        rows: List<DataRow>.generate(verses.length, (index) {
                          final v = verses[index];
                          final rank = (v.rank.isNotEmpty) ? v.rank : '#${index + 1}';
                          return DataRow(
                            cells: [
                              DataCell(Text(rank)),
                              DataCell(
                                SizedBox(
                                  width: arabicW,
                                  child: _twoLine(v.word, v.arabic),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: englishW,
                                  child: _twoLine(v.meaningEn, v.english),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: urduW,
                                  child: _twoLine(v.meaningUr, v.urdu),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search words...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.white70),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _twoLine(String top, String bottom) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          top,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          bottom,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _text(
    String label,
    TextEditingController c, {
    bool required = false,
    int maxLines = 1,
    bool readOnly = false,
    String? suffixText,
    FocusNode? focusNode,
  }) {
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          suffixText: suffixText,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      ),
    );
  }
}