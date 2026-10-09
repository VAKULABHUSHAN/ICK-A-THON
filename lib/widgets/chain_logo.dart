import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ChainLogo extends StatelessWidget {
  final double size;
  final bool showTagline;
  final Color? color;

  const ChainLogo({
    super.key,
    this.size = 36,
    this.showTagline = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? AppColors.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.link_rounded,
                size: size * 0.58,
                color: primaryColor,
              ),
              Positioned(
                right: 3,
                top: 3,
                child: Container(
                  width: size * 0.28,
                  height: size * 0.28,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    size: size * 0.18,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Expiry',
                  style: TextStyle(
                    fontSize: size * 0.56,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Chain',
                  style: TextStyle(
                    fontSize: size * 0.56,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            if (showTagline)
              Text(
                'THE IDENTITY SURVIVES',
                style: TextStyle(
                  fontSize: size * 0.26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
