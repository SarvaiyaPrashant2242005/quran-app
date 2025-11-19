import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_verse_admin/controllers/verse_controller.dart';
import 'package:quran_verse_admin/firebase_options.dart';
import 'package:quran_verse_admin/screens/login_screen.dart';
import 'package:quran_verse_admin/widgets/app_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final controller = context.read<VerseController>();
    await controller.init();
    if (!mounted) return;
    unawaited(Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/App_Icon.png', width: 120, height: 120),
              const SizedBox(height: 16),
              Image.asset('assets/images/allysoft_logo.png', height: 36),
              const SizedBox(height: 24),
              Image.asset('assets/images/loader.gif', height: 48),
              const SizedBox(height: 12),
              const Text('Developed by Allysoft'),
            ],
          ),
        ),
      ),
    );
  }
}
