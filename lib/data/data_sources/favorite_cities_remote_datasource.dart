import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteCitiesRemoteDataSource {
  FavoriteCitiesRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  static const _collection = 'weather_app';
  static const _document = 'favorites';
  static const _citiesField = 'cities';

  Future<List<String>> getFavoriteCities() async {
    final snapshot = await _docRef.get();
    final data = snapshot.data();
    if (data == null) {
      return const [];
    }

    final rawCities = data[_citiesField];
    if (rawCities is! List) {
      return const [];
    }

    final normalized = rawCities
        .whereType<String>()
        .map(_normalizeCityKey)
        .where((city) => city.isNotEmpty)
        .toSet()
        .toList(growable: false);
    normalized.sort();
    return normalized;
  }

  Future<void> addFavoriteCity(String city) async {
    final normalized = _normalizeCityKey(city);
    if (normalized.isEmpty) {
      return;
    }

    await _docRef.set({
      _citiesField: FieldValue.arrayUnion([normalized]),
    }, SetOptions(merge: true));
  }

  Future<void> removeFavoriteCity(String city) async {
    final normalized = _normalizeCityKey(city);
    if (normalized.isEmpty) {
      return;
    }

    await _docRef.set({
      _citiesField: FieldValue.arrayRemove([normalized]),
    }, SetOptions(merge: true));
  }

  DocumentReference<Map<String, dynamic>> get _docRef =>
      _firestore.collection(_collection).doc(_document);

  String _normalizeCityKey(String city) => city.trim().toLowerCase();
}
