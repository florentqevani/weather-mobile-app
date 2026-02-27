import 'package:flutter/material.dart';

import '../../core/weather.dart';

class HourlyForecastCard extends StatelessWidget {
  const HourlyForecastCard({required this.hourly, super.key});

  final List<HourlyForecast> hourly;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '24-Hour Forecast',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: hourly.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = hourly[index];
                  return Container(
                    width: 90,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blueGrey.shade50,
                    ),
                    child: Column(
                      children: [
                        Text(_formatTime(item.time)),
                        Image.network(
                          item.iconUrl,
                          width: 36,
                          errorBuilder: (_, error, stackTrace) =>
                              const SizedBox(height: 36),
                        ),
                        Text('${item.temperature.toStringAsFixed(0)}°C'),
                        Text(
                          '${(item.precipitationProbability * 100).round()}% rain',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
