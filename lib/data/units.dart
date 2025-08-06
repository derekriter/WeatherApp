import 'dart:math';

import 'package:iso_duration/iso_duration.dart';

class Temperature {
  static const _fahrenheitIDs = [
    "wmo:degF",
    "wmoUnit:degF",
    "uc:[degF]",
    "degF",
  ];
  static const _celsiusIDs = [
    "wmo:degC",
    "wmoUnit:degC",
    "wmo:Cel",
    "wmoUnit:Cel",
    "uc:Cel",
    "Cel",
  ];
  static const _kelvinIDs = ["wmo:K", "wmoUnit:K", "uc:K", "K"];

  static const fahrenheitSuffix = " °F";
  static const celsiusSuffix = " °C";
  static const kelvinSuffix = " K";

  // universal val is in celsius
  final double _universalVal;

  Temperature._(this._universalVal);

  static Temperature? fromUnitID(String unitID, double val) {
    if (_fahrenheitIDs.contains(unitID)) {
      return Temperature._((val - 32) / 1.8);
    }
    if (_celsiusIDs.contains(unitID)) {
      return Temperature._(val);
    }
    if (_kelvinIDs.contains(unitID)) {
      return Temperature._(val - 273);
    }
    return null;
  }

  static bool isValidID(String unitID) {
    return [..._fahrenheitIDs, ..._celsiusIDs, ..._kelvinIDs].contains(unitID);
  }

  double get fahrenheit => _universalVal * 1.8 + 32;
  double get celsius => _universalVal;
  double get kelvin => _universalVal + 273;

  String get fahrenheitString => "$fahrenheit$fahrenheitSuffix";
  String get celsiusString => "$celsius$celsiusSuffix";
  String get kelvinString => "$kelvin$kelvinSuffix";

  @override
  String toString() {
    return celsiusString;
  }
}

class Time {
  final DateTime date;

  Time(this.date);

  /// Parses an ISO 8601 time string. The string "NOW" can also be used to substitute in the current time
  static Time? fromIso8601String(String raw) {
    if (raw == "NOW") {
      return Time(DateTime.now());
    }

    DateTime? parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      print("Invalid time '$raw'");
      return null;
    }

    return Time(parsed);
  }

  DateTime get utcDate => date.toUtc();
  DateTime get localDate => date.toLocal();

  String get utcString => utcDate.toString();
  String get localString => localDate.toString();

  @override
  String toString() {
    return utcString;
  }
}

class TimeInterval {
  final Time start, end;

  TimeInterval({required this.start, required this.end});

  /// Supports 3 formats:
  ///  - start time/end time
  ///  - start time/duration
  ///  - duration/end time
  static TimeInterval? fromIso8601String(String raw) {
    Duration? parseDuration(String rawChunk) {
      Duration? parsed = tryParseIso8601Duration(rawChunk, zeroAsNull: false);
      if (parsed == null) {
        print("Invalid duration '$rawChunk'");
      }

      return parsed;
    }

    final chunks = raw.split("/");
    if (chunks.length != 2) {
      print("Invalid internval '$raw'");
      return null;
    }

    if (chunks[0].startsWith("P")) {
      if (chunks[1].startsWith("P")) {
        //invalid format duration/duration
        print("Invalid interval '$raw'");
        return null;
      }

      final duration = parseDuration(chunks[0]);
      final endTime = Time.fromIso8601String(chunks[1]);

      if (duration == null || endTime == null) {
        print("Invalid interval '$raw'");
        return null;
      }

      return TimeInterval(
        start: Time(endTime.date.subtract(duration)),
        end: endTime,
      );
    } else {
      final startTime = Time.fromIso8601String(chunks[0]);

      if (chunks[1].startsWith("P")) {
        final duration = parseDuration(chunks[1]);

        if (startTime == null || duration == null) {
          print("Invalid interval '$raw'");
          return null;
        }

        return TimeInterval(
          start: startTime,
          end: Time(startTime.date.add(duration)),
        );
      } else {
        final endTime = Time.fromIso8601String(chunks[1]);

        if (startTime == null || endTime == null) {
          print("Invalid interval '$raw'");
          return null;
        }

        return TimeInterval(start: startTime, end: endTime);
      }
    }
  }

