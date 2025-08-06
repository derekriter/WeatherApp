import 'package:weather_app/data/units.dart';

T? findValueFromTimedData<T>(Map<TimeInterval, T> map, Time time) {
  //TODO Optimize later, prob use SplayTreeMap or binary search

  for (final pair in map.entries) {
    if (pair.key.contains(time)) {
      return pair.value;
    }
  }

  return null;
}

typedef TemperatureMap = Map<TimeInterval, Temperature>;
typedef FractionMap = Map<TimeInterval, Fraction>;
typedef AngleMap = Map<TimeInterval, Angle>;
typedef SpeedMap = Map<TimeInterval, Speed>;
typedef GridWeatherInfo =
    ({
      TemperatureMap? temperature,
      TemperatureMap? dewpoint,
      TemperatureMap? maxTemperature,
      TemperatureMap? minTemperature,
      FractionMap? relativeHumidity,
      TemperatureMap? apparentTemperature,
      FractionMap? skyCover,
      AngleMap? windDirection,
      SpeedMap? windSpeed,
      SpeedMap? windGust,
    });
