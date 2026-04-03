import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Duration duration;
  final double? width;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.width,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) {
        setState(() => isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedScale(
        duration: widget.duration,
        scale: isPressed ? 0.95 : 1.0,
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: Curves.easeInOut,
          width: widget.width ?? double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPressed
              ? [
                  Color.fromARGB(255, 197, 153, 183),
                  Color.fromARGB(255, 163, 156, 198),
                ]
              : [
                  Color.fromARGB(255, 241, 184, 217),
                  Color.fromARGB(255, 206, 196, 244),
                ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: isPressed
            ? [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 4),
                ),
              ],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}