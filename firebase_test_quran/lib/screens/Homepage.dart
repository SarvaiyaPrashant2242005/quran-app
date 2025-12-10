import 'package:mana/controller/home_controller.dart';
import 'package:mana/models/verse_data.dart';
import 'package:mana/widgets/verse_header.dart';
import 'package:mana/widgets/language_card.dart';
import 'package:mana/widgets/page_indicator.dart';
import 'package:mana/widgets/loading_overlay.dart';
import 'package:mana/screens/SettingsScreen.dart';
import 'package:mana/screens/QuizScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screen_protector/screen_protector.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

extension _MyHomePageStateHelpers on _MyHomePageState {
  void _maybeJumpToResume() {
    if (_didInitialJump) return;
    final verses = controller.data?.verses ?? const <Verse>[];
    if (verses.isEmpty) return;

    controller.recalculateResumeIndex();
    final idx = controller.resumeIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _pageController.jumpToPage(idx);
        controller.updateCurrentIndex(idx);
      }
    });
    _didInitialJump = true;
  }
}

class _MyHomePageState extends State<MyHomePage> {
  late PageController _pageController;
  late HomeController controller;
  int _tabIndex = 0;
  bool _didInitialJump = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<HomeController>();
     try {
     ScreenProtector.preventScreenshotOn();
     ScreenProtector.protectDataLeakageOn();
  } catch (_) {}
    _pageController = PageController();
    _pageController.addListener(_onPageChanged);

    // After first frame, jump to resume index (next unlearned)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeJumpToResume();
    });
  }

  void _onPageChanged() {
    final page = _pageController.page;
    if (page != null) {
      final idx = page.round();
      controller.updateCurrentIndex(idx);
      controller.bumpIndicator();
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _tabIndex == 0
            ? const Text('', style: TextStyle(color: Colors.white))
            : _tabIndex == 1
                ? const Text('Quiz', style: TextStyle(color: Colors.white, fontSize: 16))
                : const Text('Settings', style: TextStyle(color: Colors.white, fontSize: 16)),
        actions: const [],
      ),
      extendBodyBehindAppBar: true,
      body: Obx(() {
        final controller = Get.find<HomeController>();
        final verses = controller.data?.verses ?? const <Verse>[];
        final error = controller.error;
        final loading = controller.loading;
        final ttsChecking = controller.ttsChecking;
        // Access these to make Obx rebuild when they change
        final resumeIdx = controller.resumeIndex;
        final learnedCount = controller.learnedCount;
        // Ensure we perform a one-time jump to the resume index once data is ready
        _maybeJumpToResume();

        // Tabs: 0=Home (Learning), 1=Quiz, 2=Settings
        if (_tabIndex == 1) {
          return const QuizScreen();
        }
        if (_tabIndex == 2) {
          return const SettingsScreen();
        }

        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/quran_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: Stack(
              children: [
                if (error != null)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(error),
                    ),
                  )
                else if (verses.isEmpty)
                  Center(
                    child: Image.asset(
                      'assets/images/loader.gif',
                      width: 140,
                      height: 140,
                    ),
                  )
                else
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: controller.bumpIndicator,
                    onPanUpdate: (details) {
                      if (details.delta.dx.abs() > 5) {
                        controller.bumpIndicator();
                      }
                    },
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: verses.length,
                      itemBuilder: (context, index) {
                        final v = verses[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            VerseHeader(verse: v, index: index),
                            const SizedBox(height: 12),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.only(bottom: 48),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    LanguageCard(
                                      title: 'Arabic',
                                      id: '${index}-ar',
                                      text: v.arabic,
                                      lang: 'ar',
                                      direction: TextDirection.rtl,
                                    ),
                                    LanguageCard(
                                      title: 'English',
                                      id: '${index}-en',
                                      text: v.english,
                                      lang: 'en-US',
                                      direction: TextDirection.ltr,
                                    ),
                                    LanguageCard(
                                      title: 'Urdu',
                                      id: '${index}-ur',
                                      text: v.urdu,
                                      lang: 'ur-PK',
                                      direction: TextDirection.rtl,
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                if (controller.showIndicator && verses.isNotEmpty)
                  PageIndicator(
                    currentIndex: controller.currentIndex,
                    totalPages: verses.length,
                  ),
                if (ttsChecking)
                  const LoadingOverlay(),
                if (loading && verses.isNotEmpty)
                  const LoadingOverlay(),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
       backgroundColor: Colors.black.withOpacity(0.85),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
        onTap: (i) {
          setState(() => _tabIndex = i);
          if (i == 0) {
            // When returning to Home, jump to next unlearned immediately
            final verses = controller.data?.verses ?? const <Verse>[];
            if (verses.isNotEmpty) {
              controller.recalculateResumeIndex();
              final idx = controller.resumeIndex;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _pageController.jumpToPage(idx);
                  controller.updateCurrentIndex(idx);
                }
              });
            }
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}