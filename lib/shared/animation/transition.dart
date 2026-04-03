import 'package:flutter/material.dart';

class TransitionButton extends StatelessWidget {
  final Widget page;
  final String text;
  final int durationMs;

  const TransitionButton({
    super.key,
    required this.page,
    required this.text,
    this.durationMs = 400,
  });

  // Static method for direct navigation with slide transition
  static void navigateWithSlide(BuildContext context, Widget page, {int durationMs = 400}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide from right to left
          const begin = Offset(1.0, 0.0); // Start just outside right
          const end = Offset.zero;        // End at original position
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: durationMs),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        navigateWithSlide(context, page, durationMs: durationMs);
      },
      child: Text(text),
    );
  }
}
