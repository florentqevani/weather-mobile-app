# Weather Forecast App

A Flutter weather application providing real-time conditions, hourly forecasts, and 7-day daily forecasts for any city. Built with clean architecture, offline-first caching, and Firebase integration.

---

## Features

- **City Search** — Look up weather for any city worldwide
- **Current Conditions** — Temperature, feels-like, humidity, wind speed, and pressure
- **Hourly Forecast** — Next 12 hours with temperature, description, and precipitation probability
- **7-Day Forecast** — Daily min/max temperatures and weather descriptions
- **Favorite Cities** — Save favorite cities (synced to Firebase Firestore) for quick access
- **Offline Support** — Cached weather data available without internet (30-minute TTL)
- **Auto-Refresh** — Weather updates automatically every 30 minutes
- **Pull-to-Refresh** — Manually refresh weather data at any time
- **Connectivity Awareness** — Visual offline indicator; auto-refreshes when back online
- **Crash Reporting** — Firebase Crashlytics captures errors automatically

---

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- An [OpenWeather API key](https://openweathermap.org/api) (free tier works)
- A Firebase project (optional — needed for favorites sync and crash reporting)

### Setup

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd deeplink_cookbook
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure your OpenWeather API key**

   The API key is injected at compile time via `--dart-define`. **Do not commit API keys to source control.**

   ```bash
   flutter run --dart-define=OPENWEATHER_API_KEY=your_key_here
   ```

4. **Firebase setup (optional)**

   If you want favorite-city sync and crash reporting:
   - Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/)
   - Add Android/iOS/Web apps and download the configuration files
   - Place `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in the appropriate directories
   - Enable **Cloud Firestore** and **Crashlytics** in your Firebase project

5. **Run the app**

   ```bash
   # Android
   flutter run --dart-define=OPENWEATHER_API_KEY=your_key_here

   # iOS
   flutter run --dart-define=OPENWEATHER_API_KEY=your_key_here

   # Web
   flutter run -d chrome --dart-define=OPENWEATHER_API_KEY=your_key_here
   ```

---

## How to Use

### Searching for Weather

1. Open the app — it loads the last viewed city from cache automatically
2. Tap the **search field** at the top and enter a city name
3. Press the search button to fetch weather data

### Viewing Forecasts

- **Current weather** is shown in the main card with temperature, description, humidity, wind, and pressure
- Scroll down to see the **hourly forecast** (next 12 hours) and the **daily forecast** (next 7 days)

### Managing Favorite Cities

- Tap the **heart icon** on the current weather card to add/remove the city from favorites
- Favorite cities appear as quick-access chips below the search field
- Tap any favorite chip to instantly load that city's weather
- Favorites sync to Firebase Firestore when connected

### Offline Mode

- When offline, the app displays cached weather data from the last successful fetch
- An **offline indicator** label appears at the top of the screen
- When connectivity is restored, the app automatically refreshes

---

## Architecture

The app follows **Clean Architecture** with three layers:

```
lib/
├── core/                          # Shared utilities & domain models
│   ├── config/app_config.dart     # API key configuration
│   └── weather.dart               # Domain entities
├── domain/                        # Business logic
│   ├── repositories/              # Repository contracts
│   └── use_cases/                 # Application use cases
├── data/                          # Data access
│   ├── data_sources/              # Remote (APIs) & local (Hive cache)
│   ├── models/                    # Data transfer objects
│   ├── repo/                      # Repository implementations
│   └── utils/                     # Weather icon helpers
├── presentation/                  # UI layer
│   ├── pages/                     # Screen widgets
│   ├── state/                     # BLoC (events, states, logic)
│   └── widgets/                   # Reusable UI components
└── main.dart                      # App entry point
```

### Key Patterns

| Pattern | Implementation |
|---|---|
| State Management | BLoC (flutter_bloc) |
| Data Flow | Repository pattern with use cases |
| Caching | Cache-first with 30-min TTL (Hive) |
| Error Handling | Fallback to cache on API failure |
| Connectivity | Real-time monitoring (connectivity_plus) |

---

## API Endpoints

| Provider | Endpoint | Purpose |
|---|---|---|
| OpenWeather | `api.openweathermap.org/data/2.5/weather` | Current conditions by city name |
| Open-Meteo | `api.open-meteo.com/v1/forecast` | Hourly & daily forecasts by coordinates |

Open-Meteo is free and does not require an API key. Only the OpenWeather current-weather endpoint requires a key.

---

## Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc` | Event-driven state management |
| `http` | HTTP requests to weather APIs |
| `hive` / `hive_flutter` | Local key-value caching for offline support |
| `connectivity_plus` | Network connectivity monitoring |
| `firebase_core` | Firebase initialization |
| `firebase_crashlytics` | Crash and error reporting |
| `cloud_firestore` | Cloud storage for favorite cities |
| `google_sign_in` | Google OAuth (available for future use) |
| `shared_preferences` | Simple persistent preferences |
