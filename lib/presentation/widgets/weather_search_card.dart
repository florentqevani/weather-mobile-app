import 'package:flutter/material.dart';

class WeatherSearchCard extends StatelessWidget {
  const WeatherSearchCard({
    required this.cityController,
    required this.onSearch,
    required this.onRefresh,
    required this.onFavoriteCityTap,
    required this.favorites,
    required this.isFavoritesLoading,
    required this.favoritesErrorMessage,
    super.key,
  });

  final TextEditingController cityController;
  final VoidCallback onSearch;
  final VoidCallback onRefresh;
  final ValueChanged<String> onFavoriteCityTap;
  final List<String> favorites;
  final bool isFavoritesLoading;
  final String favoritesErrorMessage;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => onSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onSearch,
                  child: const Text('Search'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            if (isFavoritesLoading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            if (favorites.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Favorite Cities',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: favorites
                    .map(
                      (city) => ActionChip(
                        label: Text(_formatCityLabel(city)),
                        onPressed: () => onFavoriteCityTap(city),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
            if (favoritesErrorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                favoritesErrorMessage,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCityLabel(String city) {
    final parts = city.split(' ');
    final titled = parts.map((part) {
      if (part.isEmpty) {
        return part;
      }
      return '${part[0].toUpperCase()}${part.substring(1)}';
    });
    return titled.join(' ');
  }
}
