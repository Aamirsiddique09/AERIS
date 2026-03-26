class WeatherModel {
  final double temperature;
  final double windspeed;

  WeatherModel({required this.temperature, required this.windspeed});

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: json['current_weather']['temperature'],
      windspeed: json['current_weather']['windspeed'],
    );
  }
}
