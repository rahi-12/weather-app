class WeatherModel {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int weatherCode;

  final List<String> hourlyTime;
  final List<double> hourlyTemperature;
  final List<int> hourlyWeatherCode;

  final List<String> dailyTime;
  final List<double> dailyMaxTemperature;
  final List<double> dailyMinTemperature;
  final List<int> dailyWeatherCode;

  final String sunrise;
  final String sunset;

  WeatherModel({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.hourlyTime,
    required this.hourlyTemperature,
    required this.hourlyWeatherCode,
    required this.dailyTime,
    required this.dailyMaxTemperature,
    required this.dailyMinTemperature,
    required this.dailyWeatherCode,
    required this.sunrise,
    required this.sunset,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final hourly = json['hourly'];
    final daily = json['daily'];

    return WeatherModel(
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),

      hourlyTime: List<String>.from(hourly['time']),
      hourlyTemperature: List<num>.from(hourly['temperature_2m'])
          .map((e) => e.toDouble())
          .toList(),
      hourlyWeatherCode: List<num>.from(hourly['weather_code'])
          .map((e) => e.toInt())
          .toList(),

      dailyTime: List<String>.from(daily['time']),
      dailyMaxTemperature: List<num>.from(daily['temperature_2m_max'])
          .map((e) => e.toDouble())
          .toList(),
      dailyMinTemperature: List<num>.from(daily['temperature_2m_min'])
          .map((e) => e.toDouble())
          .toList(),
      dailyWeatherCode: List<num>.from(daily['weather_code'])
          .map((e) => e.toInt())
          .toList(),

      sunrise: daily['sunrise'][0],
      sunset: daily['sunset'][0],
    );
  }
}
