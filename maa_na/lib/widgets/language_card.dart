import 'package:mana/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageCard extends StatelessWidget {
  final String title;
  final String id;
  final String text;
  final String lang;
  final TextDirection? direction;
  final Color? bg;

  const LanguageCard({
    super.key,
    required this.title,
    required this.id,
    required this.text,
    required this.lang,
    this.direction,
    this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final speaking = controller.speakingId == id;
      final ttsChecking = controller.ttsChecking;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.40),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  tooltip: speaking ? 'Stop' : 'Speak',
                  onPressed: ttsChecking
                      ? null
                      : () => speaking
                          ? controller.stopTts()
                          : controller.speak(id, text, lang),
                  icon: Icon(
                    speaking ? Icons.stop_circle : Icons.volume_up_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Builder(builder: (context) {
              final data = controller.data;
              final idx = controller.currentIndex;
              final verse = (data != null && idx >= 0 && idx < (data.verses.length))
                  ? data.verses[idx]
                  : null;

              String? target;
              if (verse != null) {
                if (lang.toLowerCase().startsWith('ar')) {
                  target = verse.word;
                } else if (lang.toLowerCase().startsWith('en')) {
                  target = verse.meaningEn;
                } else if (lang.toLowerCase().startsWith('ur')) {
                  target = verse.meaningUr;
                }
              }

              final baseStyle = const TextStyle(
                fontSize: 20,
                height: 1.5,
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(0, 1),
                    blurRadius: 3,
                  ),
                ],
              );

              // Split header phrase into separate words to highlight individually
              final isArabic = lang.toLowerCase().startsWith('ar');
              final needles = (target ?? '')
                  .split(RegExp('\\s+'))
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toSet()
                  .toList();

              TextSpan buildHighlightedSpanMulti(String full, List<String> words) {
                if (words.isEmpty) {
                  return TextSpan(text: full, style: baseStyle);
                }

                // Collect all match ranges for each word
                final ranges = <List<int>>[]; // [start, end)
                for (final w in words) {
                  if (w.isEmpty) continue;
                  final pattern = isArabic
                      ? RegExp(RegExp.escape(w))
                      : RegExp(RegExp.escape(w), caseSensitive: false);
                  for (final m in pattern.allMatches(full)) {
                    ranges.add([m.start, m.end]);
                  }
                }

                if (ranges.isEmpty) {
                  return TextSpan(text: full, style: baseStyle);
                }

                // Sort and merge overlapping ranges
                ranges.sort((a, b) => a[0].compareTo(b[0]));
                final merged = <List<int>>[];
                for (final r in ranges) {
                  if (merged.isEmpty) {
                    merged.add(r);
                  } else {
                    final last = merged.last;
                    if (r[0] <= last[1]) {
                      // overlap or touch: extend
                      last[1] = r[1] > last[1] ? r[1] : last[1];
                    } else {
                      merged.add([r[0], r[1]]);
                    }
                  }
                }

                // Build spans from merged ranges
                final spans = <TextSpan>[];
                int cursor = 0;
                for (final r in merged) {
                  final s = r[0];
                  final e = r[1];
                  if (s > cursor) {
                    spans.add(TextSpan(text: full.substring(cursor, s), style: baseStyle));
                  }
                  spans.add(TextSpan(
                    text: full.substring(s, e),
                    style: baseStyle.copyWith(
                      // backgroundColor: const Color(0x66FFFFFF),
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ));
                  cursor = e;
                }
                if (cursor < full.length) {
                  spans.add(TextSpan(text: full.substring(cursor), style: baseStyle));
                }
                return TextSpan(children: spans);
              }

              return RichText(
                textDirection: direction,
                text: buildHighlightedSpanMulti(text, needles),
              );
            }),
          ],
        ),
      );
    });
  }
}