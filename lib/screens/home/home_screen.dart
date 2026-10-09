import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/chain_logo.dart';
import '../../widgets/medicine_card.dart';
import '../../widgets/disclaimer_banner.dart';
import '../medicine/add_medicine_screen.dart';
import '../medicine/medicine_details_screen.dart';
import '../photo/package_photo_screen.dart';
import '../split/split_trace_screen.dart';
import '../recall/recall_radar_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        return Scaffold(
          appBar: AppBar(
            title: const ChainLogo(size: 32, showTagline: true),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  avatar: Icon(
                    state.isMockMode ? Icons.data_array : Icons.cloud_done,
                    size: 14,
                    color: state.isMockMode ? AppColors.warning : AppColors.success,
                  ),
                  label: Text(
                    state.isMockMode ? 'MOCK' : 'SUPABASE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: state.isMockMode ? AppColors.warning : AppColors.success,
                    ),
                  ),
                  onSelected: (val) {
                    state.toggleMode(!state.isMockMode);
                  },
                  backgroundColor: state.isMockMode ? AppColors.warningBg : AppColors.successBg,
                  side: BorderSide(
                    color: state.isMockMode ? AppColors.warning : AppColors.success,
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
                  const DisclaimerBanner(compact: true),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x20005F73),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Medicine Guardian',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ICK-A-THON 2026 MVP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Preserve Medicine Identity',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Split strips into custom portions without losing batch history, expiry, or recall status.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Inventory Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          title: 'Active Items',
                          count: state.totalActiveItems,
                          icon: Icons.inventory_2_rounded,
                          color: AppColors.primary,
                          bgColor: AppColors.accentSoft,
                          onTap: () => onNavigateTab(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          title: 'Expiring Soon',
                          count: state.expiringSoonCount,
                          icon: Icons.alarm_rounded,
                          color: AppColors.warning,
                          bgColor: AppColors.warningBg,
                          onTap: () {
                            state.setFilter(InventoryFilter.expiringSoon);
                            onNavigateTab(1);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          title: 'Expired Items',
                          count: state.expiredCount,
                          icon: Icons.event_busy_rounded,
                          color: AppColors.critical,
                          bgColor: AppColors.criticalBg.withOpacity(0.5),
                          onTap: () {
                            state.setFilter(InventoryFilter.expired);
                            onNavigateTab(1);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          title: 'Recalled Batches',
                          count: state.recalledCount,
                          icon: Icons.warning_amber_rounded,
                          color: AppColors.critical,
                          bgColor: AppColors.criticalBg,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RecallRadarScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'Add Medicine',
                          color: AppColors.primary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddMedicineScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.camera_alt_rounded,
                          label: 'Capture Photo',
                          color: AppColors.primaryLight,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PackagePhotoScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.alt_route_rounded,
                          label: 'Split & Trace',
                          color: AppColors.split,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SplitTraceScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.radar_rounded,
                          label: 'Recall Radar',
                          color: AppColors.critical,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RecallRadarScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Next Upcoming Expiries',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => onNavigateTab(1),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.upcomingExpiryItems.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Center(
                        child: Text(
                          'No active items found.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...state.upcomingExpiryItems.map(
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

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recently Added',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => onNavigateTab(1),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (state.recentlyAddedItems.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Center(
                        child: Text(
                          'No recently added items.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...state.recentlyAddedItems.map(
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

class _MetricCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _MetricCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: color.withOpacity(0.12),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
