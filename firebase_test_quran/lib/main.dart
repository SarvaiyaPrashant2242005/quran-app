import 'package:firebase_test_quran/screens/Homepage.dart';
import 'package:firebase_test_quran/bindings/home_binding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:firebase_test_quran/screens/SplashScreen.dart';
import 'package:screen_protector/screen_protector.dart';
 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Ignore if already initialized
  }
  // Enable screenshot/screen recording protection
  try {
    await ScreenProtector.preventScreenshotOn();
    await ScreenProtector.protectDataLeakageOn();
  } catch (_) {}
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quran Word Frequency',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(
          name: '/home',
          page: () => const MyHomePage(title: 'Quran Word Frequency'),
          binding: HomeBinding(), 
        ),
      ],
    );
  }
}