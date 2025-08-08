import 'package:flutter/material.dart';

class CurrentWeather extends StatelessWidget {
  const CurrentWeather({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final largeData = theme.textTheme.headlineSmall!.copyWith(
      fontWeight: FontWeight.bold,
    );
    final smallData = theme.textTheme.bodySmall!;

    return ConstrainedBox(
      constraints: BoxConstraints.loose(Size.fromHeight(200)),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Placeholder(
                        child: Center(
                          child: Text(
                            "Conditions icon",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  "Temp",
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: largeData,
                ),
                Text(
                  "Feels like: temp",
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: smallData,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 30,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text("Temp", textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Text("Wind", textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Text("Waves", textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Text("Hazards", textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        child: Placeholder(
                          child: Center(
                            child: Text(
                              "Temperature gauge",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Placeholder(
                          child: Center(
                            child: Text(
                              "Humidity gauge",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Expanded(
                  child: Placeholder(
                    child: Center(
                      child: Text(
                        "6hr rain chance graph",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
