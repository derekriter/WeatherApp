import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/data/utils.dart';
import 'package:weather_app/nws/nws.dart' as nws;
import 'package:weather_app/main_page.dart';

const latX = 43.6969;
const latY = -84.3056;

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
        home: Scaffold(body: MainPage()),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  AppState() {
    nws.getGridFromPoint(latX, latY).then((final gridInfo) async {
      gridX = gridInfo.gridX;
      gridY = gridInfo.gridY;
      officeID = gridInfo.officeID;

      gridWeather = await nws.getGridWeather(gridX!, gridY!, officeID!);
      notifyListeners();
    });
  }

  int? gridX, gridY;
  String? officeID;
  GridWeatherInfo? gridWeather;
}
