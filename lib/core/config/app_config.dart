class AppConfig {
  AppConfig._();

  static const _defaultOpenWeatherApiKey =
      'e5072414b840253f41f5e5fc4f1f2326';

  static String get openWeatherApiKey {
    const key = String.fromEnvironment(
      'OPENWEATHER_API_KEY',
      defaultValue: _defaultOpenWeatherApiKey,
    );
    return key;
  }
}
