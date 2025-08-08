import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/main.dart';

class LocationHeader extends StatelessWidget {
  const LocationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final theme = Theme.of(context);
    final header = theme.textTheme.headlineLarge!.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
    final details = theme.textTheme.bodyMedium!.copyWith(
      color: Colors.blueGrey,
    );

    return Container(
      color: Colors.blue.shade300,
      child: ClipRect(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "City Name",
              textAlign: TextAlign.center,
              style: header,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${appState.geoLoc?.latitude.toStringAsFixed(4) ?? "null"}°, ${appState.geoLoc?.longitude.toStringAsFixed(4) ?? "null"}° | ${appState.officeID ?? "null"}",
                  style: details,
                  softWrap: true,
                ),
                SizedBox.square(
                  dimension: (details.fontSize ?? 14) * (details.height ?? 1.4),
                  child: IconButton(
                    icon: Icon(
                      Icons.info_outline_rounded,
                      size: details.fontSize,
                    ),
                    padding: EdgeInsets.zero,
                    color: details.color,
                    onPressed: () {
                      debugPrint("Show location details");
                    },
                  ),
                ),
              ],
            ),
            Text(
              "Time - TimeZone (UTC+/-h:mm)",
              textAlign: TextAlign.center,
              style: details,
              softWrap: true,
            ),
          ],
        ),
      ),
    );
  }
}
