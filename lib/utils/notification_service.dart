import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart'; // Added for sound
import '../utils/myconfig.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal();

  Timer? _timer;
  Map<String, String> previousStatuses = {};
  String? lastNotifiedKey;
  
  // Initialize the AudioPlayer
  final AudioPlayer _audioPlayer = AudioPlayer();

  void start(String userId, GlobalKey<NavigatorState> navigatorKey) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkStatus(userId, navigatorKey);
    });
  }

  void stop() {
    _timer?.cancel();
  }

  Future<void> _checkStatus(
      String userId, GlobalKey<NavigatorState> navigatorKey) async {
    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/check_status.php"),
        body: {"user_id": userId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          List issues = data['issues'];

          for (var issue in issues) {
            String id = issue['id'].toString();
            String newStatus = issue['status'];
            String issueType = issue['issue_type'];
            issueType = formatIssueType(issueType);

            String currentKey = "$id-$newStatus";

            if (previousStatuses.containsKey(id)) {
              String oldStatus = previousStatuses[id]!;

              if (oldStatus != newStatus && lastNotifiedKey != currentKey) {
                lastNotifiedKey = currentKey;
                String formattedStatus = formatStatus(newStatus);

                _showTopNotification(
                  navigatorKey,
                  "Your report \"$issueType\" is $formattedStatus",
                );
              }
            }
            previousStatuses[id] = newStatus;
          }
        }
      }
    } catch (e) {
      print("Notification error: $e");
    }
  }

  String formatStatus(String text) {
    if (text == "in_progress") return "In Progress";
    return text
        .replaceAll("_", " ")
        .split(" ")
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : "")
        .join(" ");
  }

  String formatIssueType(String text) {
    return text
        .replaceAll("_", " ")
        .split(" ")
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : "")
        .join(" ");
  }

  void _showTopNotification(
      GlobalKey<NavigatorState> navigatorKey, String message) {
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    // Trigger Sound Effect
    _playSound();

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => _NotificationVisuals(
        message: message,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlayState.insert(overlayEntry);
  }

  // Sound logic
  Future<void> _playSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }
}

class _NotificationVisuals extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const _NotificationVisuals({required this.message, required this.onDismiss});

  @override
  State<_NotificationVisuals> createState() => _NotificationVisualsState();
}

class _NotificationVisualsState extends State<_NotificationVisuals>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () async {
      if (mounted) {
        await _controller.reverse();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SlideTransition(
            position: _offsetAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blueAccent.withOpacity(0.8),
                              Colors.indigo.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 18,
                              child: Icon(Icons.notifications_active, 
                                color: Colors.blueAccent, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "NEW UPDATE",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  Text(
                                    widget.message,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}