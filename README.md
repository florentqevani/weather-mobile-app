# Weather Search App (Flutter)

A clean Flutter weather app that lets users search any city and view current weather details in real time using the OpenWeather API.

## Preview
- Search weather by city name
- Loading and error states
- Temperature, condition, and weather icon display

## Features
- City-based weather search
- Live API data from OpenWeather
- Gradient UI with a card-based weather panel
- Basic validation for empty input
- User-friendly error message when a city is not found

## Tech Stack
- Flutter (Material UI)
- Dart
- `http` package for API requests
- OpenWeather current weather endpoint

## Project Structure
```text
lib/
  main.dart                # App entry point
  weather_page.dart        # Main weather search screen
  services/
    weather.dart           # API service layer
```

## Getting Started

### Prerequisites
- Flutter SDK installed
- A device/emulator configured
- Internet connection

### Run Locally
```bash
git clone <your-repository-url>
cd deeplink_cookbook
flutter pub get
flutter run
```

## Configuration

The app currently uses OpenWeather via an API key in `lib/services/weather.dart`.

For production use:
- Move the API key out of source code
- Use `--dart-define` or secure storage/secrets management
- Add the key to `.gitignore`d local config

Example approach with `--dart-define`:
```bash
flutter run --dart-define=OPENWEATHER_API_KEY=your_api_key_here
```

## API Used
- OpenWeather Current Weather API  
  https://openweathermap.org/current

## Notes
- Project folder name is `deeplink_cookbook`, but current app behavior is weather search.
- Consider renaming the package/project for consistency.

