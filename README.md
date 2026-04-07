# Weather Forecast App (Flutter)

A Flutter weather app that shows real-time current conditions, hourly forecasts, and a 5-day daily forecast for any city in the world. Powered by the [OpenWeatherMap API](https://openweathermap.org/).

## How the App Works

When the app launches it immediately loads the last city you searched for (if any) from the local cache so you always have something to look at, even before the network request completes. It then refreshes the data in the background and keeps the display up-to-date automatically every 30 minutes.

The app monitors your network connection in real time. If you go offline it shows an **Offline** banner and continues to display the most recently cached data. When connectivity is restored it fetches fresh data automatically.

All weather data comes from two OpenWeatherMap endpoints:

| Endpoint | Used for |
|---|---|
| `/data/2.5/weather` | Current conditions |
| `/data/2.5/forecast` | Hourly and 5-day forecasts |

Crash diagnostics are sent to Firebase Crashlytics so that unhandled errors are captured without any action required from the user.

## Using the App

### Searching for a City
1. Type a city name into the **City** text field at the top of the screen.
2. Press the **Search** button or the search key on your keyboard.
3. The app fetches the latest weather and displays it below.

### Reading the Weather Cards

**Current Weather** — shows the city and country, the current temperature in °C, a weather icon, a short description (e.g. *LIGHT RAIN*), feels-like temperature, humidity, wind speed, and atmospheric pressure.

**Hourly Forecast** — a horizontally scrollable list of upcoming hourly slots, each showing the time, temperature, weather icon, and precipitation probability.

**5-Day Daily Forecast** — one card per day with the date, weather icon, description, and the low/high temperature range.

### Saving Favorite Cities
- Tap the ⭐ (star) icon on the current weather card to save a city as a favorite.
- Your saved cities appear as quick-access chips below the search bar.
- Tap any chip to instantly load weather for that city without retyping.
- Tap the ★ (filled star) again to remove a city from your favorites.

Favorites are stored in Firebase Firestore and sync across devices when signed in.

### Refreshing Data
- **Pull down** on the main screen to trigger an immediate refresh.
- The app also refreshes automatically every 30 minutes in the background.

### Offline Mode
When no internet connection is available:
- An **Offline** banner appears below the app title.
- Previously cached weather data is shown so the screen is never empty.
- As soon as connectivity is restored the app refreshes silently.

### Handling Errors
If a fetch fails (e.g. an unrecognised city name or an expired API key) an error message appears with a **Retry** button. Tap it to try again without re-entering the city name.

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.10
- An [OpenWeatherMap API key](https://home.openweathermap.org/api_keys) (free tier works)
- A Firebase project with Crashlytics and Firestore enabled (required for favorites and crash reporting)

### Running the App
Pass your API key as a compile-time define so it is never stored in source control:

```bash
flutter run --dart-define=OPENWEATHER_API_KEY=your_openweather_api_key
```

> **Note:** Do not commit API keys to source control. Use CI/CD secrets or a local `.env` mechanism to supply the key at build time.

## Architecture

The project follows clean architecture with a BLoC state-management layer:

```text
lib/
  core/
    config/app_config.dart       # API key and global config
    weather.dart                 # Shared domain models
  data/
    data_sources/
      weather_remote_datasource.dart        # OpenWeatherMap API calls
      weather_local_datasource.dart         # Hive offline cache
      favorite_cities_remote_datasource.dart # Firestore favorites
    models/                      # JSON ↔ domain model mapping
    repo/weather_repository_impl.dart
  domain/
    repositories/weather_repository.dart
    use_cases/get_weather_report.dart
  presentation/
    pages/weather_page.dart      # Main screen
    state/                       # BLoC (events, states, bloc)
    widgets/                     # Reusable UI cards
  main.dart
```

| Layer | Technology |
|---|---|
| State management | flutter_bloc |
| Remote weather data | OpenWeatherMap REST API |
| Local cache | Hive |
| Favorites storage | Firebase Firestore |
| Crash reporting | Firebase Crashlytics |
| Connectivity detection | connectivity_plus |
