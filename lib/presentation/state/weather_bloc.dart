import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data_sources/favorite_cities_remote_datasource.dart';
import '../../domain/use_cases/get_weather_report.dart';
import '../../domain/weather.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc({
    required GetWeatherReport getWeatherReport,
    FavoriteCitiesRemoteDataSource? favoriteCitiesDataSource,
    Connectivity? connectivity,
  }) : _getWeatherReport = getWeatherReport,
       _favoriteCitiesDataSource = favoriteCitiesDataSource,
       _connectivity = connectivity ?? Connectivity(),
       super(
         const WeatherLoading(
           favoriteCities: [],
           isFavoritesLoading: false,
           favoritesErrorMessage: '',
           isOffline: false,
           activeCity: '',
         ),
       ) {
    on<WeatherInitialized>(_onInitialized);
    on<WeatherSearchRequested>(_onSearchRequested);
    on<WeatherRefreshRequested>(_onRefreshRequested);
    on<WeatherRetryRequested>(_onRetryRequested);
    on<WeatherToggleFavoriteRequested>(_onToggleFavoriteRequested);
    on<WeatherFavoriteCitiesLoadRequested>(_onLoadFavoriteCitiesRequested);
    on<WeatherConnectivityChanged>(_onConnectivityChanged);

    add(const WeatherInitialized());
  }

  final GetWeatherReport _getWeatherReport;
  final FavoriteCitiesRemoteDataSource? _favoriteCitiesDataSource;
  final Connectivity _connectivity;

  List<String> _favoriteCities = const [];
  bool _isFavoritesLoading = false;
  String _favoritesErrorMessage = '';
  bool _isOffline = false;
  String _activeCity = '';
  String _lastErrorMessage = '';
  WeatherReport? _latestReport;
  Timer? _refreshTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  Future<void> _onInitialized(
    WeatherInitialized event,
    Emitter<WeatherState> emit,
  ) async {
    _hydrateFromCache();
    if (_latestReport != null) {
      emit(_buildSuccess(_latestReport!));
    } else {
      emit(_buildLoading());
    }

    if (_favoriteCitiesDataSource != null) {
      add(const WeatherFavoriteCitiesLoadRequested());
    }

    await _setupConnectivityTracking();
    if (!_isOffline && _activeCity.isNotEmpty) {
      add(const WeatherRefreshRequested());
    }
  }

  Future<void> _onSearchRequested(
    WeatherSearchRequested event,
    Emitter<WeatherState> emit,
  ) async {
    final city = event.city.trim();
    if (city.isEmpty) {
      _lastErrorMessage = 'Enter a city name.';
      emit(_buildError(_lastErrorMessage, cachedReport: _latestReport));
      return;
    }

    _activeCity = city;
    _startAutoRefresh();
    await _fetchWeather(city: city, emit: emit, showLoading: true);
  }

  Future<void> _onRefreshRequested(
    WeatherRefreshRequested event,
    Emitter<WeatherState> emit,
  ) async {
    if (_activeCity.isEmpty) {
      return;
    }
    await _fetchWeather(city: _activeCity, emit: emit, showLoading: false);
  }

  Future<void> _onRetryRequested(
    WeatherRetryRequested event,
    Emitter<WeatherState> emit,
  ) async {
    if (_activeCity.isEmpty && _latestReport != null) {
      _activeCity = _latestReport!.current.city;
    }
    if (_activeCity.isEmpty) {
      _lastErrorMessage = 'Search for a city first.';
      emit(_buildError(_lastErrorMessage, cachedReport: _latestReport));
      return;
    }
    await _fetchWeather(city: _activeCity, emit: emit, showLoading: true);
  }

  Future<void> _onLoadFavoriteCitiesRequested(
    WeatherFavoriteCitiesLoadRequested event,
    Emitter<WeatherState> emit,
  ) async {
    if (_favoriteCitiesDataSource == null) {
      return;
    }

    _isFavoritesLoading = true;
    _favoritesErrorMessage = '';
    _emitForCurrentStatus(emit);
    try {
      final cities = await _favoriteCitiesDataSource.getFavoriteCities();
      _favoriteCities = List.unmodifiable(cities);
    } catch (_) {
      _favoritesErrorMessage = 'Failed to load favorite cities.';
    } finally {
      _isFavoritesLoading = false;
      _emitForCurrentStatus(emit);
    }
  }

  Future<void> _onToggleFavoriteRequested(
    WeatherToggleFavoriteRequested event,
    Emitter<WeatherState> emit,
  ) async {
    if (_favoriteCitiesDataSource == null) {
      _favoritesErrorMessage = 'Favorites database is not configured.';
      _emitForCurrentStatus(emit);
      return;
    }

    final normalized = _normalizeCityKey(event.city);
    if (normalized.isEmpty) {
      return;
    }

    final previous = List<String>.from(_favoriteCities);
    final currentlyFavorite = previous.contains(normalized);
    final updated = List<String>.from(previous);
    if (currentlyFavorite) {
      updated.remove(normalized);
    } else {
      updated.add(normalized);
      updated.sort();
    }

    _favoriteCities = List.unmodifiable(updated);
    _favoritesErrorMessage = '';
    _emitForCurrentStatus(emit);

    try {
      if (currentlyFavorite) {
        await _favoriteCitiesDataSource.removeFavoriteCity(normalized);
      } else {
        await _favoriteCitiesDataSource.addFavoriteCity(normalized);
      }
    } catch (_) {
      _favoriteCities = List.unmodifiable(previous);
      _favoritesErrorMessage = 'Failed to update favorite cities.';
      _emitForCurrentStatus(emit);
    }
  }

  Future<void> _onConnectivityChanged(
    WeatherConnectivityChanged event,
    Emitter<WeatherState> emit,
  ) async {
    final wasOffline = _isOffline;
    _isOffline =
        event.results.isEmpty ||
        event.results.every((result) => result == ConnectivityResult.none);

    if (_isOffline && _latestReport == null) {
      _lastErrorMessage = 'Offline: no cached weather available.';
      emit(_buildError(_lastErrorMessage));
    } else if (wasOffline != _isOffline) {
      _emitForCurrentStatus(emit);
    }

    if (wasOffline && !_isOffline && _activeCity.isNotEmpty) {
      add(const WeatherRefreshRequested());
    }
  }

  Future<void> _fetchWeather({
    required String city,
    required Emitter<WeatherState> emit,
    required bool showLoading,
  }) async {
    if (showLoading) {
      emit(_buildLoading(previousReport: _latestReport));
    }

    try {
      final report = await _getWeatherReport(city, isOnline: !_isOffline);
      _latestReport = report;
      _activeCity = city;
      _lastErrorMessage = '';
      emit(_buildSuccess(report));
    } catch (_) {
      final requestedCityKey = _normalizeCityKey(city);
      final cachedCityKey = _latestReport == null
          ? ''
          : _normalizeCityKey(_latestReport!.current.city);
      final hasCachedForRequestedCity =
          _latestReport != null && requestedCityKey == cachedCityKey;

      if (_isOffline && !hasCachedForRequestedCity) {
        _latestReport = null;
      }

      _lastErrorMessage = _isOffline
          ? 'Offline: no cached weather available for this city.'
          : 'Failed to fetch weather. Check city name or API key.';
      emit(
        _buildError(
          _lastErrorMessage,
          cachedReport: hasCachedForRequestedCity ? _latestReport : null,
        ),
      );
    }
  }

  Future<void> _setupConnectivityTracking() async {
    try {
      final initial = await _connectivity.checkConnectivity();
      if (!isClosed) {
        add(WeatherConnectivityChanged(initial));
      }
      _connectivitySubscription ??= _connectivity.onConnectivityChanged.listen((
        results,
      ) {
        if (!isClosed) {
          add(WeatherConnectivityChanged(results));
        }
      });
    } catch (_) {
      // Connectivity plugin may be unavailable in tests or unsupported targets.
    }
  }

  void _hydrateFromCache() {
    final cached = _getWeatherReport.lastCached();
    if (cached == null) {
      return;
    }
    _latestReport = cached;
    _activeCity = cached.current.city;
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      if (!isClosed) {
        add(const WeatherRefreshRequested());
      }
    });
  }

  void _emitForCurrentStatus(Emitter<WeatherState> emit) {
    final current = state;
    if (current is WeatherSuccess && _latestReport != null) {
      emit(_buildSuccess(_latestReport!));
      return;
    }
    if (current is WeatherError) {
      emit(_buildError(_lastErrorMessage, cachedReport: _latestReport));
      return;
    }
    emit(_buildLoading(previousReport: _latestReport));
  }

  WeatherLoading _buildLoading({WeatherReport? previousReport}) {
    return WeatherLoading(
      favoriteCities: _favoriteCities,
      isFavoritesLoading: _isFavoritesLoading,
      favoritesErrorMessage: _favoritesErrorMessage,
      isOffline: _isOffline,
      activeCity: _activeCity,
      previousReport: previousReport,
    );
  }

  WeatherSuccess _buildSuccess(WeatherReport report) {
    return WeatherSuccess(
      report: report,
      favoriteCities: _favoriteCities,
      isFavoritesLoading: _isFavoritesLoading,
      favoritesErrorMessage: _favoritesErrorMessage,
      isOffline: _isOffline,
      activeCity: _activeCity,
    );
  }

  WeatherError _buildError(String message, {WeatherReport? cachedReport}) {
    final resolvedMessage = message.isEmpty ? 'Something went wrong.' : message;
    return WeatherError(
      message: resolvedMessage,
      favoriteCities: _favoriteCities,
      isFavoritesLoading: _isFavoritesLoading,
      favoritesErrorMessage: _favoritesErrorMessage,
      isOffline: _isOffline,
      activeCity: _activeCity,
      cachedReport: cachedReport,
    );
  }

  String _normalizeCityKey(String city) => city.trim().toLowerCase();

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
