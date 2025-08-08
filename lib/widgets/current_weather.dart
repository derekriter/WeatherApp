import 'package:flutter/material.dart';

class CurrentWeather extends StatefulWidget {
  const CurrentWeather({super.key});

  @override
  State<CurrentWeather> createState() => _CurrentWeatherState();
}

class _CurrentWeatherState extends State<CurrentWeather>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final largeData = theme.textTheme.headlineSmall!.copyWith(
      fontWeight: FontWeight.bold,
    );
    final smallData = theme.textTheme.bodySmall!;

    final tabController = TabController(length: 4, vsync: this);

    return ConstrainedBox(
      constraints: BoxConstraints.loose(Size.fromHeight(250)),
      child: Padding(
        padding: const EdgeInsets.only(left: 5, bottom: 5, right: 5),
        child: Row(
          spacing: 5,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: TabBarView(
                  controller: tabController,
                  children: [
                    _CommonDisplay(largeData: largeData, smallData: smallData),
                    _AirDisplay(largeData: largeData, smallData: smallData),
                    Placeholder(),
                    Placeholder(),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                    child: TabBar.secondary(
                      controller: tabController,
                      tabs: [
                        Tab(icon: Icon(Icons.thermostat_rounded, size: 30)),
                        Tab(icon: Icon(Icons.air_rounded, size: 30)),
                        Tab(icon: Icon(Icons.waves_rounded, size: 30)),
                        Tab(icon: Icon(Icons.warning_rounded, size: 30)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        _CommonInfo(),
                        _AirInfo(),
                        _WaveInfo(),
                        _HazardInfo(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommonDisplay extends StatelessWidget {
  const _CommonDisplay({required this.largeData, required this.smallData});

  final TextStyle largeData, smallData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "UV Index: --",
          softWrap: false,
          overflow: TextOverflow.fade,
          style: smallData,
        ),
        Flexible(
          child: AspectRatio(
            aspectRatio: 1,
            child: Placeholder(
              child: Center(
                child: Text("Conditions icon", textAlign: TextAlign.center),
              ),
            ),
          ),
        ),
        Text(
          "Condition",
          softWrap: false,
          overflow: TextOverflow.fade,
          style: largeData,
        ),
        Text(
          "Feels like: --",
          softWrap: false,
          overflow: TextOverflow.fade,
          style: smallData,
        ),
      ],
    );
  }
}

class _CommonInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Card(
                  child: Center(
                    child: Text(
                      "Temperature gauge",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Center(
                    child: Text("Humidity gauge", textAlign: TextAlign.center),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Card(
            child: Center(
              child: Text("6hr rain chance graph", textAlign: TextAlign.center),
            ),
          ),
        ),
      ],
    );
  }
}

class _AirDisplay extends StatelessWidget {
  const _AirDisplay({required this.largeData, required this.smallData});

  final TextStyle largeData, smallData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Gusts up to: --",
          softWrap: false,
          overflow: TextOverflow.fade,
          style: smallData,
        ),
        Flexible(
          child: AspectRatio(
            aspectRatio: 1,
            child: Placeholder(
              child: Center(
                child: Text("Wind compass", textAlign: TextAlign.center),
              ),
            ),
          ),
        ),
        Text(
          "-- mph",
          softWrap: false,
          overflow: TextOverflow.fade,
          style: largeData,
        ),
        Text(
          "NNW - --°",
          softWrap: false,
          overflow: TextOverflow.fade,
          style: smallData,
        ),
      ],
    );
  }
}

class _AirInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: Card(child: Center(child: Text("AQI")))),
              Expanded(child: Card(child: Center(child: Text("Pollen")))),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(child: Card(child: Center(child: Text("Visibility")))),
              Expanded(child: Card(child: Center(child: Text("Pressure")))),
            ],
          ),
        ),
      ],
    );
  }
}

class _WaveInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Waves"));
  }
}

class _HazardInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Hazards"));
  }
}
