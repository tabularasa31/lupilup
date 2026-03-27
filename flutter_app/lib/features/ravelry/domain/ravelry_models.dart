import 'package:lupilup_flutter/features/settings/data/user_settings.dart';
import 'package:lupilup_flutter/features/stash/data/yarn_stash_item.dart';

class RavelryImportResult {
  const RavelryImportResult({
    required this.rows,
    required this.unitSystem,
  });

  final List<YarnStashItem> rows;
  final UnitSystem unitSystem;
}

