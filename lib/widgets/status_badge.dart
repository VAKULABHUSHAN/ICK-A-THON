import 'package:flutter/material.dart';
import '../models/medicine_batch.dart';
import '../models/medicine_item.dart';
import '../theme/app_colors.dart';

enum BadgeType {
  active,
  expiringSoon,
  expired,
  recalled,
  split,
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

  factory StatusBadge.forItem(MedicineItem item, {bool compact = false}) {
    final batch = item.batch;
    if (batch != null && batch.isRecalled) {
      return StatusBadge(type: BadgeType.recalled, compact: compact);
    }
    if (batch != null && batch.isExpired) {
      return StatusBadge(type: BadgeType.expired, compact: compact);
    }
    if (item.status == ItemStatus.split) {
      return StatusBadge(type: BadgeType.split, compact: compact);
    }
    if (batch != null && batch.isExpiringSoon) {
      return StatusBadge(type: BadgeType.expiringSoon, compact: compact);
    }
    return StatusBadge(type: BadgeType.active, compact: compact);
  }

  factory StatusBadge.forBatch(MedicineBatch batch, {bool compact = false}) {
    if (batch.isRecalled) {
      return StatusBadge(type: BadgeType.recalled, compact: compact);
    }
    if (batch.isExpired) {
      return StatusBadge(type: BadgeType.expired, compact: compact);
    }
    if (batch.isExpiringSoon) {
      return StatusBadge(type: BadgeType.expiringSoon, compact: compact);
    }
    return StatusBadge(type: BadgeType.active, compact: compact);
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    switch (type) {
      case BadgeType.recalled:
        bg = AppColors.criticalBg;
        fg = AppColors.critical;
        icon = Icons.warning_rounded;
        label = customLabel ?? 'RECALLED';
        break;
      case BadgeType.expired:
        bg = AppColors.criticalBg.withOpacity(0.6);
        fg = AppColors.critical;
        icon = Icons.event_busy_rounded;
        label = customLabel ?? 'EXPIRED';
        break;
      case BadgeType.expiringSoon:
        bg = AppColors.warningBg;
        fg = AppColors.warning;
        icon = Icons.alarm_rounded;
        label = customLabel ?? 'EXPIRING SOON';
        break;
      case BadgeType.split:
        bg = AppColors.splitBg;
        fg = AppColors.split;
        icon = Icons.alt_route_rounded;
        label = customLabel ?? 'SPLIT PARENT';
        break;
      case BadgeType.active:
        bg = AppColors.successBg;
        fg = AppColors.success;
        icon = Icons.check_circle_rounded;
        label = customLabel ?? 'ACTIVE';
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
        border: Border.all(color: fg.withOpacity(0.25), width: 1),
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
