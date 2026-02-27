import 'package:flutter/material.dart';

import '../../core/weather.dart';

class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({
    required this.current,
    required this.isFavorite,
    required this.onToggleFavorite,
    super.key,
  });

  final CurrentWeather current;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '${current.city}, ${current.country}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  onPressed: onToggleFavorite,
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? Colors.amber.shade700 : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Image.network(
                  current.iconUrl,
                  width: 72,
                  errorBuilder: (_, error, stackTrace) =>
                      const SizedBox(width: 72),
                ),
                const SizedBox(width: 8),
                Text(
                  '${current.temperature.toStringAsFixed(1)}°C',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(current.description.toUpperCase()),
            const SizedBox(height: 8),
            Text('Feels like: ${current.feelsLike.toStringAsFixed(1)}°C'),
            Text('Humidity: ${current.humidity}%'),
            Text('Wind: ${current.windSpeed.toStringAsFixed(1)} m/s'),
            Text('Pressure: ${current.pressure} hPa'),
          ],
        ),
      ),
    );
  }
}
