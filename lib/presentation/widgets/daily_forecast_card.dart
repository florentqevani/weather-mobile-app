import 'package:flutter/material.dart';

import '../../domain/weather.dart';

class DailyForecastCard extends StatelessWidget {
  const DailyForecastCard({required this.daily, super.key});

  final List<DailyForecast> daily;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '7-Day Forecast',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final day in daily)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Image.network(
                  day.iconUrl,
                  width: 34,
                  errorBuilder: (_, error, stackTrace) =>
                      const SizedBox(width: 34),
                ),
                title: Text(_formatDay(day.date)),
                subtitle: Text(day.description),
                trailing: Text(
                  '${day.maxTemperature.toStringAsFixed(0)}° / ${day.minTemperature.toStringAsFixed(0)}°',
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDay(DateTime value) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[value.weekday - 1];
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$weekday $day/$month';
  }
}
