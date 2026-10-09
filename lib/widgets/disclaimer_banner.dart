import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DisclaimerBanner extends StatelessWidget {
  final bool compact;

  const DisclaimerBanner({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        color: AppColors.infoBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: compact ? 16 : 18,
            color: AppColors.info,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Identity Trace Notice: QR codes preserve batch identity, trace split portions, and check recall warnings. They do not independently verify chemical purity or physical safety.',
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
