import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../theme/app_colors.dart';

class FamilyAvatar extends StatelessWidget {
  final FamilyMember? member;
  final bool isSelected;
  final VoidCallback? onTap;
  final double size;
  final bool showLabel;

  const FamilyAvatar({
    super.key,
    this.member,
    this.isSelected = false,
    this.onTap,
    this.size = 56,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final isAll = member == null;
    final displayName = isAll ? 'All' : member!.name;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isAll ? AppColors.primaryDark : member!.avatarBgColor,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x15000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isAll ? Icons.groups_rounded : member!.defaultIcon,
                color: Colors.white,
                size: size * 0.5,
              ),
            ),
          ),
          if (showLabel) ...[
            const SizedBox(height: 6),
            Text(
              displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
