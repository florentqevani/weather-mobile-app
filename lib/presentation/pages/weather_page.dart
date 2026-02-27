import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/weather.dart';
import '../state/weather_bloc.dart';
import '../state/weather_event.dart';
import '../state/weather_state.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/daily_forecast_card.dart';
import '../widgets/hourly_forecast_card.dart';
import '../widgets/offline_status_label.dart';
import '../widgets/weather_search_card.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({required this.bloc, super.key});

  final WeatherBloc bloc;

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  WeatherBloc get _bloc => widget.bloc;

  @override
  void dispose() {
    _cityController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _search() {
    _bloc.add(WeatherSearchRequested(_cityController.text));
  }

  void _searchByCity(String city) {
    _cityController.text = city;
    _bloc.add(WeatherSearchRequested(city));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B1F3A), Color(0xFF15467A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<WeatherBloc, WeatherState>(
            bloc: _bloc,
            builder: (context, state) {
              final report = _reportForState(state);
              final isLoading = state is WeatherLoading;
              final errorState = state is WeatherError ? state : null;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Weather Forecast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (state.isOffline) ...[
                    const SizedBox(height: 10),
                    const OfflineStatusLabel(),
                  ],
                  const SizedBox(height: 16),
                  WeatherSearchCard(
                    cityController: _cityController,
                    onSearch: _search,
                    onRefresh: () {
                      _bloc.add(const WeatherRefreshRequested());
                    },
                    onFavoriteCityTap: _searchByCity,
                    favorites: state.favoriteCities,
                    isFavoritesLoading: state.isFavoritesLoading,
                    favoritesErrorMessage: state.favoritesErrorMessage,
                  ),
                  const SizedBox(height: 12),
                  if (isLoading) ...[
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 12),
                  ],
                  if (errorState != null) ...[
                    _buildErrorCard(errorState),
                    const SizedBox(height: 12),
                  ],
                  if (report != null) ...[
                    CurrentWeatherCard(
                      current: report.current,
                      isFavorite: _isFavoriteCity(state, report.current.city),
                      onToggleFavorite: () {
                        _bloc.add(
                          WeatherToggleFavoriteRequested(report.current.city),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    HourlyForecastCard(hourly: report.hourly),
                    const SizedBox(height: 12),
                    DailyForecastCard(daily: report.daily),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(WeatherError state) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.message,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.tonal(
              onPressed: () {
                _bloc.add(const WeatherRetryRequested());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  WeatherReport? _reportForState(WeatherState state) {
    if (state is WeatherSuccess) {
      return state.report;
    }
    if (state is WeatherLoading) {
      return state.previousReport;
    }
    if (state is WeatherError) {
      return state.cachedReport;
    }
    return null;
  }

  bool _isFavoriteCity(WeatherState state, String city) {
    final normalized = city.trim().toLowerCase();
    return state.favoriteCities.contains(normalized);
  }
}
