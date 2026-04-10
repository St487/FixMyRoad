import 'dart:convert';
import 'package:fix_my_road/utils/myconfig.dart';
import 'package:http/http.dart' as http;

class ChatbotController {

  static Future<Map<String, dynamic>> sendMessage({
    required String message,
    int? userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/chatbot.php"),
        body: {
          "message": message,
          "user_id": userId?.toString() ?? "",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {
          "reply": "Server error. Please try again.",
          "intent": "error"
        };
      }
    } catch (e) {
      return {
        "reply": "Connection failed. Check your internet/server.",
        "intent": "error"
      };
    }
  }
}