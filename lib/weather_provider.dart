import 'package:flutter/material.dart';
import 'package:login/weather_model.dart';
import 'package:login/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _service = WeatherService();

  WeatherModel? weather;
  String city = "Karachi";
  bool isLoading = false;
  String? error;

  Future<void> loadWeather([String? newCity]) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      if (newCity != null) city = newCity;

      final coords = await _service.getCoordinates(city);
      weather = await _service.fetchWeather(coords['lat']!, coords['lon']!);
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
