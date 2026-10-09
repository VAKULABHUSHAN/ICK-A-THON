import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/chain_logo.dart';
import '../../widgets/family_avatar.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/medicine_card.dart';
import '../medicine_details/medicine_details_screen.dart';
import '../add_medicine/add_medicine_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        final groupedMedicines = state.medicinesGroupedByFamily;

        return Scaffold(
          appBar: AppBar(
            title: const ChainLogo(size: 32, showTagline: true),
            actions: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 26),
                    tooltip: 'Alerts',
                    onPressed: () => onNavigateTab(3),
                  ),
                  if (state.alertMedicines.isNotEmpty)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: AppColors.lowStock,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  avatar: Icon(
                    state.isMockMode ? Icons.data_array : Icons.cloud_done,
                    size: 14,
                    color: state.isMockMode ? AppColors.expiringSoon : AppColors.normal,
                  ),
                  label: Text(
                    state.isMockMode ? 'MOCK' : 'SUPABASE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: state.isMockMode ? AppColors.expiringSoon : AppColors.normal,
                    ),
                  ),
                  onSelected: (_) => state.toggleMode(!state.isMockMode),
                  backgroundColor: state.isMockMode ? AppColors.expiringSoonBg : AppColors.normalBg,
                  side: BorderSide(
                    color: state.isMockMode ? AppColors.expiringSoon : AppColors.normal,
                  ),
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
                  Text(
                    'Good morning 👋',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Family Medicine Cabinet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  InkWell(
                    onTap: () => onNavigateTab(1),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Search medicines by name, batch...',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.lavenderSoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Family Members',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => onNavigateTab(4),
                        child: const Text('Manage'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FamilyAvatar(
                          member: null,
                          isSelected: state.selectedFamilyMemberId == null,
                          onTap: () => state.setSelectedFamilyMember(null),
                        ),
                        const SizedBox(width: 14),
                        ...state.familyMembers.map(
                          (member) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: FamilyAvatar(
                              member: member,
                              isSelected: state.selectedFamilyMemberId == member.id,
                              onTap: () => state.setSelectedFamilyMember(member.id),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Active Meds',
                          count: state.totalActiveMedicines,
                          icon: Icons.medication_rounded,
                          color: AppColors.primary,
                          bgColor: AppColors.lavenderSoft,
                          onTap: () => state.setSelectedFamilyMember(null),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SummaryCard(
                          title: 'Expiring Soon',
                          count: state.expiringSoonCount,
                          icon: Icons.alarm_rounded,
                          color: AppColors.expiringSoon,
                          bgColor: AppColors.expiringSoonBg,
                          onTap: () => onNavigateTab(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SummaryCard(
                          title: 'Low Stock',
                          count: state.lowStockCount,
                          icon: Icons.inventory_2_outlined,
                          color: AppColors.lowStock,
                          bgColor: AppColors.lowStockBg,
                          onTap: () => onNavigateTab(3),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.filteredMedicines.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 56, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          const Text(
                            'No Medicines Recorded',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Add your first medicine package to start tracking expiry and family allocation.',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddMedicineScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add Medicine'),
                          ),
                        ],
                      ),
                    )
                  else if (state.selectedFamilyMemberId != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${state.familyMembers.firstWhere((f) => f.id == state.selectedFamilyMemberId).name}\'s Medicines',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => state.setSelectedFamilyMember(null),
                          child: const Text('Show All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...state.filteredMedicines.map(
                      (med) => MedicineCard(
                        medicine: med,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MedicineDetailsScreen(medicineId: med.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    ...groupedMedicines.entries.map((entry) {
                      final member = entry.key;
                      final meds = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: member.avatarBgColor,
                                    child: Icon(member.defaultIcon, size: 14, color: Colors.white),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${member.name}\'s Medicines',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () => state.setSelectedFamilyMember(member.id),
                                child: const Text('See all'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...meds.map(
                            (med) => MedicineCard(
                              medicine: med,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MedicineDetailsScreen(medicineId: med.id),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
