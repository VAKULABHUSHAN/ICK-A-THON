import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/medicine_card.dart';
import '../medicine_details/medicine_details_screen.dart';
import '../add_medicine/add_medicine_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _searchImage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          _searchImage = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: ${e.toString()}'),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Search Inventory'),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
              tabs: const [
                Tab(icon: Icon(Icons.search_rounded), text: 'Text Search'),
                Tab(icon: Icon(Icons.camera_alt_outlined), text: 'Image Identification'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Text Search
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppColors.surface,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => state.setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: 'Search by medicine name, batch #, manufacturer...',
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
                  ),
                  const Divider(height: 1, color: AppColors.cardBorder),
                  Expanded(
                    child: state.filteredMedicines.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  const Icon(Icons.search_off_rounded, size: 56, color: AppColors.textMuted),
                                  const SizedBox(height: 12),
                                  Text(
                                    state.searchQuery.isNotEmpty
                                        ? 'No medicines match "${state.searchQuery}"'
                                        : 'Search Family Medicine Inventory',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Search by drug name, batch number, or category to find active doses.',
                                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.filteredMedicines.length,
                            itemBuilder: (context, index) {
                              final med = state.filteredMedicines[index];
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

              // Tab 2: Image Search / Packaging Photo Identification
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lavenderSoft,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.center_focus_strong_rounded, color: AppColors.primary, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Packaging Visual Search',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Photograph front/back of tablet strip or box. Review image text and match with recorded family medicines.',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Image Display Frame
                    Container(
                      width: double.infinity,
                      height: 240,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder, width: 1.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _searchImage != null
                            ? Image.file(_searchImage!, fit: BoxFit.cover)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_a_photo_outlined, size: 48, color: AppColors.primary),
                                  SizedBox(height: 12),
                                  Text(
                                    'No Photo Selected',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                  ),
                                  SizedBox(height: 4),
                                  Text('Capture packaging or pick from gallery', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_rounded),
                            label: Text(_searchImage != null ? 'Retake Photo' : 'Take Photo'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_rounded),
                            label: const Text('Gallery'),
                          ),
                        ),
                      ],
                    ),

                    if (_searchImage != null) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Matched Inventory Records',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 10),
                      ...state.medicines.take(3).map(
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
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddMedicineScreen(prefilledFrontPhotoPath: _searchImage!.path),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline_rounded),
                          label: const Text('Create New Record with this Photo'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
