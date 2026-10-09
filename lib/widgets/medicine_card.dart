import 'dart:io';
import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../theme/app_colors.dart';
import '../utils/date_helpers.dart';
import 'status_badge.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback? onTap;

  const MedicineCard({
    super.key,
    required this.medicine,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final member = medicine.familyMember;
    final isLow = medicine.isLowStock;
    final isExp = medicine.isExpired;
    final isExpSoon = medicine.isExpiringSoon;

    Color progressColor = AppColors.primary;
    if (isExp || isLow) {
      progressColor = AppColors.lowStock;
    } else if (isExpSoon) {
      progressColor = AppColors.expiringSoon;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExp || isLow
              ? AppColors.lowStock.withValues(alpha: 0.3)
              : AppColors.cardBorder,
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Packaging Photo Thumbnail or Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.lavenderSoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: medicine.imageFrontUrl != null && medicine.imageFrontUrl!.isNotEmpty
                            ? (medicine.imageFrontUrl!.startsWith('assets/')
                                ? Image.asset(medicine.imageFrontUrl!, fit: BoxFit.cover)
                                : Image.file(
                                    File(medicine.imageFrontUrl!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const Icon(
                                      Icons.medication_rounded,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ))
                            : const Icon(
                                Icons.medication_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & Assigned Family Member
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicine.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (member != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: member.avatarBgColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(member.defaultIcon, size: 12, color: member.avatarBgColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        member.name,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: member.avatarBgColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.cardBorder),
                                ),
                                child: Text(
                                  medicine.category,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    StatusBadge.forMedicine(medicine, compact: true),
                  ],
                ),

                const SizedBox(height: 14),

                // Remaining Quantity Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${medicine.remainingQuantity} / ${medicine.totalQuantity} ${medicine.unit} left',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isLow ? AppColors.lowStock : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${(medicine.stockProgress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isLow ? AppColors.lowStock : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: medicine.stockProgress,
                        backgroundColor: AppColors.lavenderSoft,
                        color: progressColor,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Expiry Date Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          'Exp: ${DateHelpers.format(medicine.expiryDate)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      DateHelpers.daysRemainingText(medicine.expiryDate),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isExp
                            ? AppColors.critical
                            : isExpSoon
                                ? AppColors.expiringSoon
                                : AppColors.normal,
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
