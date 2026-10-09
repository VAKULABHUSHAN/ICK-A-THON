import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_helpers.dart';
import '../medicine_details/medicine_details_screen.dart';

class AddMedicineScreen extends StatefulWidget {
  final String? prefilledFrontPhotoPath;

  const AddMedicineScreen({super.key, this.prefilledFrontPhotoPath});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _batchController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _totalQtyController = TextEditingController(text: '30');
  final _remainingQtyController = TextEditingController(text: '30');
  final _locationController = TextEditingController(text: 'Medicine Cabinet');
  final _notesController = TextEditingController();

  DateTime? _mfgDate;
  DateTime? _expiryDate;
  DateTime? _dateOpened;

  String _selectedUnit = 'tablets';
  String _selectedCategory = 'General';
  String? _selectedFamilyMemberId;

  String? _frontImagePath;
  String? _backImagePath;
  bool _isSaving = false;

  final List<String> _units = ['tablets', 'capsules', 'bottles', 'sachets', 'vials', 'other'];
  final List<String> _categories = ['General', 'Cardiology', 'Diabetes', 'Vitamins', 'Pain Relief', 'Antibiotics', 'Respiratory'];

  @override
  void initState() {
    super.initState();
    if (widget.prefilledFrontPhotoPath != null) {
      _frontImagePath = widget.prefilledFrontPhotoPath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _batchController.dispose();
    _manufacturerController.dispose();
    _totalQtyController.dispose();
    _remainingQtyController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(bool isFront, ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          if (isFront) {
            _frontImagePath = picked.path;
          } else {
            _backImagePath = picked.path;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick photo: ${e.toString()}'),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime? initial, Function(DateTime) onSelected) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  void _autofillSampleData(AppState state) {
    setState(() {
      _nameController.text = 'Paracetamol 500 mg';
      _batchController.text = 'PCT-7703';
      _manufacturerController.text = 'GSK Consumer Healthcare';
      _mfgDate = DateTime(2025, 2, 1);
      _expiryDate = DateTime(2027, 8, 30);
      _totalQtyController.text = '20';
      _remainingQtyController.text = '15';
      _selectedUnit = 'tablets';
      _selectedCategory = 'Pain Relief';
      _locationController.text = 'First Aid Box';
      _dateOpened = DateTime.now().subtract(const Duration(days: 5));
      _notesController.text = 'Take 1 tablet as needed for fever.';
      _frontImagePath = 'assets/images/app_icon.png';

      if (state.familyMembers.isNotEmpty) {
        _selectedFamilyMemberId = state.familyMembers.first.id;
      }
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an expiry date.'),
          backgroundColor: AppColors.critical,
        ),
      );
      return;
    }

    final totalQty = int.parse(_totalQtyController.text.trim());
    final remainingQty = int.parse(_remainingQtyController.text.trim());

    if (remainingQty > totalQty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remaining quantity cannot exceed total quantity.'),
          backgroundColor: AppColors.critical,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final appState = Provider.of<AppState>(context, listen: false);
    final newMed = await appState.addMedicine(
      name: _nameController.text.trim(),
      familyMemberId: _selectedFamilyMemberId,
      batchNumber: _batchController.text.trim().isNotEmpty ? _batchController.text.trim() : null,
      manufacturer: _manufacturerController.text.trim().isNotEmpty ? _manufacturerController.text.trim() : null,
      mfgDate: _mfgDate,
      expiryDate: _expiryDate!,
      totalQuantity: totalQty,
      remainingQuantity: remainingQty,
      unit: _selectedUnit,
      category: _selectedCategory,
      location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
      dateOpened: _dateOpened,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      imageFrontUrl: _frontImagePath,
      imageBackUrl: _backImagePath,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (newMed != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medicine saved successfully!'),
          backgroundColor: AppColors.normal,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MedicineDetailsScreen(medicineId: newMed.id),
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
    return Consumer<AppState>(
      builder: (context, state, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Add Medicine Record'),
            actions: [
              TextButton(
                onPressed: () => _autofillSampleData(state),
                child: const Text('Auto-fill Sample'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Useful Photo Tips Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.lavenderSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Photographing Tips',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          '• Use good lighting & avoid glare\n• Keep text in sharp focus\n• Capture batch number and expiry date clearly',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Front & Back Package Photos Row
                  Row(
                    children: [
                      Expanded(
                        child: _PhotoTile(
                          title: 'Front Package Photo',
                          imagePath: _frontImagePath,
                          onPickCamera: () => _pickPhoto(true, ImageSource.camera),
                          onPickGallery: () => _pickPhoto(true, ImageSource.gallery),
                          onRemove: () => setState(() => _frontImagePath = null),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PhotoTile(
                          title: 'Back Package Photo',
                          imagePath: _backImagePath,
                          onPickCamera: () => _pickPhoto(false, ImageSource.camera),
                          onPickGallery: () => _pickPhoto(false, ImageSource.gallery),
                          onRemove: () => setState(() => _backImagePath = null),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    '1. Basic Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  // Medicine Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Medicine Name *',
                      hintText: 'e.g., Amlodipine 5 mg',
                      prefixIcon: Icon(Icons.medication_outlined),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Medicine name is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Batch Number & Manufacturer Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _batchController,
                          decoration: const InputDecoration(
                            labelText: 'Batch Number',
                            hintText: 'e.g., AML-8823',
                            prefixIcon: Icon(Icons.tag_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _manufacturerController,
                          decoration: const InputDecoration(
                            labelText: 'Manufacturer',
                            hintText: 'e.g., Pfizer',
                            prefixIcon: Icon(Icons.business_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    '2. Family Allocation & Category',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  // Family Member & Category Dropdowns Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedFamilyMemberId,
                          decoration: const InputDecoration(
                            labelText: 'Assigned Member',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          hint: const Text('Select Member'),
                          items: state.familyMembers.map((m) {
                            return DropdownMenuItem(
                              value: m.id,
                              child: Text(m.name),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedFamilyMemberId = val),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items: _categories.map((cat) {
                            return DropdownMenuItem(value: cat, child: Text(cat));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    '3. Quantities & Dates',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  // Quantity Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _totalQtyController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Total Pack Qty *',
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                          ),
                          validator: (val) {
                            final parsed = int.tryParse(val ?? '');
                            if (parsed == null || parsed <= 0) return 'Must be > 0';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _remainingQtyController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Remaining Qty *',
                            prefixIcon: Icon(Icons.pin_outlined),
                          ),
                          validator: (val) {
                            final parsed = int.tryParse(val ?? '');
                            if (parsed == null || parsed < 0) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedUnit,
                          decoration: const InputDecoration(labelText: 'Unit'),
                          items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedUnit = val);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Date Pickers Row
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, _mfgDate, (d) => setState(() => _mfgDate = d)),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Mfg Date (Optional)',
                              prefixIcon: Icon(Icons.calendar_today_outlined),
                            ),
                            child: Text(
                              _mfgDate != null ? DateHelpers.format(_mfgDate!) : 'Select Date',
                              style: TextStyle(color: _mfgDate != null ? AppColors.textPrimary : AppColors.textMuted, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, _expiryDate, (d) => setState(() => _expiryDate = d)),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Expiry Date *',
                              prefixIcon: Icon(Icons.event_outlined),
                            ),
                            child: Text(
                              _expiryDate != null ? DateHelpers.format(_expiryDate!) : 'Select Date',
                              style: TextStyle(color: _expiryDate != null ? AppColors.textPrimary : AppColors.textMuted, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Storage Location & Date Opened Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Storage Location',
                            hintText: 'e.g. Grandma Room Shelf',
                            prefixIcon: Icon(Icons.place_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, _dateOpened, (d) => setState(() => _dateOpened = d)),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date Opened',
                              prefixIcon: Icon(Icons.lock_open_rounded),
                            ),
                            child: Text(
                              _dateOpened != null ? DateHelpers.format(_dateOpened!) : 'Select Date',
                              style: TextStyle(color: _dateOpened != null ? AppColors.textPrimary : AppColors.textMuted, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Notes Field
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Dosage Instructions & Notes',
                      hintText: 'e.g. Take 1 tablet daily after breakfast with warm water',
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _submitForm,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Verify & Save Medicine'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final String title;
  final String? imagePath;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final VoidCallback onRemove;

  const _PhotoTile({
    required this.title,
    this.imagePath,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Container(
          height: 130,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imagePath != null && imagePath!.isNotEmpty
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      imagePath!.startsWith('assets/')
                          ? Image.asset(imagePath!, fit: BoxFit.cover)
                          : Image.file(File(imagePath!), fit: BoxFit.cover),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                            onPressed: onRemove,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                        tooltip: 'Camera',
                        onPressed: onPickCamera,
                      ),
                      IconButton(
                        icon: const Icon(Icons.photo_library_rounded, color: AppColors.primaryLight),
                        tooltip: 'Gallery',
                        onPressed: onPickGallery,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
