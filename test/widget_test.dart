import 'dart:io';

import 'package:deeplink_cookbook/data/data_sources/weather_local_datasource.dart';
import 'package:deeplink_cookbook/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempHiveDir;

  setUpAll(() async {
    tempHiveDir = await Directory.systemTemp.createTemp(
      'weather_app_hive_test_',
    );
    Hive.init(tempHiveDir.path);
    await Hive.openBox<String>(WeatherLocalDataSource.boxName);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempHiveDir.existsSync()) {
      await tempHiveDir.delete(recursive: true);
    }
  });

  testWidgets('Renders weather home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Weather Forecast'), findsOneWidget);
  });
}
