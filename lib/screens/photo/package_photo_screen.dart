import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/medicine_item.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../medicine/medicine_details_screen.dart';

class PackagePhotoScreen extends StatefulWidget {
  final MedicineItem? item;

  const PackagePhotoScreen({super.key, this.item});

  @override
  State<PackagePhotoScreen> createState() => _PackagePhotoScreenState();
}

class _PackagePhotoScreenState extends State<PackagePhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.item?.imagePath != null && widget.item!.imagePath!.isNotEmpty) {
      if (!widget.item!.imagePath!.startsWith('assets/')) {
        _imageFile = File(widget.item!.imagePath!);
      }
    }
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
          _imageFile = File(picked.path);
        });

        if (widget.item != null) {
          setState(() {
            _isSaving = true;
          });
          final appState = Provider.of<AppState>(context, listen: false);
          await appState.updateMedicineItem(
            widget.item!.id,
            imagePath: picked.path,
          );
          if (mounted) {
            setState(() {
              _isSaving = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Package photo updated successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    }
  }

  void _showSourceSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Photo Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.accentSoft,
                    child: Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                  ),
                  title: const Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Capture tablet strip or box photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.infoBg,
                    child: Icon(Icons.photo_library_rounded, color: AppColors.info),
                  ),
                  title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Select saved packaging photo from device'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        final item = widget.item != null
            ? state.inventory.firstWhere(
                (i) => i.id == widget.item!.id,
                orElse: () => widget.item!,
              )
            : null;

        final imagePath = item?.imagePath ?? _imageFile?.path;

        return Scaffold(
          appBar: AppBar(
            title: Text(item != null ? 'Package Photo - ${item.batch?.medicineName ?? "Item"}' : 'Capture Package Photo'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_a_photo_rounded),
                tooltip: 'Change Photo',
                onPressed: _showSourceSelection,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 280, maxHeight: 420),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.cardBorder, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _isSaving
                        ? const Center(child: CircularProgressIndicator())
                        : imagePath != null && imagePath.isNotEmpty
                            ? (imagePath.startsWith('assets/')
                                ? Image.asset(
                                    imagePath,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : Image.file(
                                    File(imagePath),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (ctx, err, stack) => const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image_rounded, size: 48, color: AppColors.textMuted),
                                          SizedBox(height: 8),
                                          Text('Image file not found', style: TextStyle(color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ),
                                  ))
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: AppColors.accentSoft,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_outlined,
                                      size: 56,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No Package Photo Captured',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Store a photo of the original medicine box or strip for visual verification.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showSourceSelection,
                        icon: const Icon(Icons.camera_alt_rounded),
                        label: Text(imagePath != null ? 'Retake Photo' : 'Capture Photo'),
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

                if (item != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.batch?.medicineName ?? 'Medicine Info',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Batch: ${item.batch?.batchNumber ?? "N/A"} · Qty: ${item.quantity} ${item.unit}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        Text(
                          'Location: ${item.location ?? "Unspecified"}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MedicineDetailsScreen(itemId: item.id),
                                ),
                              );
                            },
                            child: const Text('View Full Medicine Details'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                if (item == null && state.inventory.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Medicine Item to Attach Photo:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...state.inventory.take(4).map(
                        (i) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.medication_rounded, color: AppColors.primary),
                            title: Text(i.batch?.medicineName ?? 'Medicine', style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text('Batch ${i.batch?.batchNumber} · ${i.quantity} ${i.unit}'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PackagePhotoScreen(item: i),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
