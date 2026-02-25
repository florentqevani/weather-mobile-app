class WeatherIconApi {
  WeatherIconApi._();

  static const _baseUrl = 'https://openweathermap.org/img/wn';

  static String currentIconUrl(String iconCode) {
    if (iconCode.isEmpty) {
      return '';
    }
    return '$_baseUrl/$iconCode@2x.png';
  }

  static String forecastIconUrl(String iconCode) {
    if (iconCode.isEmpty) {
      return '';
    }
    return '$_baseUrl/$iconCode.png';
  }
}
