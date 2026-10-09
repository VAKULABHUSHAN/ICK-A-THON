import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medicine_item.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/disclaimer_banner.dart';
import '../photo/package_photo_screen.dart';
import '../split/split_trace_screen.dart';

class MedicineDetailsScreen extends StatefulWidget {
  final String itemId;

  const MedicineDetailsScreen({super.key, required this.itemId});

  @override
  State<MedicineDetailsScreen> createState() => _MedicineDetailsScreenState();
}

class _MedicineDetailsScreenState extends State<MedicineDetailsScreen> {
  void _showEditDialog(MedicineItem item) {
    final qtyController = TextEditingController(text: item.quantity.toString());
    final locController = TextEditingController(text: item.location ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Item Record'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locController,
                decoration: const InputDecoration(labelText: 'Storage Location'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final qty = int.tryParse(qtyController.text.trim());
                final loc = locController.text.trim();
                Navigator.pop(context);

                final appState = Provider.of<AppState>(context, listen: false);
                final success = await appState.updateMedicineItem(
                  item.id,
                  quantity: qty,
                  location: loc,
                );

                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item updated successfully.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        final item = state.inventory.firstWhere(
          (i) => i.id == widget.itemId,
          orElse: () => MedicineItem(
            id: widget.itemId,
            batchId: '',
            quantity: 0,
            unit: 'tablets',
          ),
        );

        final batch = item.batch;
        final isRecalled = batch?.isRecalled ?? false;
        final isExpired = batch?.isExpired ?? false;

        final parentItem = state.getParentItem(item.parentItemId);
        final childItems = state.getChildItems(item.id);
        final events = state.events.where((e) => e.itemId == item.id).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Medicine Identity Card'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Item',
                onPressed: () => _showEditDialog(item),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isRecalled) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.criticalBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.critical, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x35DC2626),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.gavel_rounded, color: AppColors.critical, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'OFFICIAL BATCH RECALL WARNING',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.critical,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          batch?.recallReason ?? 'This batch has been flagged as RECALLED by safety authorities.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'DO NOT CONSUME OR ADMINISTER. Quarantine or dispose of this medicine safely according to pharmacy guidelines.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.critical,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Main Medicine Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Package Photo Display Banner
                      if (item.imagePath != null && item.imagePath!.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: item.imagePath!.startsWith('assets/')
                                ? Image.asset(item.imagePath!, fit: BoxFit.cover)
                                : Image.file(
                                    File(item.imagePath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      color: AppColors.background,
                                      child: const Icon(Icons.broken_image_rounded, size: 48, color: AppColors.textMuted),
                                    ),
                                  ),
                          ),
                        ),
                      ],

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        batch?.medicineName ?? 'Medicine Record',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: isRecalled ? AppColors.critical : AppColors.textPrimary,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Batch #: ${batch?.batchNumber ?? "Unknown"}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge.forItem(item),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1, color: AppColors.cardBorder),
                            const SizedBox(height: 16),

                            _DetailRow(
                              icon: Icons.calendar_today_rounded,
                              label: 'Recorded Expiry',
                              value: batch != null
                                  ? DateFormatter.format(batch.expiryDate)
                                  : 'N/A',
                              subtitle: batch != null
                                  ? DateFormatter.daysRemainingText(batch.expiryDate)
                                  : null,
                              subtitleColor: isExpired
                                  ? AppColors.critical
                                  : (batch?.isExpiringSoon ?? false)
                                      ? AppColors.warning
                                      : AppColors.success,
                            ),
                            const SizedBox(height: 12),
                            _DetailRow(
                              icon: Icons.inventory_2_rounded,
                              label: 'Current Quantity',
                              value: '${item.quantity} ${item.unit}',
                            ),
                            const SizedBox(height: 12),
                            _DetailRow(
                              icon: Icons.place_rounded,
                              label: 'Storage Location',
                              value: item.location ?? 'Unspecified',
                            ),
                            if (batch?.manufacturer != null) ...[
                              const SizedBox(height: 12),
                              _DetailRow(
                                icon: Icons.business_rounded,
                                label: 'Manufacturer',
                                value: batch!.manufacturer!,
                              ),
                            ],
                            const SizedBox(height: 12),
                            _DetailRow(
                              icon: Icons.fingerprint_rounded,
                              label: 'Item Identifier (UUID)',
                              value: item.id,
                              isMono: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PackagePhotoScreen(item: item),
                            ),
                          );
                        },
                        icon: const Icon(Icons.photo_camera_rounded),
                        label: Text(item.imagePath != null ? 'View Package Photo' : 'Attach Photo'),
                      ),
                    ),
                    if (item.status != ItemStatus.split && !isRecalled) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SplitTraceScreen(parentItem: item),
                              ),
                            );
                          },
                          icon: const Icon(Icons.alt_route_rounded),
                          label: const Text('Split Item'),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  'Lineage & Portion Trace',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                if (parentItem != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.splitBg.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.split.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.arrow_upward_rounded, color: AppColors.split, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Derived from Parent Package',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.split,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Original Parent ID: ${parentItem.id}',
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.textSecondary),
                        ),
                        Text(
                          'Original Quantity: ${parentItem.quantity} ${parentItem.unit}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],

                if (childItems.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.account_tree_outlined, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Child Portions Created from this Pack',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...childItems.map(
                          (child) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.primaryLight),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Portion: ${child.quantity} ${child.unit}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Location: ${child.location ?? "Unspecified"}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MedicineDetailsScreen(itemId: child.id),
                                      ),
                                    );
                                  },
                                  child: const Text('View Portion'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (parentItem == null && childItems.isEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Text(
                      'This medicine is an original, un-split unit package. Splitting creates traceable child portions with identical batch identities.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                if (events.isNotEmpty) ...[
                  const Text(
                    'Item History Log',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...events.map(
                    (e) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.history_toggle_off_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  e.description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            DateFormatter.formatShort(e.createdAt),
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                const DisclaimerBanner(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color? subtitleColor;
  final bool isMono;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.subtitleColor,
    this.isMono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: isMono ? 'monospace' : null,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: subtitleColor ?? AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
