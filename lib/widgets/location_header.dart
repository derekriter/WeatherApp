import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/main.dart';
import 'package:weather_app/widgets/nullable_text.dart';

class LocationHeader extends StatelessWidget {
  const LocationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final theme = Theme.of(context);
    final header = theme.textTheme.headlineLarge!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
    );
    final details = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    final date = DateTime.now();
    final timezone = date.timeZoneName;
    final timezoneOffset = date.timeZoneOffset;
    final doubleDigitFormatter = NumberFormat("00");

    return Container(
      color: theme.colorScheme.primary,
      padding: EdgeInsets.symmetric(vertical: 48),
      child: ClipRect(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "City Name", //TODO process from point metadata
              textAlign: TextAlign.center,
              style: header,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NullableText(
                  appState.geoLoc == null
                      ? null
                      : "${appState.geoLoc!.latitude.toStringAsFixed(4)}°, ${appState.geoLoc!.longitude.toStringAsFixed(4)}°}",
                  referenceData: "00.0000°, 00.0000°",
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
              "$timezone (UTC${!timezoneOffset.isNegative ? "+" : ""}${doubleDigitFormatter.format(timezoneOffset.inHours)}:${doubleDigitFormatter.format(timezoneOffset.inMinutes % 60)})",
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
