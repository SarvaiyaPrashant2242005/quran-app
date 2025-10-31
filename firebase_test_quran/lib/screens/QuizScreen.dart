import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_test_quran/controller/home_controller.dart';
import 'package:firebase_test_quran/models/verse_data.dart';
import 'package:firebase_test_quran/services/tts_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late HomeController controller;
  final TtsService ttsService = TtsService();

  // Lobby/quiz state
  bool _inQuiz = false;

  // Quiz data
  late List<int> _questionIndices;
  int _qPos = 0;
  int _score = 0;
  int? _selectedIdx;
  bool _showAnswer = false;
  List<String> _options = const [];
  int _correctOption = -1;

  // TTS state
  bool _isSpeakingQuestion = false;
  int? _speakingOptionIdx;
  bool _ttsAvailable = true;

  @override
  void initState() {
    super.initState();
    controller = Get.find<HomeController>();
    _initTts();
    _resetToLobby();
  }

  Future<void> _initTts() async {
    await ttsService.init();
    final isAvailable = await ttsService.isTtsEngineInstalled();
    setState(() {
      _ttsAvailable = isAvailable;
    });
    
    // Setup callbacks
    ttsService.onCompletion = () {
      if (mounted) {
        setState(() {
          _isSpeakingQuestion = false;
          _speakingOptionIdx = null;
        });
      }
    };
    
    ttsService.onCancel = () {
      if (mounted) {
        setState(() {
          _isSpeakingQuestion = false;
          _speakingOptionIdx = null;
        });
      }
    };
    
    ttsService.onError = (msg) {
      if (mounted) {
        setState(() {
          _isSpeakingQuestion = false;
          _speakingOptionIdx = null;
        });
      }
    };
  }

  @override
  void dispose() {
    ttsService.stop();
    ttsService.dispose();
    super.dispose();
  }

  void _resetToLobby() {
    _inQuiz = false;
    _questionIndices = <int>[];
    _qPos = 0;
    _score = 0;
    _selectedIdx = null;
    _showAnswer = false;
    _options = const [];
    _correctOption = -1;
    _isSpeakingQuestion = false;
    _speakingOptionIdx = null;
    ttsService.stop();
    setState(() {});
  }

  void _startQuiz() {
    final learned = controller.learnedIndices.toList();
    learned.shuffle();
    _questionIndices = learned;
    _qPos = 0;
    _score = 0;
    _selectedIdx = null;
    _showAnswer = false;
    _inQuiz = true;
    _buildOptions();
  }

  void _buildOptions() {
    final verses = controller.data?.verses ?? const <Verse>[];
    if (_qPos >= _questionIndices.length) return;
    final correctVerseIdx = _questionIndices[_qPos];
    final correct = verses[correctVerseIdx];

    // Use learned words only for distractors
    final pool = controller.learnedIndices.toList();
    pool.remove(correctVerseIdx);
    pool.shuffle();

    final distractorIdxs = pool.take(3).toList();

    // Build a set to avoid duplicate meanings
    final optionSet = <String>{};
    optionSet.add(correct.meaningEn);
    for (final i in distractorIdxs) {
      optionSet.add(verses[i].meaningEn);
    }
    // If duplicates reduced below 4, fill from other learned to keep count at 4
    if (optionSet.length < 4) {
      for (final i in pool) {
        if (optionSet.length >= 4) break;
        optionSet.add(verses[i].meaningEn);
      }
    }
    // Still less than 4? Keep what we have; grid will adapt itemCount safely.
    final list = optionSet.toList()..shuffle();

    _correctOption = list.indexOf(correct.meaningEn);
    _options = list;
    _selectedIdx = null;
    _showAnswer = false;
    _isSpeakingQuestion = false;
    _speakingOptionIdx = null;
    ttsService.stop();
    setState(() {});
  }

  Future<void> _speakQuestion() async {
    if (!_ttsAvailable) return;
    
    final verses = controller.data?.verses ?? const <Verse>[];
    final currentIdx = _questionIndices[_qPos];
    final v = verses[currentIdx];
    
    setState(() {
      _isSpeakingQuestion = !_isSpeakingQuestion;
      _speakingOptionIdx = null;
    });
    
    if (_isSpeakingQuestion) {
      await ttsService.speak(
        id: 'question_$_qPos',
        text: v.word,
        language: 'ar-SA', // Arabic
        speechRate: 0.4,
        pitch: 1.0,
      );
    } else {
      await ttsService.stop();
    }
  }

  Future<void> _speakOption(int idx) async {
    if (!_ttsAvailable || _showAnswer) return;
    
    setState(() {
      if (_speakingOptionIdx == idx) {
        _speakingOptionIdx = null;
        _isSpeakingQuestion = false;
      } else {
        _speakingOptionIdx = idx;
        _isSpeakingQuestion = false;
      }
    });
    
    if (_speakingOptionIdx == idx) {
      await ttsService.speak(
        id: 'option_$idx',
        text: _options[idx],
        language: 'en-US', // English
        speechRate: 0.45,
        pitch: 1.0,
      );
    } else {
      await ttsService.stop();
    }
  }

  void _onSelect(int idx) {
    if (_showAnswer) return;
    setState(() {
      _selectedIdx = idx;
    });
  }

  void _submitAnswer() async {
    if (_selectedIdx == null || _showAnswer) return;
    
    ttsService.stop();
    setState(() {
      _showAnswer = true;
      _isSpeakingQuestion = false;
      _speakingOptionIdx = null;
      if (_selectedIdx == _correctOption) {
        _score++;
      }
    });

    // Wait 2 seconds then move to next question or finish
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      _next();
    }
  }

  Future<void> _next() async {
    if (_qPos < _questionIndices.length - 1) {
      setState(() {
        _qPos += 1;
      });
      _buildOptions();
    } else {
      // Completed quiz: persist and show dialog
      await controller.quizCompleted(score: _score);
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Quiz Completed'),
              content: Text(
                'Your score: $_score/${_questionIndices.length}',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
      _resetToLobby();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background (same as app)
        Container(
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
          ),
        ),
        if (!_inQuiz) _buildLobby() else _buildQuiz(),
      ],
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildLobby() {
    // Wrap stats in Obx so they update live if user learns more words and returns
    return Obx(() {
      final learned = controller.learnedCount;
      final high = controller.quizHighScore;
      final lastCount = controller.lastQuizLearnedCount;

      String message = '';
      bool canStart = true;
      final alreadyTakenForCurrent = lastCount > 0 && learned <= lastCount;

      if (learned < 5) {
        message = 'Learn at least 5 words to start the quiz.';
        canStart = false;
      }

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statChip('Learned', learned.toString()),
                  _statChip('High Score', high.toString()),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Play Quiz',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color.fromARGB(255, 191, 255, 0)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Test your knowledge on all learned words. Questions are generated from your learned list only.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18,  color: const Color.fromARGB(255, 255, 255, 255)),
                      ),
                      const SizedBox(height: 16),
                      if (alreadyTakenForCurrent)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            'You have already taken a quiz for your current $learned learned words.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.blue.shade900),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (!canStart)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.orange.shade900),
                          ),
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: canStart ? _startQuiz : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7A2DD1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(alreadyTakenForCurrent ? 'Play Quiz Again' : 'Start Quiz'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        learned >= 5 && canStart ? 'Questions: $learned' : 'Questions: —',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQuiz() {
    final verses = controller.data?.verses ?? const <Verse>[];
    final currentIdx = _questionIndices[_qPos];
    final v = verses[currentIdx];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statChip('Score', '$_score/${_questionIndices.length}'),
                _statChip('Q', '${_qPos + 1}/${_questionIndices.length}'),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'What is the meaning of',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          v.word,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          v.pronounce,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (_ttsAvailable)
                    IconButton(
                      onPressed: _speakQuestion,
                      icon: Icon(
                        _isSpeakingQuestion ? Icons.stop_circle : Icons.volume_up,
                        color: _isSpeakingQuestion ? Colors.red : const Color(0xFF7A2DD1),
                        size: 32,
                      ),
                      tooltip: _isSpeakingQuestion ? 'Stop' : 'Listen to question',
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: _options.length,
                itemBuilder: (ctx, i) {
                  final isCorrect = i == _correctOption;
                  final isSelected = _selectedIdx == i;
                  final isSpeaking = _speakingOptionIdx == i;
                  Color bg;
                  Color fg = Colors.white;
                  Color? borderColor;
                  
                  if (_showAnswer) {
                    if (isCorrect) {
                      bg = Colors.green.shade600;
                    } else if (isSelected) {
                      bg = Colors.red.shade600;
                    } else {
                      bg = Colors.white.withOpacity(0.12);
                      fg = Colors.white70;
                    }
                  } else {
                    if (isSelected) {
                      bg = const Color(0xFF7A2DD1).withOpacity(0.3);
                      borderColor = const Color(0xFF7A2DD1);
                    } else {
                      bg = Colors.white.withOpacity(0.12);
                    }
                  }

                  return InkWell(
                    onTap: _showAnswer ? null : () => _onSelect(i),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: borderColor ?? Colors.white24,
                          width: borderColor != null ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                _options[i],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: fg,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          if (_ttsAvailable && !_showAnswer)
                            IconButton(
                              onPressed: () => _speakOption(i),
                              icon: Icon(
                                isSpeaking ? Icons.stop_circle : Icons.volume_up,
                                color: isSpeaking ? Colors.red : Colors.white70,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            if (!_showAnswer)
              ElevatedButton(
                onPressed: _selectedIdx != null ? _submitAnswer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A2DD1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: const Text('Submit Answer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              )
            else
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selectedIdx == _correctOption 
                          ? Colors.green.shade50 
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selectedIdx == _correctOption 
                            ? Colors.green.shade200 
                            : Colors.red.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedIdx == _correctOption ? Icons.check_circle : Icons.cancel,
                          color: _selectedIdx == _correctOption 
                              ? Colors.green.shade700 
                              : Colors.red.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedIdx == _correctOption 
                                ? 'Correct! Well done!' 
                                : 'Incorrect. The correct answer is: ${_options[_correctOption]}',
                            style: TextStyle(
                              color: _selectedIdx == _correctOption 
                                  ? Colors.green.shade900 
                                  : Colors.red.shade900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
          ],
        ),
      ),
    );
  }
}