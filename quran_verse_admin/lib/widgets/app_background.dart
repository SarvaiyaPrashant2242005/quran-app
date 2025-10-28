import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        const DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/quran_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Soft dark scrim for readability
        Container(color: Colors.black.withOpacity(0.40)),
        // Blue beam spotlight from top center matching the provided image
        IgnorePointer(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0, -1.0),
                end: Alignment(0, 0.2),
                colors: [
                  Color.fromARGB(140, 64, 118, 255),
                  Color.fromARGB(60, 64, 118, 255),
                  Colors.transparent,
                ],
                stops: [0.0, 0.35, 1.0],
              ),
            ),
          ),
        ),
        // Content
        SafeArea(child: child),
      ],
    );
  }
}
