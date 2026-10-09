import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/medicine_card.dart';
import '../medicine_details/medicine_details_screen.dart';

enum AlertFilter { all, expiring, lowStock, opened }

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  AlertFilter _selectedFilter = AlertFilter.all;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        final allAlerts = state.alertMedicines;

        final filteredAlerts = allAlerts.where((m) {
          switch (_selectedFilter) {
            case AlertFilter.all:
              return true;
            case AlertFilter.expiring:
              return m.isExpired || m.isExpiringSoon;
            case AlertFilter.lowStock:
              return m.isLowStock;
            case AlertFilter.opened:
              return m.isOpenedForLongTime;
          }
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Alerts & Reminders'),
          ),
          body: RefreshIndicator(
            onRefresh: () => state.refreshData(),
            child: Column(
              children: [
                // Filter Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.surface,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChipItem(
                          label: 'All Alerts (${allAlerts.length})',
                          isSelected: _selectedFilter == AlertFilter.all,
                          onSelected: () => setState(() => _selectedFilter = AlertFilter.all),
                        ),
                        const SizedBox(width: 8),
                        _FilterChipItem(
                          label: 'Expiring (${state.expiringSoonCount + state.expiredCount})',
                          isSelected: _selectedFilter == AlertFilter.expiring,
                          onSelected: () => setState(() => _selectedFilter = AlertFilter.expiring),
                          activeColor: AppColors.expiringSoon,
                        ),
                        const SizedBox(width: 8),
                        _FilterChipItem(
                          label: 'Low Stock (${state.lowStockCount})',
                          isSelected: _selectedFilter == AlertFilter.lowStock,
                          onSelected: () => setState(() => _selectedFilter = AlertFilter.lowStock),
                          activeColor: AppColors.lowStock,
                        ),
                        const SizedBox(width: 8),
                        _FilterChipItem(
                          label: 'Opened >60d',
                          isSelected: _selectedFilter == AlertFilter.opened,
                          onSelected: () => setState(() => _selectedFilter = AlertFilter.opened),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.cardBorder),

                // Alerts List View
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredAlerts.isEmpty
                          ? ListView(
                              padding: const EdgeInsets.all(32),
                              children: const [
                                SizedBox(height: 60),
                                Icon(Icons.notifications_active_outlined, size: 64, color: AppColors.normal),
                                SizedBox(height: 16),
                                Text(
                                  'No Active Alerts',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'All family medicine records pass expiry and inventory thresholds.',
                                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredAlerts.length,
                              itemBuilder: (context, index) {
                                final med = filteredAlerts[index];
                                return MedicineCard(
                                  medicine: med,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MedicineDetailsScreen(medicineId: med.id),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final Color? activeColor;

  const _FilterChipItem({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.primary;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: color.withValues(alpha: 0.15),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? color : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? color : AppColors.cardBorder,
        width: isSelected ? 1.5 : 1.0,
      ),
      showCheckmark: false,
    );
  }
}
