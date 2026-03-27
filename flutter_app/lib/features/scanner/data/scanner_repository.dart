import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lupilup_flutter/features/scanner/data/scan_draft.dart';
import 'package:lupilup_flutter/features/stash/data/stash_repository.dart';
import 'package:lupilup_flutter/features/stash/data/yarn_stash_item.dart';

class ScannerRepository {
  ScannerRepository(this._stashRepository) : _picker = ImagePicker();

  final StashRepository _stashRepository;
  final ImagePicker _picker;

  Future<XFile?> pickImage(ImageSource source) {
    return _picker.pickImage(source: source, imageQuality: 88);
  }

  Future<ScanDraft?> scanImage(XFile? image) async {
    if (image == null) return null;

    final draft = _stashRepository.makeDraft(
      source: YarnSource.scan,
      name: 'Scanned yarn draft',
    );

    return ScanDraft(
      imagePath: image.path,
      rawText: 'OCR is temporarily disabled in the Flutter migration build.',
      suggestedItem: draft,
      duplicates: const [],
    );
  }
}

final scannerRepositoryProvider = Provider<ScannerRepository>((ref) {
  return ScannerRepository(ref.watch(stashRepositoryProvider));
});
