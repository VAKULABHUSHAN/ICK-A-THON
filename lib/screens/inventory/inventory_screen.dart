import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/medicine_card.dart';
import '../medicine/add_medicine_screen.dart';
import '../medicine/medicine_details_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        final filteredList = state.filteredInventory;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Medicine Inventory'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Add Medicine',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddMedicineScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => state.refreshData(),
            child: Column(
              children: [
                // Search & Filters Header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.surface,
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: (val) => state.setSearchQuery(val),
                        decoration: InputDecoration(
                          hintText: 'Search by medicine name, batch #, location...',
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    state.setSearchQuery('');
                                  },
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChipItem(
                              label: 'All (${state.inventory.length})',
                              isSelected: state.selectedFilter == InventoryFilter.all,
                              onSelected: () => state.setFilter(InventoryFilter.all),
                            ),
                            const SizedBox(width: 8),
                            _FilterChipItem(
                              label: 'Expiring Soon (${state.expiringSoonCount})',
                              isSelected: state.selectedFilter == InventoryFilter.expiringSoon,
                              onSelected: () => state.setFilter(InventoryFilter.expiringSoon),
                              activeColor: AppColors.warning,
                            ),
                            const SizedBox(width: 8),
                            _FilterChipItem(
                              label: 'Expired (${state.expiredCount})',
                              isSelected: state.selectedFilter == InventoryFilter.expired,
                              onSelected: () => state.setFilter(InventoryFilter.expired),
                              activeColor: AppColors.critical,
                            ),
                            const SizedBox(width: 8),
                            _FilterChipItem(
                              label: 'Recalled (${state.recalledCount})',
                              isSelected: state.selectedFilter == InventoryFilter.recalled,
                              onSelected: () => state.setFilter(InventoryFilter.recalled),
                              activeColor: AppColors.critical,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.cardBorder),

                // Inventory List View
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredList.isEmpty
                          ? ListView(
                              padding: const EdgeInsets.all(32),
                              children: [
                                const SizedBox(height: 40),
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: AppColors.textMuted.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.searchQuery.isNotEmpty
                                      ? 'No medicines match "${state.searchQuery}"'
                                      : 'No medicine items found',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Add your first medicine strip, bottle, or pack to start tracking identity and expiry.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                Center(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const AddMedicineScreen(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.add_rounded),
                                    label: const Text('Add Medicine Record'),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final item = filteredList[index];
                                return MedicineCard(
                                  item: item,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MedicineDetailsScreen(itemId: item.id),
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
          floatingActionButton: FloatingActionButton.extended(
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
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
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
    final themeColor = activeColor ?? AppColors.primary;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: themeColor.withOpacity(0.15),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? themeColor : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? themeColor : AppColors.cardBorder,
        width: isSelected ? 1.5 : 1.0,
      ),
      showCheckmark: false,
    );
  }
}
