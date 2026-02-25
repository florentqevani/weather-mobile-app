import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenWeatherRemoteDataSource {
  OpenWeatherRemoteDataSource({
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const _openMeteoUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<Map<String, dynamic>> fetchCurrentByCity(String city) async {
    final uri = Uri.parse('$_baseUrl/weather').replace(
      queryParameters: {
        'q': city,
        'appid': apiKey,
        'units': 'metric',
      },
    );

    return _getJson(uri);
  }

  Future<Map<String, dynamic>> fetchForecastByCity(String city) async {
    final uri = Uri.parse('$_baseUrl/forecast').replace(
      queryParameters: {
        'q': city,
        'appid': apiKey,
        'units': 'metric',
      },
    );

    return _getJson(uri);
  }

  Future<Map<String, dynamic>> fetchOneCallByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_openMeteoUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'hourly': 'temperature_2m,precipitation_probability,weathercode',
        'daily': 'temperature_2m_max,temperature_2m_min,weathercode',
        'forecast_days': '7',
        'timezone': 'auto',
      },
    );

    return _getJson(uri);
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    final body = response.body;
    final message = body.isNotEmpty ? body : 'Failed to fetch weather data';
    throw Exception('Weather API error (${response.statusCode}): $message');
  }
}
