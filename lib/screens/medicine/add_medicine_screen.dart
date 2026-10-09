import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_formatter.dart';
import 'medicine_details_screen.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _batchController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _quantityController = TextEditingController(text: '10');
  final _locationController = TextEditingController(text: 'Medicine Cabinet');

  DateTime? _selectedExpiryDate;
  String _selectedUnit = 'tablets';
  String? _capturedImagePath;
  bool _isSaving = false;

  final List<String> _units = ['tablets', 'capsules', 'bottles', 'sachets', 'vials', 'other'];

  @override
  void dispose() {
    _nameController.dispose();
    _batchController.dispose();
    _manufacturerController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? now.add(const Duration(days: 365)),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
      });
    }
  }

  Future<void> _pickPackagePhoto(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          _capturedImagePath = picked.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture photo: ${e.toString()}'),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    }
  }

  void _showPhotoOptionsModal() {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Attach Package Photo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.accentSoft,
                    child: Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                  ),
                  title: const Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickPackagePhoto(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.infoBg,
                    child: Icon(Icons.photo_library_rounded, color: AppColors.info),
                  ),
                  title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickPackagePhoto(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.warningBg,
                    child: Icon(Icons.flash_on_rounded, color: AppColors.warning),
                  ),
                  title: const Text('Auto-fill Sample Paracetamol Strip', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Batch: PCT-7703 · Exp: 2028-06-30'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _nameController.text = 'Paracetamol 500mg Strip';
                      _batchController.text = 'PCT-7703';
                      _manufacturerController.text = 'GlaxoSmithKline';
                      _selectedExpiryDate = DateTime(2028, 6, 30);
                      _quantityController.text = '10';
                      _selectedUnit = 'tablets';
                      _locationController.text = 'First Aid Kit';
                      _capturedImagePath = 'assets/images/app_icon.png';
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an expiry date.'),
          backgroundColor: AppColors.critical,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final appState = Provider.of<AppState>(context, listen: false);
    final newItem = await appState.addMedicine(
      medicineName: _nameController.text.trim(),
      batchNumber: _batchController.text.trim(),
      expiryDate: _selectedExpiryDate!,
      manufacturer: _manufacturerController.text.trim().isNotEmpty
          ? _manufacturerController.text.trim()
          : null,
      quantity: int.parse(_quantityController.text.trim()),
      unit: _selectedUnit,
      location: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : null,
      imagePath: _capturedImagePath,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (newItem != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medicine registered successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MedicineDetailsScreen(itemId: newItem.id),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.errorMessage ?? 'Failed to save record.'),
          backgroundColor: AppColors.critical,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine Record'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Picker Container Preview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    if (_capturedImagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          color: AppColors.background,
                          child: _capturedImagePath!.startsWith('assets/')
                              ? Image.asset(_capturedImagePath!, fit: BoxFit.cover)
                              : Image.file(File(_capturedImagePath!), fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.accentSoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _capturedImagePath != null ? 'Package Photo Attached' : 'Package Photo',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                _capturedImagePath != null ? 'Tap to change package photo' : 'Capture box/strip photo or choose from gallery.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: _showPhotoOptionsModal,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text(_capturedImagePath != null ? 'Change' : 'Pick Photo', style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Medicine Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name *',
                  hintText: 'e.g., Amoxicillin 500mg Strip',
                  prefixIcon: Icon(Icons.medication_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _batchController,
                      decoration: const InputDecoration(
                        labelText: 'Batch Number *',
                        hintText: 'e.g., B23184',
                        prefixIcon: Icon(Icons.tag_rounded),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Batch # required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickExpiryDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Expiry Date *',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(
                          _selectedExpiryDate != null
                              ? DateFormatter.format(_selectedExpiryDate!)
                              : 'Select Date',
                          style: TextStyle(
                            color: _selectedExpiryDate != null
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _manufacturerController,
                decoration: const InputDecoration(
                  labelText: 'Manufacturer (Optional)',
                  hintText: 'e.g., Apex Pharmaceuticals',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Portion & Storage',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity *',
                        hintText: 'e.g., 10',
                        prefixIcon: Icon(Icons.numbers_rounded),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Required';
                        }
                        final parsed = int.tryParse(val.trim());
                        if (parsed == null || parsed <= 0) {
                          return 'Must be > 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit *',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _units.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedUnit = val;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Storage Location',
                  hintText: 'e.g., Kitchen Shelf B / First Aid Kit',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submitForm,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save & Register Identity'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
