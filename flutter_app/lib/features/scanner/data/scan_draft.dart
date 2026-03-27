import 'package:lupilup_flutter/features/stash/data/yarn_stash_item.dart';

class ScanDraft {
  const ScanDraft({
    required this.rawText,
    required this.suggestedItem,
    required this.duplicates,
    this.imagePath,
  });

  final String? imagePath;
  final String rawText;
  final YarnStashItem suggestedItem;
  final List<YarnStashItem> duplicates;
}

