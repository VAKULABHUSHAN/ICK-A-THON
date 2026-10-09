import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../theme/app_colors.dart';

enum BadgeType {
  normal,
  expiringSoon,
  lowStock,
  expired,
  critical,
}

class StatusBadge extends StatelessWidget {
  final BadgeType type;
  final String? customLabel;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.type,
    this.customLabel,
    this.compact = false,
  });

  factory StatusBadge.forMedicine(Medicine medicine, {bool compact = false}) {
    if (medicine.isExpired) {
      return StatusBadge(type: BadgeType.expired, compact: compact);
    }
    if (medicine.isExpiringSoon) {
      return StatusBadge(type: BadgeType.expiringSoon, compact: compact);
    }
    if (medicine.isLowStock) {
      return StatusBadge(type: BadgeType.lowStock, compact: compact);
    }
    return StatusBadge(type: BadgeType.normal, compact: compact);
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    switch (type) {
      case BadgeType.expired:
        bg = AppColors.criticalBg;
        fg = AppColors.critical;
        icon = Icons.event_busy_rounded;
        label = customLabel ?? 'EXPIRED';
        break;
      case BadgeType.expiringSoon:
        bg = AppColors.expiringSoonBg;
        fg = AppColors.expiringSoon;
        icon = Icons.alarm_rounded;
        label = customLabel ?? 'EXPIRING SOON';
        break;
      case BadgeType.lowStock:
        bg = AppColors.lowStockBg;
        fg = AppColors.lowStock;
        icon = Icons.inventory_2_outlined;
        label = customLabel ?? 'LOW STOCK';
        break;
      case BadgeType.critical:
        bg = AppColors.criticalBg;
        fg = AppColors.critical;
        icon = Icons.warning_amber_rounded;
        label = customLabel ?? 'ALERT';
        break;
      case BadgeType.normal:
        bg = AppColors.normalBg;
        fg = AppColors.normal;
        icon = Icons.check_circle_outline_rounded;
        label = customLabel ?? 'OK';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
