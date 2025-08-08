import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/data/utils.dart';
import 'package:weather_app/nws/nws_weather.dart';
import 'package:weather_app/data/units.dart';

const String userAgent = "(derekriter.github.io derekriter08@gmail.com)";

String _genAPIError(String msg, Uri uri, http.Response resp) {
  return "API Error: $msg\nStatus Code: ${resp.statusCode}\nURI: '$uri'\nBody:\n${resp.body}";
}

//TODO cache data so the NWS servers don't get spammed

Future<({int gridX, int gridY, String officeID})> getGridFromPoint(
  double lat,
  double long,
) async {
  //api doesn't want more than 4 decimals places, will cause unexpected functionality if not followed
  //https://weather-gov.github.io/api/general-faqs#:~:text=Please%20note%20that,be%20close%0Aenough!
  final uri = Uri.parse(
    "https://api.weather.gov/points/${lat.toStringAsFixed(4)},${long.toStringAsFixed(4)}",
  );
  final resp = await http.get(
    uri,
    headers: {"User-Agent": userAgent, "Accept": "application/ld+json"},
  );

  if (resp.statusCode != 200) {
    return Future.error(_genAPIError("bad response", uri, resp));
  }

  final json = jsonDecode(resp.body);
  if (json == null) {
    return Future.error(_genAPIError("no json content returned", uri, resp));
  }
  if (json is! Map<String, dynamic>) {
    return Future.error(_genAPIError("expected json object", uri, resp));
  }
  if (!json.containsKey("gridX")) {
    return Future.error(_genAPIError("missing argument 'gridX'", uri, resp));
  } else if (json["gridX"] is! int) {
    return Future.error(
      _genAPIError("argument 'gridX' should be an int", uri, resp),
    );
  }
  if (!json.containsKey("gridY")) {
    return Future.error(_genAPIError("missing argument 'gridY'", uri, resp));
  } else if (json["gridY"] is! int) {
    return Future.error(
      _genAPIError("argument 'gridY' should be an int", uri, resp),
    );
  }
  if (!json.containsKey("gridId")) {
    return Future.error(_genAPIError("missing argument 'gridId'", uri, resp));
  } else if (json["gridId"] is! String) {
    return Future.error(
      _genAPIError("argument 'gridId' should be a String", uri, resp),
    );
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
  final uri = Uri.parse(
    "https://api.weather.gov/gridpoints/$officeID/$gridX,$gridY",
  );
  final resp = await http.get(
    uri,
    headers: {"User-Agent": userAgent, "Accept": "application/ld+json"},
  );

  if (resp.statusCode != 200) {
    return Future.error(_genAPIError("bad response", uri, resp));
  }

  final json = jsonDecode(resp.body);
  if (json == null) {
    return Future.error(_genAPIError("no json content returned", uri, resp));
  }
  if (json is! Map<String, dynamic>) {
    return Future.error(_genAPIError("expected json object", uri, resp));
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
      debugPrint("No $setName");
    } else {
      debugPrint("$setName should be an object");
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
    debugPrint("No uom in $setType set");
    return null;
  }
  if (setJson["uom"] is! String) {
    debugPrint("uom in $setType set should be a String");
    return null;
  }
  final uom = setJson["uom"] as String; //unit of measurement
  if (!validator(uom)) {
    debugPrint("Invalid uom '$uom' in $setType set");
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
    debugPrint("No values in $setType set");
    return null;
  }
  if (setJson["values"] is! List<dynamic>) {
    debugPrint("values in $setType set should be a list");
    return null;
  }

  Map<TimeInterval, T> parsed = {};
  final values = setJson["values"] as List<dynamic>;
  for (final reading in values) {
    if (reading is! Map<String, dynamic>) {
      debugPrint("Invalid $setType set reading '$reading'");
      continue;
    }

    if (!reading.containsKey("validTime")) {
      debugPrint("Missing validTime in $setType set reading '$reading'");
      continue;
    }
    if (reading["validTime"] is! String) {
      debugPrint(
        "validTime should be a String in $setType set reading '$reading'",
      );
      continue;
    }
    final validTime = TimeInterval.fromIso8601String(
      reading["validTime"] as String,
    );
    if (validTime == null) {
      debugPrint("Invalid time interval in $setType set reading '$reading'");
      continue;
    }

    if (!reading.containsKey("value")) {
      debugPrint("Missing value in $setType set reading '$reading'");
      continue;
    }
    final parsedVal = parser(reading["value"]);
    if (parsedVal == null) {
      debugPrint("Failed to parse value in $setType set reading '$reading'");
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
      debugPrint("value in weather set should be a list");
      return null;
    }
    for (final obj in raw) {
      if (obj == null) {
        debugPrint("Null value in weather set");
        continue;
      }
      if (obj is! Map<String, dynamic>) {
        debugPrint("value in weather set should be an object");
        continue;
      }
    }
  });
}