  /// Returns true if the given time is included in the time interval. This treats the start time as inclusive and the end as exclusive.
  bool contains(Time time) {
    return (time.date.isAtSameMomentAs(start.date) ||
            time.date.isAfter(start.date)) &&
        time.date.isBefore(end.date);
  }

  Duration get duration => end.date.difference(start.date);

  String get startEndString => "$start/$end";
  String get startDurationString => "$start/$duration";
  String get durationEndString => "$duration/$end";

  @override
  String toString() {
    return startDurationString;
  }
}

class Fraction {
  static const _percentageIDs = ["wmoUnit:percent", "wmo:percent", "uc:%", "%"];
  static const _ppthIDs = ["wmoUnit:0.001", "wmo:0.001", "uc:ppth", "ppth"];
  static const _ppmIDs = ["uc:ppm", "ppm"];
  static const _ppbIDs = ["uc:ppb", "ppb"];
  static const _pptrIDs = ["uc:pptr", "pptr"];

  static const percentageSuffix = "%";
  static const ppthSuffix = " ppth";
  static const ppmSuffix = " ppm";
  static const ppbSuffix = " ppb";
  static const pptrSuffix = " pptr";

  // universal val is in decimal
  final double _universalVal;

  Fraction._(this._universalVal);

  static Fraction? fromUnitID(String unitID, double val) {
    if (_percentageIDs.contains(unitID)) {
      return Fraction._(val / 100);
    }
    if (_ppthIDs.contains(unitID)) {
      return Fraction._(val / 1e3);
    }
    if (_ppmIDs.contains(unitID)) {
      return Fraction._(val / 1e6);
    }
    if (_ppbIDs.contains(unitID)) {
      return Fraction._(val / 1e9);
    }
    if (_pptrIDs.contains(unitID)) {
      return Fraction._(val / 1e12);
    }
    return null;
  }

  static bool isValidID(String unitID) {
    return [
      ..._percentageIDs,
      ..._ppthIDs,
      ..._ppmIDs,
      ..._ppbIDs,
      ..._pptrIDs,
    ].contains(unitID);
  }

  double get decimal => _universalVal;
  double get percentage => _universalVal * 100;
  double get ppth => _universalVal * 1e3;
  double get ppm => _universalVal * 1e6;
  double get ppb => _universalVal * 1e9;
  double get pptr => _universalVal * 1e12;

  String get percentageString => "$percentage$percentageSuffix";
  String get ppthString => "$ppth$ppthSuffix";
  String get ppmString => "$ppm$ppmSuffix";
  String get ppbString => "$ppb$ppbSuffix";
  String get pptrString => "$pptr$pptrSuffix";

  @override
  String toString() {
    return percentageString;
  }
}

class Angle {
  static const _degreeIDs = [
    "wmo:degree_(angle)",
    "wmoUnit:degree_(angle)",
    "wmo:degrees_true",
    "wmoUnit:degrees_true",
    "uc:deg",
    "deg",
  ];
  static const _radianIDs = ["wmo:rad", "wmoUnit:rad", "uc:rad", "rad"];
  static const _minuteIDs = ["wmo:'", "wmoUnit:'", "uc:'", "'"];
  static const _secondsIDs = ["wmo:\"", "wmoUnit:\"", "uc:\"", "\""];

  static const degreeSuffix = "°";
  static const radianSuffix = " rad";
  static const minuteSuffix = "'";
  static const secondSuffix = "\"";

  // universal val is in degrees
  final double _universalVal;

  Angle._(this._universalVal);

  static Angle? fromUnitID(String unitID, double val) {
    if (_degreeIDs.contains(unitID)) {
      return Angle._(val);
    }
    if (_radianIDs.contains(unitID)) {
      return Angle._(val / pi * 180);
    }
    if (_minuteIDs.contains(unitID)) {
      return Angle._(val / 60);
    }
    if (_secondsIDs.contains(unitID)) {
      return Angle._(val / 360);
    }
    return null;
  }

  static bool isValidID(String unitID) {
    return [
      ..._degreeIDs,
      ..._radianIDs,
      ..._minuteIDs,
      ..._secondsIDs,
    ].contains(unitID);
  }

