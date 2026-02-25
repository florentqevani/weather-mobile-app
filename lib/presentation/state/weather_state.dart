import '../../domain/weather.dart';

abstract class WeatherState {
  const WeatherState({
    required this.favoriteCities,
    required this.isFavoritesLoading,
    required this.favoritesErrorMessage,
    required this.isOffline,
    required this.activeCity,
  });

  final List<String> favoriteCities;
  final bool isFavoritesLoading;
  final String favoritesErrorMessage;
  final bool isOffline;
  final String activeCity;
}

class WeatherLoading extends WeatherState {
  const WeatherLoading({
    required super.favoriteCities,
    required super.isFavoritesLoading,
    required super.favoritesErrorMessage,
    required super.isOffline,
    required super.activeCity,
    this.previousReport,
  });

  final WeatherReport? previousReport;
}

class WeatherSuccess extends WeatherState {
  const WeatherSuccess({
    required this.report,
    required super.favoriteCities,
    required super.isFavoritesLoading,
    required super.favoritesErrorMessage,
    required super.isOffline,
    required super.activeCity,
  });

  final WeatherReport report;
}

class WeatherError extends WeatherState {
  const WeatherError({
    required this.message,
    required super.favoriteCities,
    required super.isFavoritesLoading,
    required super.favoritesErrorMessage,
    required super.isOffline,
    required super.activeCity,
    this.cachedReport,
  });

  final String message;
  final WeatherReport? cachedReport;
}
