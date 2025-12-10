// quiz_controller.dart
import 'package:mana/services/local_data_service.dart';
import 'package:get/get.dart';

class QuizController extends GetxController {
  final LocalDataService _local;

  // Quiz state
  final _quizHighScore = 0.obs;
  final _lastQuizLearnedCount = 0.obs;

  // Getters
  int get quizHighScore => _quizHighScore.value;
  int get lastQuizLearnedCount => _lastQuizLearnedCount.value;

  QuizController({
    required LocalDataService local,
  }) : _local = local;

  @override
  void onInit() {
    super.onInit();
    _loadQuizState();
  }

  Future<void> _loadQuizState() async {
    _quizHighScore.value = await _local.loadQuizHighScore();
    _lastQuizLearnedCount.value = await _local.loadLastQuizLearnedCount();
  }

  Future<void> setQuizHighScore(int score) async {
    if (score > _quizHighScore.value) {
      _quizHighScore.value = score;
      await _local.saveQuizHighScore(score);
    }
  }

  Future<void> setLastQuizLearnedCount(int count) async {
    _lastQuizLearnedCount.value = count;
    await _local.saveLastQuizLearnedCount(count);
  }

  Future<void> quizCompleted({required int score, required int learnedCount}) async {
    await setQuizHighScore(score);
    await setLastQuizLearnedCount(learnedCount);
  }

  Future<void> resetQuizState() async {
    _quizHighScore.value = 0;
    _lastQuizLearnedCount.value = 0;
    await _local.saveQuizHighScore(0);
    await _local.saveLastQuizLearnedCount(0);
  }
}