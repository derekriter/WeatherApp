import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:weather_app/data/utils.dart';
import 'package:weather_app/nws/nws_weather.dart';
import 'package:weather_app/data/units.dart';

const String userAgent = "derekriter08@gmail.com";

Future<({int gridX, int gridY, String officeID})> getGridFromPoint(
  double latX,
  double latY,
) async {
  final resp = await http.get(
    Uri.parse("https://api.weather.gov/points/$latX,$latY"),
    headers: {"User-Agent": userAgent, "Accept": "application/ld+json"},
  );

  if (resp.statusCode != 200) {
    throw Exception(
      "API Error\nStatus Code: ${resp.statusCode}\nBody: ${resp.body}",
    );
  }

  final json = jsonDecode(resp.body);
  if (json == null) {
    throw Exception("API Error, no json content returned");
  }
  if (json is! Map<String, dynamic>) {
    throw Exception("API Error, expected json object");
  }
  if (!json.containsKey("gridX")) {
    throw Exception("Missing argument 'gridX'");
  } else if (json["gridX"] is! int) {
    throw Exception("Argument 'gridX' should be an int");
  }
  if (!json.containsKey("gridY")) {
    throw Exception("Missing argument 'gridY'");
  } else if (json["gridY"] is! int) {
    throw Exception("Argument 'gridY' should be an int");
  }
  if (!json.containsKey("gridId")) {
    throw Exception("Missing argument 'gridId'");
  } else if (json["gridId"] is! String) {
    throw Exception("Argument 'gridId' should be a String");
  }

  return (
    gridX: json["gridX"] as int,
    gridY: json["gridY"] as int,
    officeID: json["gridId"] as String,
  );
}

Future<GridWeatherInfo> getGridWeather(
  int gridX,
  int gridY,
  String officeID,
) async {
  final resp = await http.get(
    Uri.parse("https://api.weather.gov/gridpoints/$officeID/$gridX,$gridY"),
    headers: {"User-Agent": userAgent, "Accept": "application/ld+json"},
  );

  if (resp.statusCode != 200) {
    throw Exception(
      "API Error\nStatus Code: ${resp.statusCode}\nBody: ${resp.body}",
    );
  }

  // print(resp.body);

  final json = jsonDecode(resp.body);
  if (json == null) {
    throw Exception("API Error, no json content returned");
  }
  if (json is! Map<String, dynamic>) {
    throw Exception("API Error, expected json object");
  }

  final TemperatureMap? temperature = _parseTimedSet(
    json,
    "temperature",
    _parseTemperatureSet,
  );
  final TemperatureMap? dewpoint = _parseTimedSet(
    json,
    "dewpoint",
    _parseTemperatureSet,
  );
  final TemperatureMap? maxTemperature = _parseTimedSet(
    json,
    "maxTemperature",
    _parseTemperatureSet,
  );
  final TemperatureMap? minTemperature = _parseTimedSet(
    json,
    "minTemperature",
    _parseTemperatureSet,
  );
  final FractionMap? relativeHumidity = _parseTimedSet(
    json,
    "relativeHumidity",
    _parseFractionSet,
  );
  final TemperatureMap? apparentTemperature = _parseTimedSet(
    json,
    "apparentTemperature",
    _parseTemperatureSet,
  );
  final FractionMap? skyCover = _parseTimedSet(
    json,
    "skyCover",
    _parseFractionSet,
  );
  final AngleMap? windDirection = _parseTimedSet(
    json,
    "windDirection",
    _parseAngleSet,
  );
  final SpeedMap? windSpeed = _parseTimedSet(json, "windSpeed", _parseSpeedSet);
  final SpeedMap? windGust = _parseTimedSet(json, "windGust", _parseSpeedSet);
  // final Map<TimeInterval, Weather>? weather = _parseTimedSet(
  //   json,
  //   "weather",
  //   _parseWeatherSet,
  // );
  //TODO finish parsing weather data

  return (
    temperature: temperature,
    dewpoint: dewpoint,
    maxTemperature: maxTemperature,
    minTemperature: minTemperature,
    relativeHumidity: relativeHumidity,
    apparentTemperature: apparentTemperature,
    skyCover: skyCover,
    windDirection: windDirection,
    windSpeed: windSpeed,
    windGust: windGust,
  );
}

