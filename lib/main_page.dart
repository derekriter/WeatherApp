import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/data/units.dart';
import 'package:weather_app/data/utils.dart';
import 'package:weather_app/main.dart';
import 'package:weather_app/widgets/current_weather.dart';
import 'package:weather_app/widgets/loading_box.dart';
import 'package:weather_app/widgets/location_header.dart';
import 'package:weather_app/widgets/shimmer_loading.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final theme = Theme.of(context);
    final smallData = theme.textTheme.bodySmall!;

    if (appState.errorMsg != null) {
      return SingleChildScrollView(child: Text(appState.errorMsg!));
    }
    if (appState.gridWeather == null) {
      return Center(child: Text("Loading"));
    }

    late final Widget temperatureWidget;
    if (appState.gridWeather!.temperature == null) {
      temperatureWidget = LoadingBox(
        width: double.maxFinite,
        height: (smallData.fontSize ?? 14) * (smallData.height ?? 1.4) * 2,
      );
    } else {
      temperatureWidget = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 15,
          children: [
            for (var i = 0; i < 12; i++)
              () {
                final date = DateTime.now()
                    .copyWith(
                      minute: 0,
                      second: 0,
                      millisecond: 0,
                      microsecond: 0,
                    )
                    .add(Duration(hours: i));

                return Column(
                  children: [
                    Text(
                      findValueFromTimedData(
                            appState.gridWeather!.temperature!,
                            Time(date),
                          )?.fahrenheitString() ??
                          "?",
                      style: smallData,
                    ),
                    Text(DateFormat.j().format(date)),
                  ],
                );
              }(),
          ],
        ),
      );
    }

    return ShimmerRoot(
      background: theme.colorScheme.surfaceDim,
      glint: theme.colorScheme.surfaceBright,
      child: ListView(
        physics: ClampingScrollPhysics(),
        children: [
          LocationHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              children: [
                CurrentWeather(),
                // Divider(height: 1, thickness: 1),
                Divider(height: 10, thickness: 1),
                temperatureWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
