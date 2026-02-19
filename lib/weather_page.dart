import 'package:firebase_crashlytics/firebase_crashlytics.dart' show FirebaseCrashlytics;
import 'package:flutter/material.dart';
import 'services/weather.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService weatherService = WeatherService();
  final TextEditingController cityController = TextEditingController();

  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  String errorMessage = "";

  Future<void> searchWeather() async {
    final city = cityController.text.trim();
    if (city.isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final data = await weatherService.fetchWeatherByCity(city);

      setState(() {
        weatherData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "City not found";
        isLoading = false;
        weatherData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Weather App",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: cityController,
                      decoration: InputDecoration(
                        hintText: "Enter city name",
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: searchWeather,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onSubmitted: (_) => searchWeather(),
                    ),

                    const SizedBox(height: 20),

                    if (isLoading)
                      const CircularProgressIndicator(),

                    if (errorMessage.isNotEmpty)
                      Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),

                    if (weatherData != null && !isLoading)
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            weatherData!["name"],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Image.network(
                            "https://openweathermap.org/img/wn/${weatherData!["weather"][0]["icon"]}@2x.png",
                            width: 100,
                          ),

                          Text(
                            "${weatherData!["main"]["temp"]}°C",
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            weatherData!["weather"][0]["description"]
                                .toString()
                                .toUpperCase(),
                          ),
                        //Crashlytics
                ElevatedButton(
                  onPressed: () {
                    FirebaseCrashlytics.instance.crash();
                  },
                  child: Text('Test Crash'),),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
