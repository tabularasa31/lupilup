import 'package:flutter_test/flutter_test.dart';
import 'package:lupilup_flutter/features/ravelry/domain/ravelry_mapper.dart';
import 'package:lupilup_flutter/features/settings/data/user_settings.dart';

void main() {
  test('detectRavelryUnitSystem returns imperial for yard-based unit', () {
    expect(detectRavelryUnitSystem('yards'), UnitSystem.imperial);
  });

  test('mapRavelryStashRows converts yardage into meters per 100g', () {
    final rows = mapRavelryStashRows(
      {
        'length_unit': 'yards',
        'stash': [
          {
            'yarn_company_name': 'Woolfolk',
            'name': 'Far',
            'colorway': 'Oat',
            'fiber': '100% merino',
            'grams': 50,
            'yardage': 142,
            'dye_lot': 'A1',
          },
        ],
      },
      UnitSystem.imperial,
    );

    expect(rows, hasLength(1));
    expect(rows.first.brand, 'Woolfolk');
    expect(rows.first.lengthMPer100g, 260);
    expect(rows.first.currentWeightG, 50);
  });

  test('extractRavelryUsername supports nested current_user payloads', () {
    final username = extractRavelryUsername({
      'user': {'username': 'maker_girl'}
    });

    expect(username, 'maker_girl');
  });
}

