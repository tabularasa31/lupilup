import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lupilup_flutter/core/theme/app_theme.dart';
import 'package:lupilup_flutter/features/stash/data/yarn_stash_item.dart';

class YarnCard extends StatelessWidget {
  const YarnCard({
    required this.item,
    super.key,
    this.onTap,
    this.trailing,
  });

  final YarnStashItem item;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final progress = _progressValue(item);
    final color = _parseColor(item.colorHex);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderStrong),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.playfairDisplay(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height: 1.08,
                            ),
                          ),
                        ),
                        if (trailing != null) ...[
                          const SizedBox(width: 6),
                          trailing!,
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _detailsLine(item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.2,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        value: progress,
                        backgroundColor: const Color(0xFFF1EEE8),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.progressBar,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _gramsLabel(item.currentWeightG),
                          style: GoogleFonts.playfairDisplay(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                        TextSpan(
                          text: 'g',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _metersLabel(item),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                          height: 1.2,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _detailsLine(YarnStashItem item) {
    final parts = <String>[
      if ((item.fiberContent ?? '').trim().isNotEmpty) item.fiberContent!.trim(),
      if (item.lengthMPer100g != null) '${item.lengthMPer100g} m / 100g',
    ];

    if (parts.isEmpty) {
      return item.type.name[0].toUpperCase() + item.type.name.substring(1);
    }
    return parts.join(' · ');
  }

  static String _gramsLabel(double? grams) {
    if (grams == null) return '0';
    final rounded = grams.roundToDouble();
    if (rounded == grams) {
      return rounded.toInt().toString();
    }
    return grams.toStringAsFixed(1);
  }

  static String _metersLabel(YarnStashItem item) {
    final currentWeight = item.currentWeightG;
    final length = item.lengthMPer100g;
    if (currentWeight == null || length == null) return 'meters unknown';

    final meters = (currentWeight * length) / 100;
    final rounded = meters.round();
    return '$rounded m left';
  }

  static double? _progressValue(YarnStashItem item) {
    final current = item.currentWeightG;
    final original = item.originalWeightG;
    if (current == null || original == null || original <= 0) {
      return 0;
    }

    return (current / original).clamp(0, 1).toDouble();
  }

  static Color _parseColor(String? hex) {
    final normalized = (hex ?? '').trim().replaceFirst('#', '');
    if (normalized.isEmpty) return const Color(0xFFE7E1D8);

    final withAlpha = switch (normalized.length) {
      6 => 'FF$normalized',
      8 => normalized,
      _ => '',
    };
    if (withAlpha.isEmpty) return const Color(0xFFE7E1D8);

    final parsed = int.tryParse(withAlpha, radix: 16);
    if (parsed == null) return const Color(0xFFE7E1D8);
    return Color(parsed);
  }
}
