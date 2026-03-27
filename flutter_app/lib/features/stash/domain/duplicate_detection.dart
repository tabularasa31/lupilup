import 'package:lupilup_flutter/features/stash/data/yarn_stash_item.dart';

double duplicateScore(
  YarnStashItem existing, {
  String? brand,
  String? colorName,
  String? lot,
}) {
  double score = 0;

  if (_same(existing.brand, brand)) score += 0.45;
  if (_same(existing.colorName, colorName)) score += 0.35;
  if (_same(existing.lot, lot)) score += 0.20;

  return score;
}

bool _same(String? a, String? b) {
  final left = (a ?? '').trim().toLowerCase();
  final right = (b ?? '').trim().toLowerCase();
  if (left.isEmpty || right.isEmpty) return false;
  return left == right;
}

