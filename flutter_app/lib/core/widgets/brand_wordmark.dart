import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lupilup_flutter/core/theme/app_theme.dart';

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({
    super.key,
    this.size = 54,
    this.textAlign = TextAlign.center,
  });

  final double size;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final baseStyle = GoogleFonts.playfairDisplay(
      fontSize: size,
      fontWeight: FontWeight.w600,
      height: 0.95,
      letterSpacing: -1.1,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'lupi',
            style: baseStyle.copyWith(color: AppColors.textPrimary),
          ),
          TextSpan(
            text: 'lup',
            style: baseStyle.copyWith(color: const Color(0xFFD6A6AA)),
          ),
        ],
      ),
      textAlign: textAlign,
    );
  }
}
