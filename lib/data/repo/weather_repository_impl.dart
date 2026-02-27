import '../../domain/repositories/weather_repository.dart';
import '../../core/weather.dart';
import '../data_sources/weather_local_datasource.dart';
import '../data_sources/weather_remote_datasource.dart';
import '../models/weather.dart';
import '../utils/weather_icon_api.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource, {
    Duration cacheTtl = const Duration(minutes: 30),
  }) : _cacheTtl = cacheTtl;

  final OpenWeatherRemoteDataSource _remoteDataSource;
  final WeatherLocalDataSource _localDataSource;
  final Duration _cacheTtl;

  @override
  Future<WeatherReport> getWeatherReportByCity(
    String city, {
    bool isOnline = true,
  }) async {
    final trimmedCity = city.trim();
    if (trimmedCity.isEmpty) {
      throw Exception('City is required');
    }

    final cached = _localDataSource.getWeatherReportByCity(trimmedCity);
    if (cached != null && _isCacheFresh(cached.fetchedAt)) {
      return cached;
    }
    if (!isOnline) {
      if (cached != null) {
        return cached;
      }
      throw Exception('Offline mode: no cached weather available.');
    }

    try {
      final report = await _fetchRemoteWeatherReport(trimmedCity);
      await _localDataSource.saveWeatherReport(
        city: trimmedCity,
        report: report,
      );
      return report;
    } catch (_) {
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  WeatherReport? getLastCachedWeatherReport() {
    return _localDataSource.getLastWeatherReport();
  }

  Future<WeatherReport> _fetchRemoteWeatherReport(String city) async {
    final currentJson = await _remoteDataSource.fetchCurrentByCity(city);
    final current = CurrentWeatherModel.fromJson(currentJson).toDomain();
    final coord = currentJson['coord'] as Map<String, dynamic>?;
    final lat = (coord?['lat'] as num?)?.toDouble();
    final lon = (coord?['lon'] as num?)?.toDouble();
    if (lat == null || lon == null) {
      throw Exception('Missing coordinates for selected city');
    }

    final oneCallJson = await _remoteDataSource.fetchOneCallByCoordinates(
      latitude: lat,
      longitude: lon,
    );
    final hourlyData =
        (oneCallJson['hourly'] as Map<String, dynamic>?) ?? const {};
    final dailyData =
        (oneCallJson['daily'] as Map<String, dynamic>?) ?? const {};

    return WeatherReport(
      current: current,
      hourly: _mapHourly(hourlyData),
      daily: _mapDaily(dailyData),
      fetchedAt: DateTime.now(),
    );
  }

  List<HourlyForecast> _mapHourly(Map<String, dynamic> hourlyData) {
    final times = (hourlyData['time'] as List<dynamic>? ?? const [])
        .cast<String>();
    final temperatures =
        (hourlyData['temperature_2m'] as List<dynamic>? ?? const []);
    final precipitation =
        (hourlyData['precipitation_probability'] as List<dynamic>? ?? const []);
    final weatherCodes =
        (hourlyData['weathercode'] as List<dynamic>? ?? const []);
    final limit = _minLength([
      times.length,
      temperatures.length,
      precipitation.length,
      weatherCodes.length,
      24,
    ]);

    return List.generate(limit, (index) {
      final weatherInfo = _weatherFromCode(
        (weatherCodes[index] as num?)?.toInt() ?? 0,
      );
      return HourlyForecast(
        time: DateTime.tryParse(times[index]) ?? DateTime.now(),
        temperature: (temperatures[index] as num?)?.toDouble() ?? 0,
        description: weatherInfo.description,
        iconCode: weatherInfo.iconCode,
        iconUrl: WeatherIconApi.forecastIconUrl(weatherInfo.iconCode),
        precipitationProbability:
            ((precipitation[index] as num?)?.toDouble() ?? 0) / 100,
      );
    }, growable: false);
  }

  List<DailyForecast> _mapDaily(Map<String, dynamic> dailyData) {
    final times = (dailyData['time'] as List<dynamic>? ?? const [])
        .cast<String>();
    final mins =
        (dailyData['temperature_2m_min'] as List<dynamic>? ?? const []);
    final maxs =
        (dailyData['temperature_2m_max'] as List<dynamic>? ?? const []);
    final weatherCodes =
        (dailyData['weathercode'] as List<dynamic>? ?? const []);
    final limit = _minLength([
      times.length,
      mins.length,
      maxs.length,
      weatherCodes.length,
      7,
    ]);

    return List.generate(limit, (index) {
      final weatherInfo = _weatherFromCode(
        (weatherCodes[index] as num?)?.toInt() ?? 0,
      );
      final dateTime = DateTime.tryParse(times[index]) ?? DateTime.now();
      return DailyForecast(
        date: DateTime(dateTime.year, dateTime.month, dateTime.day),
        minTemperature: (mins[index] as num?)?.toDouble() ?? 0,
        maxTemperature: (maxs[index] as num?)?.toDouble() ?? 0,
        description: weatherInfo.description,
        iconCode: weatherInfo.iconCode,
        iconUrl: WeatherIconApi.forecastIconUrl(weatherInfo.iconCode),
      );
    }, growable: false);
  }

  int _minLength(List<int> values) {
    var min = values.first;
    for (var i = 1; i < values.length; i++) {
      if (values[i] < min) {
        min = values[i];
      }
    }
    return min;
  }

  ({String description, String iconCode}) _weatherFromCode(int code) {
    switch (code) {
      case 0:
        return (description: 'clear sky', iconCode: '01d');
      case 1:
      case 2:
        return (description: 'partly cloudy', iconCode: '02d');
      case 3:
        return (description: 'overcast', iconCode: '04d');
      case 45:
      case 48:
        return (description: 'fog', iconCode: '50d');
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return (description: 'drizzle', iconCode: '09d');
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
        return (description: 'rain', iconCode: '10d');
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return (description: 'snow', iconCode: '13d');
      case 95:
      case 96:
      case 99:
        return (description: 'thunderstorm', iconCode: '11d');
      default:
        return (description: 'weather', iconCode: '03d');
    }
  }

  bool _isCacheFresh(DateTime fetchedAt) {
    return DateTime.now().difference(fetchedAt) < _cacheTtl;
  }
}