Map<TimeInterval, T>? _parseTimedSet<T>(
  Map<String, dynamic> weatherJson,
  String setName,
  Map<TimeInterval, T>? Function(Map<String, dynamic> setJson) parser,
) {
  if (weatherJson[setName] is! Map<String, dynamic>) {
    if (!weatherJson.containsKey(setName)) {
      print("No $setName");
    } else {
      print("$setName should be an object");
    }
    return null;
  }

  return parser(weatherJson[setName] as Map<String, dynamic>);
}

String? _parseUOM(
  Map<String, dynamic> setJson,
  String setType,
  bool Function(String uom) validator,
) {
  if (!setJson.containsKey("uom")) {
    print("No uom in $setType set");
    return null;
  }
  if (setJson["uom"] is! String) {
    print("uom in $setType set should be a String");
    return null;
  }
  final uom = setJson["uom"] as String; //unit of measurement
  if (!validator(uom)) {
    print("Invalid uom '$uom' in $setType set");
    return null;
  }

  return uom;
}

Map<TimeInterval, T>? _parseTimedValues<T>(
  Map<String, dynamic> setJson,
  String setType,
  T? Function(dynamic raw) parser,
) {
  if (!setJson.containsKey("values")) {
    print("No values in $setType set");
    return null;
  }
  if (setJson["values"] is! List<dynamic>) {
    print("values in $setType set should be a list");
    return null;
  }

  Map<TimeInterval, T> parsed = {};
  final values = setJson["values"] as List<dynamic>;
  for (final reading in values) {
    if (reading is! Map<String, dynamic>) {
      print("Invalid $setType set reading '$reading'");
      continue;
    }

    if (!reading.containsKey("validTime")) {
      print("Missing validTime in $setType set reading '$reading'");
      continue;
    }
    if (reading["validTime"] is! String) {
      print("validTime should be a String in $setType set reading '$reading'");
      continue;
    }
    final validTime = TimeInterval.fromIso8601String(
      reading["validTime"] as String,
    );
    if (validTime == null) {
      print("Invalid time interval in $setType set reading '$reading'");
      continue;
    }

    if (!reading.containsKey("value")) {
      print("Missing value in $setType set reading '$reading'");
      continue;
    }
    final parsedVal = parser(reading["value"]);
    if (parsedVal == null) {
      print("Failed to parse value in $setType set reading '$reading'");
      continue;
    }

    parsed[validTime] = parsedVal;
  }

  return parsed;
}

Map<TimeInterval, T>? _parseTimedNumberValues<T>(
  Map<String, dynamic> setJson,
  String setType,
  String uom,
  T? Function(String uom, double val) constructor,
) {
  return _parseTimedValues(setJson, setType, (raw) {
    if (raw is! num) {
      return null;
    }
    return constructor(uom, raw.toDouble());
  });
}

TemperatureMap? _parseTemperatureSet(Map<String, dynamic> setJson) {
  final uom = _parseUOM(setJson, "temperature", Temperature.isValidID);
  if (uom == null) {
    return null;
  }

  return _parseTimedNumberValues(
    setJson,
    "temperature",
    uom,
    Temperature.fromUnitID,
  );
}

FractionMap? _parseFractionSet(Map<String, dynamic> setJson) {
  final uom = _parseUOM(setJson, "fraction", Fraction.isValidID);
  if (uom == null) {
    return null;
  }

  return _parseTimedNumberValues(setJson, "fraction", uom, Fraction.fromUnitID);
}

AngleMap? _parseAngleSet(Map<String, dynamic> setJson) {
  final uom = _parseUOM(setJson, "angle", Angle.isValidID);
  if (uom == null) {
    return null;
  }

  return _parseTimedNumberValues(setJson, "angle", uom, Angle.fromUnitID);
}

SpeedMap? _parseSpeedSet(Map<String, dynamic> setJson) {
  final uom = _parseUOM(setJson, "speed", Speed.isValidID);
  if (uom == null) {
    return null;
  }

  return _parseTimedNumberValues(setJson, "speed", uom, Speed.fromUnitID);
}

Map<TimeInterval, Weather>? _parseWeatherSet(Map<String, dynamic> setJson) {
  //TODO finish parsing weather
  return _parseTimedValues(setJson, "weather", (raw) {
    if (raw is! List<dynamic>) {
      print("value in weather set should be a list");
      return null;
    }
    for (final obj in raw) {
      if (obj == null) {
        print("Null value in weather set");
        continue;
      }
      if (obj is! Map<String, dynamic>) {
        print("value in weather set should be an object");
        continue;
      }
    }
  });
}
