# Weather Forecast App (Flutter)

Structured Flutter weather app with real-time current conditions, hourly forecast, and 5-day daily forecast.

## Features
- Search by city
- Current weather from OpenWeather
- Hourly forecast (next 12 slots)
- Daily forecast (5 days)
- Auto-refresh every 10 minutes
- Crash reporting via Firebase Crashlytics

## Architecture
```text
lib/
  core/
    config/app_config.dart
  data/
    datasources/weather_remote_datasource.dart
    models/weather.dart
    repo/weather_repository_impl.dart
  domain/
    weather.dart
    repositories/weather_repository.dart
    usecases/get_weather_report.dart
  presentation/
    pages/weather_page.dart
    state/weather_controller.dart
  main.dart
```

## Secure API Key Setup
The API key is loaded at runtime using a compile-time define.

Run:
```bash
flutter run --dart-define=OPENWEATHER_API_KEY=your_openweather_api_key
```

Do not commit API keys to source control.

## API Endpoints Used
- Current weather: `https://api.openweathermap.org/data/2.5/weather`
- Forecast: `https://api.openweathermap.org/data/2.5/forecast`
