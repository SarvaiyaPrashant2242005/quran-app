import 'package:mana/controller/home_controller.dart';
import 'package:mana/models/verse_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerseHeader extends StatelessWidget {
  final Verse verse;
  final int index;

  const VerseHeader({
    super.key,
    required this.verse,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final topInset = MediaQuery.of(context).padding.top; // avoid AppBar overlap
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 30, 20, 22),
      decoration: BoxDecoration(   
        color: Colors.black.withOpacity(0.4),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // const SizedBox(height: 1),
          // Rank + Learned indicator row
          Obx(() {
            final learned = controller.isLearned(index);
            return Row(
              children: [
                Text(
                  '${verse.rank}',
                  style: const TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                if (learned)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.6)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Learned',
                          style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => controller.speak('$index-hword', verse.word, 'ar'),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Word: ',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  TextSpan(
                    text: verse.word,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' (${verse.pronounce})',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 3),
          GestureDetector(
            onTap: () => controller.speak('$index-hen', verse.meaningEn, 'en-US'),
            child: Text(
              'English : ${verse.meaningEn}',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const SizedBox(height: 3),
          GestureDetector(
            onTap: () => controller.speak('$index-hur', verse.meaningUr, 'ur-PK'),
            child: Text(
              'Urdu : ${verse.meaningUr}',
              style: const TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Repeats ${verse.times} ',
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 8),
          Obx(() {
            final learned = controller.isLearned(index);
            final learnedCount = controller.learnedCount;
            final total = controller.totalCount;
            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$learnedCount/$total learned',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: learned ? Colors.green.shade700 : const Color(0xFF1DBA8E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: learned
                      ? null
                      : () async {
                          await controller.learnAtIndex(index);
                        },
                  icon: Icon(learned ? Icons.check : Icons.school, size: 18),
                  label: Text(learned ? 'Learned' : 'Learn'),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}