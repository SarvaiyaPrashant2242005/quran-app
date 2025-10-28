// home_controller.dart (GetX version)
import 'dart:io';
import 'package:firebase_test_quran/models/verse_data.dart';
import 'package:firebase_test_quran/services/firestore_service.dart';
import 'package:firebase_test_quran/services/local_data_service.dart';
import 'package:firebase_test_quran/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class HomeController extends GetxController {
  final LocalDataService _local;
  final FirestoreService _remote;
  final TtsService _tts;

  final _data = Rx<VerseData?>(null);
  final _loading = true.obs;
  final _error = Rx<String?>(null);
  final _speakingId = Rx<String?>(null);
  final _currentIndex = 0.obs;
  final _showIndicator = false.obs;
  // TTS gating states
  final _ttsChecking = false.obs; // show loader while checking engine
  final _ttsInstalled = false.obs; // cache engine availability
  Timer? _indicatorTimer;

  // Learning state
  final RxSet<int> _learned = <int>{}.obs;
  final _lastIndex = RxnInt();
  final _resumeIndex = 0.obs;
  bool _resumeCalculated = false;

  // Getters
  VerseData? get data => _data.value;
  bool get loading => _loading.value;
  String? get error => _error.value;
  String? get speakingId => _speakingId.value;
  int get currentIndex => _currentIndex.value;
  bool get showIndicator => _showIndicator.value;
  bool get ttsChecking => _ttsChecking.value;
  bool get ttsInstalled => _ttsInstalled.value;
  Set<int> get learnedIndices => _learned;
  int get learnedCount => _learned.length;
  int get totalCount => _data.value?.verses.length ?? 0;
  int get resumeIndex => _resumeIndex.value;

  HomeController({
    required LocalDataService local,
    required FirestoreService remote,
    required TtsService tts,
  })  : _local = local,                                                              
        _remote = remote,
        _tts = tts;

  @override
  void onInit() {
    super.onInit();
    _setupTtsCallbacks();
    _tts.init();
    init();
    // Immediately check TTS installation and gate UI if not available
    checkAndPromptTtsInstallation();
  }

  Future<void> init() async {
    await _loadLocal();
    await _loadLearningProgress();
    _calculateResumeIndex();
  }

  void _setupTtsCallbacks() {
    _tts.onCompletion = () {
      _speakingId.value = null;
    };
    _tts.onCancel = () {
      _speakingId.value = null;
    };
    _tts.onError = (msg) {
      _speakingId.value = null;
    };
  }

  Future<void> _loadLocal() async {
    _loading.value = true;
    _error.value = null;

    try {
      final data = await _local.readLocal();
      _data.value = data;
    } catch (e) {
      _error.value = 'Failed to load local data: $e';
    } finally {
      _loading.value = false;
    }
  }

  Future<void> sync() async {
    _loading.value = true;

    try {
      final remoteData = await _remote.fetchRemoteData();
      if (remoteData == null) {
        throw Exception('No remote data found');
      }
      await _local.writeLocal(remoteData);
      await _loadLocal();
    } catch (e) {
      _error.value = 'Sync failed: $e';
      _loading.value = false;
      rethrow;
    }
  }

  Future<void> stopTts() async {
    await _tts.stop();
    _speakingId.value = null;
  }

  Future<void> speak(String id, String text, String lang) async {
    // Block speak when TTS is not installed; show info dialog instead
    if (!_ttsInstalled.value) {
      await checkAndPromptTtsInstallation();
      return;
    }

    // Set speaking immediately so UI updates the icon right away
    _speakingId.value = id;

    await _tts.speak(
      id: id,
      text: text,
      language: lang,
      speechRate: 0.45,
      pitch: 1.0,
    );
    // speakingId will be cleared by TTS completion/cancel/error callbacks
  }

  void updateCurrentIndex(int index) {
    if (index != _currentIndex.value) {
      _currentIndex.value = index;
      // track last seen index for resume
      _lastIndex.value = index;
      _local.saveLastIndex(index);
    }
  }

  void bumpIndicator() {
    _showIndicator.value = true;
    _indicatorTimer?.cancel();
    _indicatorTimer = Timer(const Duration(seconds: 2), () {
      _showIndicator.value = false;
    });
  }

  // Check if TTS engine is installed and prompt if not
  Future<void> checkAndPromptTtsInstallation() async {
    _ttsChecking.value = true;
    _error.value = null;
    try {
      final isInstalled = await _tts.isTtsEngineInstalled();
      _ttsInstalled.value = isInstalled;
      if (!isInstalled) {
        // Show installation dialog once check completes
        _showTtsInstallDialog();
      }
    } catch (e) {
      // If anything goes wrong, treat as not installed but don't crash
      _ttsInstalled.value = false;
    } finally {
      _ttsChecking.value = false;
    }
  }

  // Show dialog to install TTS engine
  void _showTtsInstallDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Color(0xFF7A2DD1), size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'TTS Engine Required',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Text(
          'Text-to-Speech engine is not installed or not available on your device.\n\n'
          'To enable voice features for Arabic, English, and Urdu, please install "Google Text-to-Speech" from Play Store.',
          style: TextStyle(fontSize: 15, height: 1.4),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Later',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A2DD1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Get.back();
              _openTtsInstallPage();
            },
            child: const Text('Install Now'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Open Play Store or App Store to install TTS
  Future<void> _openTtsInstallPage() async {
    try {
      if (Platform.isAndroid) {
        // Try to open Play Store app first
        final uri = Uri.parse('market://details?id=com.google.android.tts');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          // Fallback to browser
          final webUri = Uri.parse(
            'https://play.google.com/store/apps/details?id=com.google.android.tts',
          );
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        }
      } else if (Platform.isIOS) {
        // iOS has built-in TTS
        Get.snackbar(
          'Info',
          'Text-to-Speech is built into iOS. Please check your device settings under Accessibility > Spoken Content.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.white,
          colorText: Colors.black,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open Play Store. Please search for "Google Text-to-Speech" manually in Play Store.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  // Check TTS status (for info button)
  Future<void> checkTtsStatus() async {
    final available = await _tts.isTtsAvailable();
    final languages = await _tts.getAvailableLanguages();
    final isInstalled = await _tts.isTtsEngineInstalled();

    // keep cached flag in sync
    _ttsInstalled.value = isInstalled;

    // Show status with first few languages
    final languagePreview = languages.take(5).join(', ');
    final moreLanguages = languages.length > 5 ? ' +${languages.length - 5} more' : '';

    Get.dialog(
      AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: Color(0xFF7A2DD1), size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'TTS Engine Status',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow('Engine Installed', isInstalled),
            const SizedBox(height: 8),
            _buildStatusRow('TTS Available', available),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
          
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$languagePreview$moreLanguages',
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          if (isInstalled)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Get.back();
                _openTtsUninstallPage();
              },
              icon: const Icon(Icons.delete_outline, size: 20),
              label: const Text('Uninstall'),
            )
          else
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A2DD1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Get.back();
                _openTtsInstallPage();
              },
              icon: const Icon(Icons.download, size: 20),
              label: const Text('Install'),
            ),
        ],
      ),
    );
  }

  // Learning: load/save progress and sequencing
  Future<void> _loadLearningProgress() async {
    final learned = await _local.loadLearnedIndices();
    _learned
      ..clear()
      ..addAll(learned);
    _lastIndex.value = await _local.loadLastIndex();
  }

  Future<void> _saveLearningProgress() async {
    await _local.saveLearnedIndices(_learned);
    if (_lastIndex.value != null) {
      await _local.saveLastIndex(_lastIndex.value!);
    }
  }

  void _calculateResumeIndex() {
    if (_resumeCalculated) return;
    final total = totalCount;
    if (total == 0) {
      _resumeIndex.value = 0;
      _resumeCalculated = true;
      return;
    }
    final start = ((_lastIndex.value ?? -1) + 1).clamp(0, total - 1);
    _resumeIndex.value = nextUnlearnedFrom(start) ?? 0;
    _resumeCalculated = true;
  }

  int? nextUnlearnedFrom(int start) {
    final total = totalCount;
    if (total == 0) return null;
    for (int i = 0; i < total; i++) {
      final idx = (start + i) % total;
      if (!_learned.contains(idx)) return idx;
    }
    return null; // all learned
  }

  bool isLearned(int index) => _learned.contains(index);

  Future<void> markLearned(int index) async {
    _learned.add(index);
    _lastIndex.value = index;
    await _saveLearningProgress();
  }

  Future<void> resetLearning() async {
    _learned.clear();
    _lastIndex.value = null;
    await _local.resetLearningProgress();
    _resumeCalculated = false;
    _calculateResumeIndex();
  }

  // Sequence learning for a page: speak AR -> EN -> UR, then mark learned
  Future<int?> learnAtIndex(int index) async {
    final verses = _data.value?.verses ?? const <Verse>[];
    if (index < 0 || index >= verses.length) return null;

    // Ensure TTS engine
    if (!_ttsInstalled.value) {
      await checkAndPromptTtsInstallation();
      if (!_ttsInstalled.value) return null;
    }

    final v = verses[index];
    try {
      // Also speak the header word shown in VerseHeader before the sequence
      await _tts.speak(id: '${index}-hword', text: v.word, language: 'ar');
      await _tts.speak(id: '${index}-ar', text: v.arabic, language: 'ar');
      await _tts.speak(id: '${index}-en', text: v.english, language: 'en-US');
      await _tts.speak(id: '${index}-ur', text: v.urdu, language: 'ur-PK');
    } catch (_) {
      // If any speak fails, do not mark learned
      return null;
    }

    await markLearned(index);
    final next = nextUnlearnedFrom(index + 1);
    return next;
  }

  @override
  void onClose() {
    _indicatorTimer?.cancel();
    _tts.dispose();
    super.onClose();
  }

}

