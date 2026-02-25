import '../../domain/weather.dart';
import '../utils/weather_icon_api.dart';

class CurrentWeatherModel {
  const CurrentWeatherModel({
    required this.city,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.timestamp,
  });

  factory CurrentWeatherModel.fromJson(Map<String, dynamic> json) {
    final weather =
        (json['weather'] as List<dynamic>).first as Map<String, dynamic>;
    final main = json['main'] as Map<String, dynamic>;
    final wind = (json['wind'] as Map<String, dynamic>?) ?? const {};
    final sys = (json['sys'] as Map<String, dynamic>?) ?? const {};

    return CurrentWeatherModel(
      city: (json['name'] ?? '').toString(),
      country: (sys['country'] ?? '').toString(),
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      description: (weather['description'] ?? '').toString(),
      iconCode: (weather['icon'] ?? '').toString(),
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
      pressure: (main['pressure'] as num?)?.toInt() ?? 0,
      timestamp: ((json['dt'] as num?)?.toInt() ?? 0),
    );
  }

  final String city;
  final String country;
  final double temperature;
  final double feelsLike;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final int timestamp;

  CurrentWeather toDomain() {
    return CurrentWeather(
      city: city,
      country: country,
      temperature: temperature,
      feelsLike: feelsLike,
      description: description,
      iconCode: iconCode,
      iconUrl: WeatherIconApi.currentIconUrl(iconCode),
      humidity: humidity,
      windSpeed: windSpeed,
      pressure: pressure,
      observedAt: DateTime.fromMillisecondsSinceEpoch(
        timestamp * 1000,
        isUtc: true,
      ).toLocal(),
    );
  }
}

class ForecastItemModel {
  const ForecastItemModel({
    required this.timestamp,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.iconCode,
    required this.precipitationProbability,
  });

  factory ForecastItemModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather =
        (json['weather'] as List<dynamic>).first as Map<String, dynamic>;

    final temperature = (main['temp'] as num).toDouble();

    return ForecastItemModel(
      timestamp: ((json['dt'] as num?)?.toInt() ?? 0),
      temperature: temperature,
      tempMin: (main['temp_min'] as num?)?.toDouble() ?? temperature,
      tempMax: (main['temp_max'] as num?)?.toDouble() ?? temperature,
      description: (weather['description'] ?? '').toString(),
      iconCode: (weather['icon'] ?? '').toString(),
      precipitationProbability: (json['pop'] as num?)?.toDouble() ?? 0,
    );
  }

  final int timestamp;
  final double temperature;
  final double tempMin;
  final double tempMax;
  final String description;
  final String iconCode;
  final double precipitationProbability;

  DateTime get localDateTime => DateTime.fromMillisecondsSinceEpoch(
    timestamp * 1000,
    isUtc: true,
  ).toLocal();

  HourlyForecast toHourlyDomain() {
    return HourlyForecast(
      time: localDateTime,
      temperature: temperature,
      description: description,
      iconCode: iconCode,
      iconUrl: WeatherIconApi.forecastIconUrl(iconCode),
      precipitationProbability: precipitationProbability,
    );
  }
}
