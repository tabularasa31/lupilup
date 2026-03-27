import 'package:lupilup_flutter/features/settings/data/user_settings.dart';

typedef RavelryRowSeed = ({
  String? brand,
  String? name,
  String? colorName,
  String? fiberContent,
  int? lengthMPer100g,
  double? currentWeightG,
  double? originalWeightG,
  String? lot,
});

UnitSystem detectRavelryUnitSystem(dynamic value) {
  final normalized = (value as String? ?? '').toLowerCase();
  if (normalized.contains('yard')) {
    return UnitSystem.imperial;
  }
  return UnitSystem.metric;
}

List<dynamic> extractRavelryEntries(dynamic stashJson) {
  if (stashJson is List<dynamic>) {
    return stashJson;
  }
  if (stashJson is! Map<String, dynamic>) {
    return const [];
  }

  const candidates = ['stash', 'entries', 'yarns', 'data', 'items', 'results'];
  for (final key in candidates) {
    final value = stashJson[key];
    if (value is List<dynamic>) {
      return value;
    }
  }

  final values = stashJson.values.toList();
  if (values.isNotEmpty &&
      values.every((value) => value is Map<String, dynamic> || value is List<dynamic>)) {
    return values.expand((value) {
      if (value is List<dynamic>) return value;
      return [value];
    }).toList();
  }

  return const [];
}

String extractRavelryUsername(dynamic json) {
  if (json is Map<String, dynamic>) {
    final direct = json['username'];
    if (direct is String && direct.isNotEmpty) {
      return direct;
    }
    final user = json['user'];
    if (user is Map<String, dynamic>) {
      final nested = user['username'];
      if (nested is String && nested.isNotEmpty) {
        return nested;
      }
    }
  }
  throw StateError('Could not resolve Ravelry username.');
}

List<RavelryRowSeed> mapRavelryStashRows(
  dynamic stashJson,
  UnitSystem unitSystem,
) {
  final entries = extractRavelryEntries(stashJson);
  final rows = <RavelryRowSeed>[];

  for (final entry in entries) {
    if (entry is! Map<String, dynamic>) {
      continue;
    }

    final grams = _toDouble(
      entry['grams'] ?? entry['weight_g'] ?? entry['skein_weight_g'],
    );
    final yardage = _toDouble(
      entry['yardage'] ?? entry['meters'] ?? entry['length'],
    );

    if (grams == null || yardage == null || grams <= 0 || yardage <= 0) {
      continue;
    }

    final meters = _convertLengthToMeters(unitSystem, yardage);
    final lengthPer100g = ((meters / grams) * 100).round();

    rows.add((
      brand: (entry['yarn_company_name'] ?? entry['brand']) as String?,
      name: (entry['name'] ?? entry['yarn_name']) as String?,
      colorName: (entry['colorway'] ?? entry['color_name']) as String?,
      fiberContent: (entry['fiber'] ?? entry['fiber_content']) as String?,
      lengthMPer100g: lengthPer100g,
      currentWeightG: grams,
      originalWeightG: grams,
      lot: (entry['dye_lot'] ?? entry['lot']) as String?,
    ));
  }

  return rows;
}

double _convertLengthToMeters(UnitSystem system, double value) {
  if (system == UnitSystem.metric) {
    return value;
  }
  return value * 0.9144;
}

double? _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