// Helper method to build status rows
Widget _buildStatusRow(String label, bool status) {
  return Row(
    children: [
      Icon(
        status ? Icons.check_circle : Icons.cancel,
        color: status ? Colors.green : Colors.red,
        size: 20,
      ),
      const SizedBox(width: 8),
      Text(
        '$label: ',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      Text(
        status ? 'Yes' : 'No',
        style: TextStyle(
          color: status ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

// Add this new method to open uninstall page
// Updated method to open TTS app settings (best we can do)
Future<void> _openTtsUninstallPage() async {
  try {
    if (Platform.isAndroid) {
      // Open the TTS app details page in Android settings
      final uri = Uri.parse('android.settings.APPLICATION_DETAILS_SETTINGS');
      final packageUri = Uri(
        scheme: 'package',
        path: 'com.google.android.tts',
      );
      
      // Try to open app details
      try {
        await launchUrl(
          Uri.parse('market://details?id=com.google.android.tts'),
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {
        Get.snackbar(
          'Uninstall TTS',
          'Please go to:\nSettings > Apps > Google Text-to-Speech > Uninstall',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.white,
          colorText: Colors.black,
        );
      }
    } else if (Platform.isIOS) {
      Get.snackbar(
        'Info',
        'TTS is built into iOS and cannot be uninstalled.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade900,
      );
    }
  } catch (e) {
    Get.snackbar(
      'Manual Uninstall Required',
      'Please uninstall manually:\nSettings > Apps > Google Text-to-Speech',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade900,
    );
  }
}