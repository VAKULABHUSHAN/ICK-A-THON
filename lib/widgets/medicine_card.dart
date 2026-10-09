import 'package:flutter/material.dart';
import '../models/medicine_item.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatter.dart';
import 'status_badge.dart';

class MedicineCard extends StatelessWidget {
  final MedicineItem item;
  final VoidCallback? onTap;

  const MedicineCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final batch = item.batch;
    final isRecalled = batch?.isRecalled ?? false;
    final isExpired = batch?.isExpired ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRecalled
            ? AppColors.criticalBg.withOpacity(0.15)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecalled
              ? AppColors.critical.withOpacity(0.5)
              : isExpired
                  ? AppColors.critical.withOpacity(0.3)
                  : AppColors.cardBorder,
          width: isRecalled ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isRecalled
                            ? AppColors.criticalBg
                            : isExpired
                                ? AppColors.criticalBg.withOpacity(0.5)
                                : AppColors.accentSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isRecalled
                            ? Icons.warning_rounded
                            : Icons.medication_rounded,
                        color: isRecalled
                            ? AppColors.critical
                            : isExpired
                                ? AppColors.critical
                                : AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            batch?.medicineName ?? 'Unknown Medicine',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isRecalled
                                  ? AppColors.critical
                                  : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: AppColors.cardBorder),
                                ),
                                child: Text(
                                  'BATCH: ${batch?.batchNumber ?? "N/A"}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              if (item.parentItemId != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.splitBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'CHILD PORTION',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.split,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    StatusBadge.forItem(item, compact: true),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.cardBorder),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.inventory_2_outlined,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${item.quantity} ${item.unit}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.place_outlined,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.location ?? 'Unspecified',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          batch != null
                              ? 'Exp: ${DateFormatter.format(batch.expiryDate)}'
                              : 'No expiry date',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (batch != null)
                      Text(
                        DateFormatter.daysRemainingText(batch.expiryDate),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: batch.isExpired
                              ? AppColors.critical
                              : batch.isExpiringSoon
                                  ? AppColors.warning
                                  : AppColors.success,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
