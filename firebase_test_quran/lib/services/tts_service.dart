// services/tts_service.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  
  String? _currentSpeakingId;
  bool _isInitialized = false;
  
  String? get currentSpeakingId => _currentSpeakingId;
  
  // Callbacks
  VoidCallback? onCompletion;
  VoidCallback? onCancel;
  Function(String)? onError;
  
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      // Platform-specific initialization
      if (Platform.isAndroid) {
        await _initAndroid();
      } else if (Platform.isIOS) {
        await _initIOS();
      }
      
      _setupHandlers();
      _isInitialized = true;
    } catch (e) {
      print('TTS initialization error: $e');
      onError?.call('TTS not available on this device');
    }
  }
  
  Future<void> _initAndroid() async {
    await _tts.setSharedInstance(true);
  }
  
  Future<void> _initIOS() async {
    await _tts.setSharedInstance(true);
    await _tts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ],
      IosTextToSpeechAudioMode.voicePrompt,
    );
  }
  
  void _setupHandlers() {
    _tts.setStartHandler(() {
      print('TTS Started');
    });
    
    _tts.setCompletionHandler(() {
      print('TTS Completed');
      _currentSpeakingId = null;
      onCompletion?.call();
    });
    
    _tts.setCancelHandler(() {
      print('TTS Cancelled');
      _currentSpeakingId = null;
      onCancel?.call();
    });
    
    _tts.setErrorHandler((msg) {
      print('TTS Error: $msg');
      _currentSpeakingId = null;
      onError?.call(msg);
    });
    
    _tts.awaitSpeakCompletion(true);
  }
  
  Future<bool> _isLanguageAvailable(String language) async {
    try {
      final languages = await _tts.getLanguages;
      if (languages == null) return false;
      
      // Check exact match
      if (languages.contains(language)) return true;
      
      // Check language code without region (e.g., 'ar' from 'ar-SA')
      final langCode = language.split('-').first;
      return languages.any((l) => l.toString().startsWith(langCode));
    } catch (e) {
      print('Error checking language availability: $e');
      return false;
    }
  }
  
  Future<String> _getBestAvailableLanguage(String requestedLanguage) async {
    // Try exact match first
    if (await _isLanguageAvailable(requestedLanguage)) {
      return requestedLanguage;
    }
    
    // Try language code only
    final langCode = requestedLanguage.split('-').first;
    final languages = await _tts.getLanguages;
    
    if (languages != null) {
      // Find any variant of the language
      for (var lang in languages) {
        if (lang.toString().startsWith(langCode)) {
          return lang.toString();
        }
      }
    }
    
    // Fallback to default
    return Platform.isIOS ? 'en-US' : 'en-US';
  }
  // In tts_service.dart, add this method:

Future<bool> isTtsEngineInstalled() async {
  try {
    final engines = await _tts.getEngines;
    final languages = await _tts.getLanguages;
    
    // Check if any TTS engine is available
    if (engines == null || engines.isEmpty) {
      return false;
    }
    
    // Check if any languages are available
    if (languages == null || languages.isEmpty) {
      return false;
    }
    
    return true;
  } catch (e) {
    print('Error checking TTS engine: $e');
    return false;
  }
}
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      print('Error stopping TTS: $e');
    }
    _currentSpeakingId = null;
  }
  
  Future<void> speak({
    required String id,
    required String text,
    required String language,
    double speechRate = 0.45,
    double pitch = 1.0,
  }) async {
    if (!_isInitialized) {
      await init();
    }
    
    // If already speaking the same id, stop it
    if (_currentSpeakingId == id) {
      await stop();
      return;
    }
    
    // Stop any current speech
    await stop();
    
    try {
      // Get best available language
      final availableLanguage = await _getBestAvailableLanguage(language);
      print('Using language: $availableLanguage for requested: $language');
      
      // Set language
      final languageResult = await _tts.setLanguage(availableLanguage);
      if (languageResult == 0) {
        throw Exception('Language not supported: $availableLanguage');
      }
      
      // Set speech parameters with platform-specific adjustments
      if (Platform.isAndroid) {
        await _tts.setSpeechRate(speechRate * 0.75); // Android tends to be faster
      } else {
        await _tts.setSpeechRate(speechRate);
      }
      
      await _tts.setPitch(pitch);
      await _tts.setVolume(1.0);
      
      // Set speaking ID before speaking
      _currentSpeakingId = id;
      
      // Speak with retry logic
      final result = await _tts.speak(text);
      
      if (result == 0) {
        throw Exception('Failed to start speech');
      }
      
    } catch (e) {
      print('TTS speak error: $e');
      _currentSpeakingId = null;
      onError?.call('Failed to speak: $e');
    }
  }
  
  Future<void> dispose() async {
    try {
      await _tts.stop();
    } catch (e) {
      print('Error disposing TTS: $e');
    }
    _isInitialized = false;
  }
  
  // Utility method to check TTS availability
  Future<bool> isTtsAvailable() async {
    try {
      final engines = await _tts.getEngines;
      return engines != null && engines.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  // Get available languages for debugging
  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _tts.getLanguages;
      return languages?.map((e) => e.toString()).toList() ?? [];
    } catch (e) {
      return [];
    }
  }
}