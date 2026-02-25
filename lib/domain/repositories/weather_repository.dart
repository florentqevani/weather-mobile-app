import '../weather.dart';

abstract class WeatherRepository {
  Future<WeatherReport> getWeatherReportByCity(
    String city, {
    bool isOnline = true,
  });
  WeatherReport? getLastCachedWeatherReport();
}
