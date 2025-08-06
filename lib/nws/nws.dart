import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:weather_app/nws/nws_weather.dart';
import 'package:weather_app/data/units.dart';

const String userAgent = "derekriter08@gmail.com";

Future<(int gridX, int gridY, String officeID)> getGridFromPoint(
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

  return (json["gridX"] as int, json["gridY"] as int, json["gridId"] as String);
}

void getGridWeather(int gridX, int gridY, String officeID) async {
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

  final Map<TimeInterval, Temperature>? temperature = _parseTimedSet(
    json,
    "temperature",
    _parseTemperatureSet,
  );
  final Map<TimeInterval, Temperature>? dewpoint = _parseTimedSet(
    json,
    "dewpoint",
    _parseTemperatureSet,
  );
  final Map<TimeInterval, Temperature>? maxTemperature = _parseTimedSet(
    json,
    "maxTemperature",
    _parseTemperatureSet,
  );
  final Map<TimeInterval, Temperature>? minTemperature = _parseTimedSet(
    json,
    "minTemperature",
    _parseTemperatureSet,
  );
  final Map<TimeInterval, Fraction>? relativeHumidity = _parseTimedSet(
    json,
    "relativeHumidity",
    _parseFractionSet,
  );
  final Map<TimeInterval, Temperature>? apparentTemperature = _parseTimedSet(
    json,
    "apparentTemperature",
    _parseTemperatureSet,
  );
  final Map<TimeInterval, Fraction>? skyCover = _parseTimedSet(
    json,
    "skyCover",
    _parseFractionSet,
  );
  final Map<TimeInterval, Angle>? windDirection = _parseTimedSet(
    json,
    "windDirection",
    _parseAngleSet,
  );
  final Map<TimeInterval, Speed>? windSpeed = _parseTimedSet(
    json,
    "windSpeed",
    _parseSpeedSet,
  );
  final Map<TimeInterval, Speed>? windGust = _parseTimedSet(
    json,
    "windGust",
    _parseSpeedSet,
  );
  // final Map<TimeInterval, Weather>? weather = _parseTimedSet(
  //   json,
  //   "weather",
  //   _parseWeatherSet,
  // );
  //TODO finish parsing weather data
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

Map<TimeInterval, Temperature>? _parseTemperatureSet(
  Map<String, dynamic> setJson,
) {
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

Map<TimeInterval, Fraction>? _parseFractionSet(Map<String, dynamic> setJson) {
  final uom = _parseUOM(setJson, "fraction", Fraction.isValidID);
  if (uom == null) {
    return null;
  }

  return _parseTimedNumberValues(setJson, "fraction", uom, Fraction.fromUnitID);
}

Map<TimeInterval, Angle>? _parseAngleSet(Map<String, dynamic> setJson) {
  final uom = _parseUOM(setJson, "angle", Angle.isValidID);
  if (uom == null) {
    return null;
  }

  return _parseTimedNumberValues(setJson, "angle", uom, Angle.fromUnitID);
}

Map<TimeInterval, Speed>? _parseSpeedSet(Map<String, dynamic> setJson) {
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
