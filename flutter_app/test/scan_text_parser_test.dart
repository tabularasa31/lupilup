import 'package:flutter_test/flutter_test.dart';
import 'package:lupilup_flutter/features/scanner/domain/scan_text_parser.dart';

void main() {
  test('parseScanText extracts yarn metadata from OCR text', () {
    const rawText = '''
Sandnes Garn
Sunday
Color: Almond
100% Merino
50 g
235 m
Lot 7781
''';

    final parsed = parseScanText(rawText);

    expect(parsed.brand, 'Sandnes Garn');
    expect(parsed.name, 'Sunday');
    expect(parsed.colorName, 'Almond');
    expect(parsed.lot, '7781');
    expect(parsed.currentWeightG, 50);
    expect(parsed.lengthMPer100g, 470);
  });
}

