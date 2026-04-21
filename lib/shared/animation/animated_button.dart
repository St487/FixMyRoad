import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Duration duration;
  final double? width;
  final bool isLoading;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.width,
    this.isLoading = false,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading
          ? null
          : (_) => setState(() => isPressed = true),

      onTapUp: widget.isLoading
          ? null
          : (_) {
              setState(() => isPressed = false);
              widget.onPressed?.call();
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
          padding: const EdgeInsets.symmetric(vertical: 12),

          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isLoading
                  ? [
                      Colors.grey.shade400,
                      Colors.grey.shade300,
                    ]
                  : isPressed
                      ? [
                          const Color.fromARGB(255, 197, 153, 183),
                          const Color.fromARGB(255, 163, 156, 198),
                        ]
                      : [
                          const Color.fromARGB(255, 241, 184, 217),
                          const Color.fromARGB(255, 206, 196, 244),
                        ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: widget.isLoading
                ? []
                : isPressed
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

          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : widget.child,
          ),
        ),
      ),
    );
  }
}