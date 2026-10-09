import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medicine.dart';
import '../../models/medicine_history.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_helpers.dart';
import '../../widgets/status_badge.dart';

class MedicineDetailsScreen extends StatefulWidget {
  final String medicineId;

  const MedicineDetailsScreen({super.key, required this.medicineId});

  @override
  State<MedicineDetailsScreen> createState() => _MedicineDetailsScreenState();
}

class _MedicineDetailsScreenState extends State<MedicineDetailsScreen> {
  void _showMarkAsTakenModal(Medicine med, AppState state) {
    final qtyController = TextEditingController(text: '1');
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Record Dose Consumption',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Record consumed dose for ${med.name}. Current remaining: ${med.remainingQuantity} ${med.unit}.',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Dose Quantity (${med.unit}) *',
                  prefixIcon: const Icon(Icons.numbers_rounded),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'e.g. Taken with morning meal',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final qty = int.tryParse(qtyController.text.trim());
                    if (qty == null || qty <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter a valid quantity > 0')),
                      );
                      return;
                    }
                    if (qty > med.remainingQuantity) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cannot consume more than remaining stock (${med.remainingQuantity})')),
                      );
                      return;
                    }

                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);
                    final success = await state.markMedicineAsTaken(
                      med.id,
                      qty,
                      notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                    );

                    if (mounted && success) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Logged $qty ${med.unit} dose consumed!'),
                          backgroundColor: AppColors.normal,
                        ),
                      );
                    }
                  },
                  child: const Text('Confirm & Log Consumption'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(Medicine med, AppState state) {
    final remController = TextEditingController(text: med.remainingQuantity.toString());
    final locController = TextEditingController(text: med.location ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Medicine Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: remController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Remaining Quantity'),
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
                final qty = int.tryParse(remController.text.trim());
                final loc = locController.text.trim();
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);

                final success = await state.updateMedicine(
                  med.id,
                  remainingQuantity: qty,
                  location: loc,
                );

                if (mounted && success) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Medicine record updated!'), backgroundColor: AppColors.normal),
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
        final medicine = state.medicines.firstWhere(
          (m) => m.id == widget.medicineId,
          orElse: () => Medicine(
            id: widget.medicineId,
            name: 'Medicine',
            expiryDate: DateTime.now(),
            totalQuantity: 1,
            remainingQuantity: 1,
          ),
        );

        final member = medicine.familyMember;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Medicine Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Details',
                onPressed: () => _showEditDialog(medicine, state),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      if (medicine.imageFrontUrl != null && medicine.imageFrontUrl!.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: medicine.imageFrontUrl!.startsWith('assets/')
                                ? Image.asset(medicine.imageFrontUrl!, fit: BoxFit.cover)
                                : Image.file(
                                    File(medicine.imageFrontUrl!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      color: AppColors.lavenderSoft,
                                      child: const Icon(Icons.medication_rounded, size: 64, color: AppColors.primary),
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
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        medicine.name,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Category: ${medicine.category} · Batch: ${medicine.batchNumber ?? "N/A"}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge.forMedicine(medicine),
                              ],
                            ),

                            const SizedBox(height: 16),
                            const Divider(height: 1, color: AppColors.cardBorder),
                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Remaining Quantity: ${medicine.remainingQuantity} / ${medicine.totalQuantity} ${medicine.unit}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                ),
                                Text(
                                  '${(medicine.stockProgress * 100).toInt()}%',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: medicine.stockProgress,
                                backgroundColor: AppColors.lavenderSoft,
                                color: medicine.isLowStock ? AppColors.lowStock : AppColors.primary,
                                minHeight: 8,
                              ),
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
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: medicine.remainingQuantity > 0
                            ? () => _showMarkAsTakenModal(medicine, state)
                            : null,
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('Mark as Taken'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showEditDialog(medicine, state),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  'Record Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Assigned Family Member',
                        value: member?.name ?? 'Unassigned',
                        subtitle: member?.relation,
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        icon: Icons.event_outlined,
                        label: 'Recorded Expiry Date',
                        value: DateHelpers.format(medicine.expiryDate),
                        subtitle: DateHelpers.daysRemainingText(medicine.expiryDate),
                        subtitleColor: medicine.isExpired
                            ? AppColors.critical
                            : medicine.isExpiringSoon
                                ? AppColors.expiringSoon
                                : AppColors.normal,
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        icon: Icons.place_outlined,
                        label: 'Storage Location',
                        value: medicine.location ?? 'Unspecified',
                      ),
                      if (medicine.manufacturer != null) ...[
                        const SizedBox(height: 12),
                        _DetailRow(
                          icon: Icons.business_outlined,
                          label: 'Manufacturer',
                          value: medicine.manufacturer!,
                        ),
                      ],
                      if (medicine.mfgDate != null) ...[
                        const SizedBox(height: 12),
                        _DetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Manufacturing Date',
                          value: DateHelpers.format(medicine.mfgDate!),
                        ),
                      ],
                      if (medicine.dateOpened != null) ...[
                        const SizedBox(height: 12),
                        _DetailRow(
                          icon: Icons.lock_open_rounded,
                          label: 'Date Opened',
                          value: DateHelpers.format(medicine.dateOpened!),
                        ),
                      ],
                      if (medicine.notes != null && medicine.notes!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _DetailRow(
                          icon: Icons.notes_rounded,
                          label: 'Dosage & Notes',
                          value: medicine.notes!,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                FutureBuilder<List<MedicineHistory>>(
                  future: state.getMedicineHistory(medicine.id),
                  builder: (context, snapshot) {
                    final logs = snapshot.data ?? [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Consumption & Activity Log',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        if (logs.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: const Text('No consumption history recorded yet.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          )
                        else
                          ...logs.map(
                            (log) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: log.eventType == 'taken' ? AppColors.lavenderSoft : AppColors.normalBg,
                                    child: Icon(
                                      log.eventType == 'taken' ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                                      size: 16,
                                      color: log.eventType == 'taken' ? AppColors.primary : AppColors.normal,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(log.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                        Text(log.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  Text(DateHelpers.formatShort(log.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.infoBg.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline_rounded, size: 16, color: AppColors.info),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Notice: This feature records user-entered medicine consumption and stock tracking only.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
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

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.subtitleColor,
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
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: subtitleColor ?? AppColors.textSecondary),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
