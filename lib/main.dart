import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/config/app_config.dart';
import 'data/data_sources/favorite_cities_remote_datasource.dart';
import 'data/data_sources/weather_local_datasource.dart';
import 'data/data_sources/weather_remote_datasource.dart';
import 'data/repo/weather_repository_impl.dart';
import 'domain/use_cases/get_weather_report.dart';
import 'presentation/pages/weather_page.dart';
import 'presentation/state/weather_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox<String>(WeatherLocalDataSource.boxName);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      final apiKey = AppConfig.openWeatherApiKey;
      final localDataSource = WeatherLocalDataSource(
        Hive.box<String>(WeatherLocalDataSource.boxName),
      );
      final favoriteCitiesDataSource = Firebase.apps.isNotEmpty
          ? FavoriteCitiesRemoteDataSource(FirebaseFirestore.instance)
          : null;
      final bloc = WeatherBloc(
        getWeatherReport: GetWeatherReport(
          WeatherRepositoryImpl(
            OpenWeatherRemoteDataSource(apiKey: apiKey),
            localDataSource,
          ),
        ),
        favoriteCitiesDataSource: favoriteCitiesDataSource,
      );

      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WeatherScreen(bloc: bloc),
      );
    } on FormatException catch (e) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                e.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );
    }
  }
}
