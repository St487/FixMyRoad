import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static const String baseUrl = "https://api.countrystatecity.in/v1";
  static const String apiKey = "55585edf8004c988498925f046667ef8fce10c095b42e0c1979f41394bc53c80";

  static Map<String, String> get headers => {
        'X-CSCAPI-KEY': apiKey,
        'Content-Type': 'application/json',
      };

  static Future<List<Map<String, dynamic>>> fetchStates() async {
    final response = await http.get(
      Uri.parse("$baseUrl/countries/MY/states"), // MY = Malaysia ISO2
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> fetchCities(String stateIso) async {
    final response = await http.get(
      Uri.parse("$baseUrl/countries/MY/states/$stateIso/cities"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }
}