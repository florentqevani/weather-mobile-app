import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = "e5072414b840253f41f5e5fc4f1f2326";

  Future<Map<String, dynamic>> fetchWeatherByCity(String city) async {
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("City not found");
    }
  }
}
