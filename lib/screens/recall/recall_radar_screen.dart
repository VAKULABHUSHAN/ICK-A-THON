import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medicine_batch.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/medicine_card.dart';
import '../medicine/medicine_details_screen.dart';

class RecallRadarScreen extends StatelessWidget {
  const RecallRadarScreen({super.key});

  void _showSimulateRecallDialog(BuildContext context, AppState state) {
    final activeBatches = state.inventory
        .map((i) => i.batch)
        .whereType<MedicineBatch>()
        .where((b) => !b.isRecalled)
        .toSet()
        .toList();

    if (activeBatches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All current inventory batches are already flagged as recalled!'),
        ),
      );
      return;
    }

    MedicineBatch selectedBatch = activeBatches.first;
    final reasonController = TextEditingController(
      text: 'Simulated FDA Recall: Safety testing failed for supplier active batch.',
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.science_rounded, color: AppColors.warning),
                  SizedBox(width: 8),
                  Text('Simulate Recall Action (Demo)'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warningBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'DEMO NOTICE: This action triggers a real backend repository update to flag the selected batch as RECALLED and update all derived portions.',
                        style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Select Batch to Recall:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedBatch.id,
                      items: activeBatches.map((b) {
                        return DropdownMenuItem(
                          value: b.id,
                          child: Text('${b.medicineName} (${b.batchNumber})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedBatch = activeBatches.firstWhere((b) => b.id == val);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reasonController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Recall Reason Notice'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.critical),
                  onPressed: () async {
                    Navigator.pop(context);
                    final success = await state.simulateBatchRecall(
                      selectedBatch.id,
                      reason: reasonController.text.trim(),
                    );
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Batch ${selectedBatch.batchNumber} flagged as RECALLED!'),
                          backgroundColor: AppColors.critical,
                        ),
                      );
                    }
                  },
                  child: const Text('Issue Simulated Recall'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        final recalledItems = state.inventory.where((i) => (i.batch?.isRecalled ?? false)).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Recall Radar'),
            actions: [
              TextButton.icon(
                onPressed: () => _showSimulateRecallDialog(context, state),
                icon: const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.critical),
                label: const Text(
                  'Simulate Recall',
                  style: TextStyle(color: AppColors.critical, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => state.refreshData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.criticalBg.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.critical.withOpacity(0.5), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.radar_rounded, color: AppColors.critical, size: 28),
                            SizedBox(width: 10),
                            Text(
                              'Batch Safety & Recall Radar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.critical,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Monitors recorded medicine inventory against batch recall warnings. Child portions split from recalled parent packages inherit recall warnings immediately.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recalled Inventory Items (${recalledItems.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showSimulateRecallDialog(context, state),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.critical,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        icon: const Icon(Icons.add_alert_rounded, size: 16),
                        label: const Text('Simulate Recall', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (recalledItems.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.verified_user_rounded, size: 48, color: AppColors.success),
                          SizedBox(height: 12),
                          Text(
                            'No Recalled Items Found',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'All active medicines and split portions in your inventory currently pass safety checks.',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ...recalledItems.map(
                      (item) => MedicineCard(
                        item: item,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MedicineDetailsScreen(itemId: item.id),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
