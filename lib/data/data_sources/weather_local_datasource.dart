import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/weather.dart';
import '../utils/weather_icon_api.dart';

class WeatherLocalDataSource {
  WeatherLocalDataSource(this._box);

  static const boxName = 'weather_cache';
  static const _latestCityStorageKey = '__latest_city__';
  final Box<String> _box;

  Future<void> saveWeatherReport({
    required String city,
    required WeatherReport report,
  }) async {
    final key = _cityKey(city);
    await _box.put(key, jsonEncode(_weatherReportToJson(report)));
    await _box.put(_latestCityStorageKey, key);
  }

  WeatherReport? getWeatherReportByCity(String city) {
    final payload = _box.get(_cityKey(city));
    if (payload == null || payload.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return _weatherReportFromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  WeatherReport? getLastWeatherReport() {
    final latestCity = _box.get(_latestCityStorageKey);
    if (latestCity == null || latestCity.isEmpty) {
      return null;
    }
    return getWeatherReportByCity(latestCity);
  }

  String _cityKey(String city) => city.trim().toLowerCase();

  Map<String, dynamic> _weatherReportToJson(WeatherReport report) {
    return {
      'fetchedAt': report.fetchedAt.toIso8601String(),
      'current': {
        'city': report.current.city,
        'country': report.current.country,
        'temperature': report.current.temperature,
        'feelsLike': report.current.feelsLike,
        'description': report.current.description,
        'iconCode': report.current.iconCode,
        'iconUrl': report.current.iconUrl,
        'humidity': report.current.humidity,
        'windSpeed': report.current.windSpeed,
        'pressure': report.current.pressure,
        'observedAt': report.current.observedAt.toIso8601String(),
      },
      'hourly': report.hourly
          .map(
            (item) => {
              'time': item.time.toIso8601String(),
              'temperature': item.temperature,
              'description': item.description,
              'iconCode': item.iconCode,
              'iconUrl': item.iconUrl,
              'precipitationProbability': item.precipitationProbability,
            },
          )
          .toList(growable: false),
      'daily': report.daily
          .map(
            (item) => {
              'date': item.date.toIso8601String(),
              'minTemperature': item.minTemperature,
              'maxTemperature': item.maxTemperature,
              'description': item.description,
              'iconCode': item.iconCode,
              'iconUrl': item.iconUrl,
            },
          )
          .toList(growable: false),
    };
  }

  WeatherReport _weatherReportFromJson(Map<String, dynamic> json) {
    final currentJson = _asMap(json['current']);
    final hourlyJson = _asListOfMaps(json['hourly']);
    final dailyJson = _asListOfMaps(json['daily']);

    return WeatherReport(
      current: CurrentWeather(
        city: _asString(currentJson['city']),
        country: _asString(currentJson['country']),
        temperature: _asDouble(currentJson['temperature']),
        feelsLike: _asDouble(currentJson['feelsLike']),
        description: _asString(currentJson['description']),
        iconCode: _currentIconCode(currentJson),
        iconUrl: _currentIconUrl(currentJson),
        humidity: _asInt(currentJson['humidity']),
        windSpeed: _asDouble(currentJson['windSpeed']),
        pressure: _asInt(currentJson['pressure']),
        observedAt: _asDateTime(currentJson['observedAt']),
      ),
      hourly: hourlyJson
          .map(
            (item) => HourlyForecast(
              time: _asDateTime(item['time']),
              temperature: _asDouble(item['temperature']),
              description: _asString(item['description']),
              iconCode: _forecastIconCode(item),
              iconUrl: _forecastIconUrl(item),
              precipitationProbability: _asDouble(
                item['precipitationProbability'],
              ),
            ),
          )
          .toList(growable: false),
      daily: dailyJson
          .map(
            (item) => DailyForecast(
              date: _asDateTime(item['date']),
              minTemperature: _asDouble(item['minTemperature']),
              maxTemperature: _asDouble(item['maxTemperature']),
              description: _asString(item['description']),
              iconCode: _forecastIconCode(item),
              iconUrl: _forecastIconUrl(item),
            ),
          )
          .toList(growable: false),
      fetchedAt: _asDateTime(json['fetchedAt']),
    );
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return const {};
  }

  List<Map<String, dynamic>> _asListOfMaps(Object? value) {
    if (value is! List) {
      return const [];
    }
    return value.map(_asMap).toList(growable: false);
  }

  String _asString(Object? value) => (value ?? '').toString();

  int _asInt(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(_asString(value)) ?? 0;
  }

  double _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(_asString(value)) ?? 0;
  }

  DateTime _asDateTime(Object? value) {
    final parsed = DateTime.tryParse(_asString(value));
    return parsed ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _currentIconCode(Map<String, dynamic> item) {
    return _asString(item['iconCode']);
  }

  String _currentIconUrl(Map<String, dynamic> item) {
    final iconUrl = _asString(item['iconUrl']);
    if (iconUrl.isNotEmpty) {
      return iconUrl;
    }
    return WeatherIconApi.currentIconUrl(_currentIconCode(item));
  }

  String _forecastIconCode(Map<String, dynamic> item) {
    return _asString(item['iconCode']);
  }

  String _forecastIconUrl(Map<String, dynamic> item) {
    final iconUrl = _asString(item['iconUrl']);
    if (iconUrl.isNotEmpty) {
      return iconUrl;
    }
    return WeatherIconApi.forecastIconUrl(_forecastIconCode(item));
  }
}
