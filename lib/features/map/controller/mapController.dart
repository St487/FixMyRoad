import 'dart:convert';
import 'package:fix_my_road/utils/myconfig.dart';
import 'package:http/http.dart' as http;

class MapController {

  static Future<List<dynamic>> getIssues() async {
    final response = await http.get(Uri.parse("${MyConfig.myurl}/get_issues.php"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["data"];
    } else {
      throw Exception("Failed to load issues");
    }
  }
}