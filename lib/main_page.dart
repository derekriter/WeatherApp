import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/data/units.dart';
import 'package:weather_app/data/utils.dart';
import 'package:weather_app/main.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (appState.gridWeather == null) {
      return Center(child: Text("Loading"));
    }
    if (appState.gridWeather!.temperature == null) {
      return Text("No temperature data");
    }

    final temperatureWidget = Row(
      spacing: 15,
      children: [
        for (var i = 0; i < 12; i++)
          () {
            final date = DateTime.now()
                .copyWith(minute: 0, second: 0, millisecond: 0, microsecond: 0)
                .add(Duration(hours: i));

            return Column(
              children: [
                Text(
                  findValueFromTimedData(
                        appState.gridWeather!.temperature!,
                        Time(date),
                      )?.fahrenheitString() ??
                      "?",
                ),
                Text(DateFormat.j().format(date)),
              ],
            );
          }(),
      ],
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: temperatureWidget,
    );
  }
}
