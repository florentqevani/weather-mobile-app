import '../repositories/weather_repository.dart';
import '../weather.dart';

class GetWeatherReport {
  const GetWeatherReport(this._repository);

  final WeatherRepository _repository;

  Future<WeatherReport> call(String city, {bool isOnline = true}) {
    return _repository.getWeatherReportByCity(city, isOnline: isOnline);
  }

  WeatherReport? lastCached() {
    return _repository.getLastCachedWeatherReport();
  }
}
