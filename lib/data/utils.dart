import 'package:weather_app/data/units.dart';

T? findValueFromTimeIntervalMap<T>(Map<TimeInterval, T> map, Time time) {
  //TODO Optimize later, prob use SplayTreeMap or binary search

  for (final pair in map.entries) {
    if (pair.key.contains(time)) {
      return pair.value;
    }
  }

  return null;
}
