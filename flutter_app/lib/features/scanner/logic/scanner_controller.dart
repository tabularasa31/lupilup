import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lupilup_flutter/features/scanner/data/scan_draft.dart';
import 'package:lupilup_flutter/features/scanner/data/scanner_repository.dart';
import 'package:lupilup_flutter/features/stash/data/stash_repository.dart';

class ScannerController extends AsyncNotifier<ScanDraft?> {
  @override
  Future<ScanDraft?> build() async => null;

  Future<void> pickAndScan(ImageSource source) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final image = await ref.read(scannerRepositoryProvider).pickImage(source);
      return ref.read(scannerRepositoryProvider).scanImage(image);
    });
  }

  Future<void> saveScanDraft(ScanDraft draft) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(stashRepositoryProvider).save(draft.suggestedItem);
      return draft;
    });
  }

  void clear() {
    state = const AsyncData(null);
  }
}

final scannerControllerProvider =
    AsyncNotifierProvider<ScannerController, ScanDraft?>(ScannerController.new);