  double get degrees => _universalVal;
  double get radians => _universalVal / 180 * pi;
  double get minutes => _universalVal * 60;
  double get seconds => _universalVal * 360;

  String get degreesString => "$degrees$degreeSuffix";
  String get radiansString => "$radians$radianSuffix";
  String get minutesString => "$minutes$minuteSuffix";
  String get secondsString => "$seconds$secondSuffix";

  @override
  String toString() {
    return degreesString;
  }
}

class Speed {
  static const _kmhIDs = ["wmo:km_h-1", "wmoUnit:km_h-1"];

  static const kmhSuffix = " kmh";
  static const mphSuffix = " mph";

  // universal val is in kmh
  final double _universalVal;

  Speed._(this._universalVal);

  static Speed? fromUnitID(String unitID, double val) {
    if (_kmhIDs.contains(unitID)) {
      return Speed._(val);
    }
    return null;
  }

  static bool isValidID(String unitID) {
    return [..._kmhIDs].contains(unitID);
  }

  double get kmh => _universalVal;
  double get mph => _universalVal / 1.609344;

  String get kmhString => "$kmh$kmhSuffix";
  String get mphString => "$mph$mphSuffix";

  @override
  String toString() {
    return kmhString;
  }
}

class Distance {
  static const _footIDs = [
    "wmo:ft",
    "wmoUnit:ft",
    "uc:[ft_br]",
    "[ft_br]",
    "uc:[ft_i]",
    "[ft_i]",
    "uc:[ft_us]",
    "[ft_us]",
  ];
  static const _inchIDs = [
    "uc:[in_br]",
    "[in_br]",
    "uc:[in_i]",
    "[in_i]",
    "uc:[in_us]",
    "[in_us]",
  ];
  static const _meterIDs = ["wmo:m", "wmoUnit:m", "uc:m", "m"];
  static const _mileIDs = [
    "uc:[mi_br]",
    "[mi_br]",
    "uc:[mi_i]",
    "[mi_i]",
    "uc:[mi_us]",
    "[mi_us]",
  ];
  static const _yardIDs = [
    "uc:[yd_br]",
    "[yd_br]",
    "uc:[yd_i]",
    "[yd_i]",
    "uc:[yd_us]",
    "[yd_us]",
  ];
  static const _kilometerIDs = ["wmo:km", "wmoUnit:km"];

  static const footSuffix = " ft";
  static const inchSuffix = " in";
  static const meterSuffix = " m";
  static const mileSuffix = " mi";
  static const yardSuffix = " yd";
  static const kilometerSuffix = " km";

  // universal val is in km
  final double _universalVal;

  Distance._(this._universalVal);

  static Distance? fromUnitID(String unitID, double val) {
    if (_footIDs.contains(unitID)) {
      return Distance._(val * 3.048e-4);
    }
    if (_inchIDs.contains(unitID)) {
      return Distance._(val * 2.54e-5);
    }
    if (_meterIDs.contains(unitID)) {
      return Distance._(val * 1e-3);
    }
    if (_mileIDs.contains(unitID)) {
      return Distance._(val * 1.609344);
    }
    if (_yardIDs.contains(unitID)) {
      return Distance._(val * 9.144e-4);
    }
    if (_kilometerIDs.contains(unitID)) {
      return Distance._(val);
    }
    return null;
  }

  static bool isValidID(String unitID) {
    return [
      ..._footIDs,
      ..._inchIDs,
      ..._meterIDs,
      ..._mileIDs,
      ..._yardIDs,
      ..._kilometerIDs,
    ].contains(unitID);
  }

  double get feet => _universalVal / 3.048e-4;
  double get inches => _universalVal / 2.54e-5;
  double get meters => _universalVal / 1e-3;
  double get miles => _universalVal / 1.609344;
  double get yards => _universalVal / 9.144e-4;
  double get kilometers => _universalVal;

  String get feetString => "$feet$footSuffix";
  String get inchesString => "$inches$inchSuffix";
  String get metersString => "$meters$meterSuffix";
  String get milesString => "$miles$mileSuffix";
  String get yardsString => "$yards$yardSuffix";
  String get kilometersString => "$kilometers$kilometerSuffix";

  @override
  String toString() {
    return kilometersString;
  }
}
