import 'package:geolocator/geolocator.dart';
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

Future<Position> getGeolocation() async {
  final enabled = await Geolocator.isLocationServiceEnabled();
  if (!enabled) {
    return Future.error("Location services are not enabled");
  }

  var permission = await Geolocator.checkPermission();
  switch (permission) {
    case LocationPermission.unableToDetermine:
      return Future.error("Unable to determine location permissions");
    case LocationPermission.deniedForever:
      return Future.error("Access to location services are permanetly denied");
    case LocationPermission.denied:
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Access to location services where denied");
      }
    default:
      break;
  }

  return await Geolocator.getCurrentPosition();
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
