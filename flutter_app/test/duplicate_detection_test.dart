import 'package:flutter_test/flutter_test.dart';
import 'package:lupilup_flutter/features/stash/data/yarn_stash_item.dart';
import 'package:lupilup_flutter/features/stash/domain/duplicate_detection.dart';

void main() {
  test('duplicateScore favors exact brand, color, and lot matches', () {
    final item = YarnStashItem(
      id: '1',
      userId: 'u1',
      type: YarnType.skein,
      source: YarnSource.manual,
      createdAt: DateTime(2026, 1, 1),
      brand: 'Sandnes Garn',
      name: 'Sunday',
      colorName: 'Almond',
      lot: '7781',
    );

    final strong = duplicateScore(
      item,
      brand: 'Sandnes Garn',
      colorName: 'Almond',
      lot: '7781',
    );
    final weak = duplicateScore(
      item,
      brand: 'Another Brand',
      colorName: 'Almond',
      lot: '7781',
    );

    expect(strong, greaterThan(weak));
    expect(strong, 1.0);
  });
}

