import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ChainLogo extends StatelessWidget {
  final double size;
  final bool showTagline;

  const ChainLogo({
    super.key,
    this.size = 36,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x306516D5),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.link_rounded,
                size: size * 0.58,
                color: Colors.white,
              ),
              Positioned(
                right: 3,
                top: 3,
                child: Container(
                  width: size * 0.28,
                  height: size * 0.28,
                  decoration: const BoxDecoration(
                    color: AppColors.lavender,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    size: size * 0.18,
                    color: AppColors.primary,
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
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            if (showTagline)
              Text(
                'THE IDENTITY THAT SURVIVES',
                style: TextStyle(
                  fontSize: size * 0.24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
