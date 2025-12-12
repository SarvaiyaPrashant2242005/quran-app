import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_verse_admin/controllers/verse_controller.dart';
import 'package:quran_verse_admin/screens/home_screen.dart';
import 'package:quran_verse_admin/screens/words_screen.dart';
import 'package:quran_verse_admin/widgets/app_background.dart';
import 'package:flutter/foundation.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [HomeScreen(), WordsScreen()];

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<VerseController>().loading;
   return Scaffold(
  body: AppBackground(child: _pages[_index]),

  // HIDE NAV BAR ON WEB
  bottomNavigationBar: kIsWeb
      ? null
      : NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Words',
            ),
          ],
        ),

  // HIDE LOADING FAB ON WEB
  floatingActionButton: (!kIsWeb && loading) ? const _BusyFAB() : null,
  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
);

  }
}

class _BusyFAB extends StatelessWidget {
  const _BusyFAB();
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      onPressed: null,
      backgroundColor: Colors.white.withOpacity(0.25),
      elevation: 0,
      child: Image.asset('assets/images/loader.gif', height: 24),
    );
  }
}
