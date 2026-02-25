import 'package:connectivity_plus/connectivity_plus.dart';

abstract class WeatherEvent {
  const WeatherEvent();
}

class WeatherInitialized extends WeatherEvent {
  const WeatherInitialized();
}

class WeatherSearchRequested extends WeatherEvent {
  const WeatherSearchRequested(this.city);

  final String city;
}

class WeatherRefreshRequested extends WeatherEvent {
  const WeatherRefreshRequested();
}

class WeatherRetryRequested extends WeatherEvent {
  const WeatherRetryRequested();
}

class WeatherToggleFavoriteRequested extends WeatherEvent {
  const WeatherToggleFavoriteRequested(this.city);

  final String city;
}

class WeatherFavoriteCitiesLoadRequested extends WeatherEvent {
  const WeatherFavoriteCitiesLoadRequested();
}

class WeatherConnectivityChanged extends WeatherEvent {
  const WeatherConnectivityChanged(this.results);

  final List<ConnectivityResult> results;
}
