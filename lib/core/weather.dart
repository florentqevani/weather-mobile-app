class WeatherReport {
  const WeatherReport({
    required this.current,
    required this.hourly,
    required this.daily,
    required this.fetchedAt,
  });

  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final DateTime fetchedAt;
}

class CurrentWeather {
  const CurrentWeather({
    required this.city,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.iconCode,
    required this.iconUrl,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.observedAt,
  });

  final String city;
  final String country;
  final double temperature;
  final double feelsLike;
  final String description;
  final String iconCode;
  final String iconUrl;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final DateTime observedAt;
}

class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.iconUrl,
    required this.precipitationProbability,
  });

  final DateTime time;
  final double temperature;
  final String description;
  final String iconCode;
  final String iconUrl;
  final double precipitationProbability;
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.minTemperature,
    required this.maxTemperature,
    required this.description,
    required this.iconCode,
    required this.iconUrl,
  });

  final DateTime date;
  final double minTemperature;
  final double maxTemperature;
  final String description;
  final String iconCode;
  final String iconUrl;
}
