# Ma'na - Quran Learning App

Ma'na is an interactive Quran study application that helps users learn Arabic words from the Quran with their meanings and pronunciations in multiple languages.

## 🌟 Features

### Core Learning Features
- **Word-by-Word Learning**: Study individual Quranic words with detailed information
- **Multi-language Support**: Arabic text with English and Urdu translations
- **Pronunciation Guide**: Phonetic pronunciation for each Arabic word
- **Text-to-Speech**: Listen to Arabic pronunciation and translations
- **Progress Tracking**: Visual progress indicators and learning statistics
- **Smart Resume**: Automatically continue from your last learned word

### Interactive Quiz System
- **Knowledge Testing**: Quiz yourself on learned words
- **Multiple Choice**: 4-option multiple choice questions
- **Audio Support**: Listen to questions and options
- **Score Tracking**: Track your quiz performance and high scores
- **Adaptive Learning**: Quiz only includes words you've already learned

### User Experience
- **Beautiful Interface**: Islamic-themed UI with Quran background imagery
- **Smooth Navigation**: Swipe between verses with page indicators
- **Settings Panel**: Sync data, check TTS status, reset progress
- **Offline Support**: Works without internet connection
- **Screen Protection**: Prevents screenshots for content security

## 📱 App Structure

### Screens
- **SplashScreen**: App initialization and loading
- **Homepage**: Main learning interface with verse cards
- **QuizScreen**: Interactive quiz with multiple choice questions
- **SettingsScreen**: App settings, sync, and progress management

### Key Components
- **VerseHeader**: Displays verse information and word details
- **LanguageCard**: Shows text in different languages with TTS support
- **PageIndicator**: Shows current position in the learning sequence
- **LoadingOverlay**: Loading states during data operations

## 🏗️ Architecture

### State Management
- **GetX**: Primary state management solution
- **HomeController**: Manages learning data, progress, and quiz state
- **Reactive UI**: Obx widgets for automatic UI updates

### Data Flow
```
Firebase Firestore → Local Storage → HomeController → UI Components
```

### Services
- **TTS Service**: Text-to-speech functionality for Arabic and translations
- **Firebase Service**: Cloud data synchronization
- **Local Storage**: SharedPreferences for offline data persistence

## 📂 Folder Structure

```
lib/
├── bindings/
│   └── home_binding.dart           # Dependency injection setup
├── controller/
│   └── home_controller.dart        # Main app state controller
├── models/
│   └── verse_data.dart            # Data models for verses
├── screens/
│   ├── Homepage.dart              # Main learning screen
│   ├── QuizScreen.dart            # Quiz interface
│   ├── SettingsScreen.dart        # Settings and sync
│   └── SplashScreen.dart          # App initialization
├── services/
│   └── tts_service.dart           # Text-to-speech service
├── widgets/
│   ├── verse_header.dart          # Verse information display
│   ├── language_card.dart         # Multi-language text cards
│   ├── page_indicator.dart        # Navigation indicator
│   └── loading_overlay.dart       # Loading state overlay
├── firebase_options.dart          # Firebase configuration
└── main.dart                      # App entry point
```

## 🔧 Configuration

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.7.2                    # State management
  firebase_core: ^3.4.0         # Firebase core
  cloud_firestore: ^5.4.4       # Firestore database
  flutter_tts: ^3.8.0           # Text-to-speech
  shared_preferences: ^2.2.3     # Local storage
  provider: ^6.1.5+1            # Additional state management
  audioplayers: ^6.5.1          # Audio playback
  url_launcher: ^6.3.2          # URL handling
  screen_protector: ^1.4.0      # Screen protection
```

### Assets
```yaml
assets:
  - assets/data.json             # Local verse data
  - assets/images/allysoft_logo.png
  - assets/images/loader.gif
  - assets/images/App_icon.png
  - assets/images/quran_background.jpg
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2+
- Firebase project with Firestore enabled
- Android/iOS development environment

### Installation
1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure Firebase**
   - Add your `google-services.json` (Android) to `android/app/`
   - Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`

3. **Run the app**
   ```bash
   flutter run
   ```

### Firebase Setup
1. Create a Firestore collection named `verses`
2. Structure documents with fields:
   - `rank`: String (e.g., "#1")
   - `word`: String (Arabic word)
   - `pronounce`: String (pronunciation)
   - `meaning_en`: String (English meaning)
   - `meaning_ur`: String (Urdu meaning)
   - `times`: String (frequency info)
   - `arabic`: String (full Arabic verse)
   - `english`: String (English translation)
   - `urdu`: String (Urdu translation)

## 📊 Data Management

### Learning Progress
- Progress is stored locally using SharedPreferences
- Learned words are tracked by index
- Quiz scores and statistics are persisted
- Resume position is automatically saved

### Synchronization
- Manual sync from Settings screen
- Fetches latest data from Firestore
- Updates local storage with new content
- Preserves user progress during sync

## 🎯 Usage

### Learning Flow
1. **Start Learning**: App opens to the first unlearned word
2. **Study Word**: View Arabic word, pronunciation, and meanings
3. **Listen**: Use TTS to hear correct pronunciation
4. **Navigate**: Swipe or tap to move between words
5. **Track Progress**: Visual indicators show learning status

### Quiz Flow
1. **Access Quiz**: Tap Quiz tab (requires 5+ learned words)
2. **Answer Questions**: Select correct meaning for Arabic words
3. **Get Feedback**: Immediate feedback on answers
4. **View Results**: Final score and performance summary
5. **Retake**: Option to retake quiz for better scores

### Settings Options
- **Sync Data**: Update content from Firestore
- **Check TTS**: Verify text-to-speech availability
- **Reset Progress**: Clear all learning data
- **View Statistics**: See learning progress and quiz scores

## 🔊 Text-to-Speech

### Supported Languages
- **Arabic**: `ar-SA` for Quranic words
- **English**: `en-US` for translations
- **Urdu**: `ur-PK` for Urdu meanings

### Features
- Play/pause controls
- Adjustable speech rate and pitch
- Visual feedback during playback
- Error handling for unsupported devices

## 🎨 UI/UX Design

### Theme
- Islamic-inspired color scheme
- Quran background imagery
- Gradient overlays for readability
- Material Design components

### Responsive Design
- Adapts to different screen sizes
- Optimized for both phones and tablets
- Smooth animations and transitions
- Accessibility considerations

## 🐛 Troubleshooting

### Common Issues
1. **TTS Not Working**: Check device TTS settings and language packs
2. **Sync Failures**: Verify internet connection and Firebase configuration
3. **Progress Lost**: Ensure app has storage permissions
4. **Audio Issues**: Check device volume and audio permissions

### Debug Mode
- Enable debug mode in `main.dart`
- Check console logs for detailed error information
- Use Flutter Inspector for UI debugging

## 📈 Performance

### Optimization
- Lazy loading of verse data
- Efficient state management with GetX
- Image caching for better performance
- Minimal memory footprint

### Best Practices
- Regular data cleanup
- Efficient widget rebuilding
- Proper resource disposal
- Battery-friendly background operations

---

**Ma'na** - Your companion for understanding the Quran, one word at a time.