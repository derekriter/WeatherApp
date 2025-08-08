import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/data/utils.dart';
import 'package:weather_app/nws/nws.dart' as nws;
import 'package:weather_app/main_page.dart';

void main() async {
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        ),
        title: "Weather",
        home: Scaffold(body: MainPage()),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  AppState() {
    getGeolocation()
        .then((final pos) async {
          geoLoc = pos;

          final gridInfo = await nws
              .getGridFromPoint(geoLoc!.latitude, geoLoc!.longitude)
              .catchError((err, stack) {
                throw "$err$stack";
              });
          gridX = gridInfo.gridX;
          gridY = gridInfo.gridY;
          officeID = gridInfo.officeID;

          gridWeather = await nws
              .getGridWeather(gridX!, gridY!, officeID!)
              .catchError((err, stack) {
                throw "$err$stack";
              });
          notifyListeners();
        })
        .catchError((err, stack) {
          // errorMsg = "$err$stack";
          geoLoc = null;
          gridX = null;
          gridY = null;
          officeID = null;
          gridWeather = (
            temperature: null,
            dewpoint: null,
            maxTemperature: null,
            minTemperature: null,
            relativeHumidity: null,
            apparentTemperature: null,
            skyCover: null,
            windDirection: null,
            windSpeed: null,
            windGust: null,
          );
          notifyListeners();
        });
  }

  Position? geoLoc;
  int? gridX, gridY;
  String? officeID;
  GridWeatherInfo? gridWeather;

  String? errorMsg;
}
