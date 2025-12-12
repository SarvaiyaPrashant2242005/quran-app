# Ma'na - Quran Study Application

Ma'na is a comprehensive Quran study application that helps users learn and understand Quranic words through interactive learning and quiz features. The project consists of two Flutter applications: a main learning app and an admin panel for content management.

## 🌟 Features

### Main App (Ma'na)
- **Interactive Word Learning**: Study Quranic words with Arabic text, pronunciation, and meanings in English and Urdu
- **Text-to-Speech Support**: Listen to Arabic pronunciation and translations
- **Progress Tracking**: Track your learning progress with visual indicators
- **Smart Resume**: Automatically resume from where you left off
- **Quiz System**: Test your knowledge with interactive quizzes
- **Multi-language Support**: Arabic, English, and Urdu translations
- **Offline Capability**: Works offline with local data storage
- **Beautiful UI**: Islamic-themed interface with Quran background

### Admin Panel
- **Content Management**: Add, edit, and delete Quranic words and verses
- **Real-time Search**: Search through words and meanings
- **Data Synchronization**: Sync data with Firebase Firestore
- **Responsive Design**: Works on desktop and mobile devices
- **Bulk Operations**: Manage multiple entries efficiently

## 📱 About the Apps

**Ma'na** is designed to help Muslims and Arabic learners understand the Quran by focusing on individual words and their meanings. The app presents verses in a card-based interface where users can:

- Learn Arabic words with proper pronunciation
- Understand meanings in multiple languages
- Practice with interactive quizzes
- Track their learning progress
- Resume learning from their last position

The **Admin Panel** allows content managers to maintain the word database, ensuring accurate translations and proper organization of the learning material.
<!-- 
## 🏗️ Project Structure

```
├── maa_na/                 # Main learning application
│   ├── lib/
│   │   ├── screens/        # UI screens (Home, Quiz, Settings)
│   │   ├── controller/     # GetX controllers for state management
│   │   ├── models/         # Data models (Verse, VerseData)
│   │   ├── services/       # Services (TTS, Firebase)
│   │   ├── widgets/        # Reusable UI components
│   │   └── bindings/       # Dependency injection bindings
│   ├── assets/             # Images, data files
│   └── pubspec.yaml        # Dependencies and configuration
│
├── maa_na_Admin/           # Admin panel application
│   ├── lib/
│   │   ├── screens/        # Admin UI screens
│   │   ├── controllers/    # State management controllers
│   │   ├── models/         # Data models
│   │   ├── services/       # Firebase and other services
│   │   └── widgets/        # UI components
│   ├── assets/             # Admin app resources
│   └── pubspec.yaml        # Admin app dependencies
│
└── README.md               # This file
``` -->

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Firebase project setup
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd quran-app
   ```

2. **Setup Main App**
   ```bash
   cd maa_na
   flutter pub get
   flutter run
   ```

3. **Setup Admin Panel**
   ```bash
   cd ../maa_na_Admin
   flutter pub get
   flutter run
   ```

### Firebase Configuration
Both apps require Firebase configuration:
1. Create a Firebase project
2. Add Android/iOS apps to your Firebase project
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place configuration files in respective platform folders
5. Update Firebase configuration in both apps

## 🛠️ Development

### Main App Architecture
- **State Management**: GetX for reactive state management
- **Data Storage**: SharedPreferences for local storage, Firebase for cloud sync
- **Navigation**: GetX routing system
- **UI Framework**: Material Design with custom theming

### Admin Panel Architecture
- **State Management**: Provider pattern
- **Database**: Firebase Firestore
- **UI**: Material Design with responsive layout
- **Authentication**: Firebase Auth (login system)

## 📦 Dependencies

### Main App Key Dependencies
- `get`: State management and routing
- `firebase_core` & `cloud_firestore`: Firebase integration
- `flutter_tts`: Text-to-speech functionality
- `shared_preferences`: Local data persistence
- `provider`: Additional state management
- `audioplayers`: Audio playback support

### Admin Panel Key Dependencies
- `provider`: State management
- `firebase_core` & `cloud_firestore`: Firebase integration
- `flutter`: Core Flutter framework

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Quran text and translations from authentic sources
- Islamic design inspiration
- Flutter community for excellent packages and support

## 📞 Support

For support, email [your-email] or create an issue in the repository.

---

**Ma'na** - Making Quranic learning accessible and engaging for everyone.