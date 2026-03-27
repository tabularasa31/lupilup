class ParsedScanFields {
  const ParsedScanFields({
    this.brand,
    this.name,
    this.colorName,
    this.fiberContent,
    this.lengthMPer100g,
    this.currentWeightG,
    this.originalWeightG,
    this.lot,
  });

  final String? brand;
  final String? name;
  final String? colorName;
  final String? fiberContent;
  final int? lengthMPer100g;
  final double? currentWeightG;
  final double? originalWeightG;
  final String? lot;
}

ParsedScanFields parseScanText(String rawText) {
  final lines = rawText
      .split(RegExp(r'[\r\n]+'))
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList();

  String? extract(RegExp pattern) {
    final match = pattern.firstMatch(rawText);
    return match?.group(1)?.trim();
  }

  final weightMatch = extract(RegExp(r'(\d+(?:[.,]\d+)?)\s*g', caseSensitive: false));
  final lengthMatch = extract(
    RegExp(r'(\d+(?:[.,]\d+)?)\s*(?:m|meters|metres|yd|yards)', caseSensitive: false),
  );
  final lot = extract(RegExp(r'lot[:\s#-]*([A-Za-z0-9-]+)', caseSensitive: false));

  final brand = lines.isNotEmpty ? lines.first : null;
  final name = lines.length > 1 ? lines[1] : null;
  final colorName = extract(
    RegExp(r'(?:color|colour|colorway)[:\s-]*([A-Za-z0-9 ]+)', caseSensitive: false),
  );
  final fiber = extract(
    RegExp(r'((?:\d{1,3}%\s*[A-Za-z]+(?:,\s*)?)+)', caseSensitive: false),
  );
  final currentWeight = double.tryParse(weightMatch?.replaceAll(',', '.') ?? '');
  final lengthValue = double.tryParse(lengthMatch?.replaceAll(',', '.') ?? '');
  final lengthMPer100g = currentWeight != null &&
          currentWeight > 0 &&
          lengthValue != null &&
          lengthValue > 0
      ? ((lengthValue / currentWeight) * 100).round()
      : null;

  return ParsedScanFields(
    brand: brand,
    name: name,
    colorName: colorName,
    fiberContent: fiber,
    lengthMPer100g: lengthMPer100g,
    currentWeightG: currentWeight,
    originalWeightG: currentWeight,
    lot: lot,
  );
}

