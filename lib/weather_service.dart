import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:login/weather_model.dart';

class WeatherService {
  // 🔍 Convert city → lat/lon
  Future<Map<String, double>> getCoordinates(String city) async {
    final url = Uri.parse(
      "https://geocoding-api.open-meteo.com/v1/search?name=$city",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['results'] != null && data['results'].isNotEmpty) {
        return {
          "lat": data['results'][0]['latitude'],
          "lon": data['results'][0]['longitude'],
        };
      } else {
        throw Exception("City not found");
      }
    } else {
      throw Exception("Geocoding failed");
    }
  }

  // 🌤 Get weather by coordinates
  Future<WeatherModel> fetchWeather(double lat, double lon) async {
    final url = Uri.parse(
      "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&timezone=auto",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Weather fetch failed");
    }
  }
}
