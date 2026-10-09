import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medicine_item.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../photo/package_photo_screen.dart';

class SplitTraceScreen extends StatefulWidget {
  final MedicineItem? parentItem;

  const SplitTraceScreen({super.key, this.parentItem});

  @override
  State<SplitTraceScreen> createState() => _SplitTraceScreenState();
}

class _SplitTraceScreenState extends State<SplitTraceScreen> {
  MedicineItem? _selectedParent;

  final _formKey = GlobalKey<FormState>();
  final _qtyAController = TextEditingController();
  final _qtyBController = TextEditingController();
  final _locAController = TextEditingController();
  final _locBController = TextEditingController();

  bool _isProcessing = false;
  List<MedicineItem>? _createdChildren;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _selectedParent = widget.parentItem;
    if (_selectedParent != null) {
      _presetDefaultSplit(_selectedParent!);
    }
  }

  void _presetDefaultSplit(MedicineItem parent) {
    final half = (parent.quantity / 2).floor();
    final remainder = parent.quantity - half;

    _qtyAController.text = half > 0 ? half.toString() : '1';
    _qtyBController.text = remainder > 0 ? remainder.toString() : '1';
    _locAController.text = '${parent.location ?? "Main Cabinet"} (Portion A)';
    _locBController.text = '${parent.location ?? "Travel Pack"} (Portion B)';
    _validateInputs();
  }

  @override
  void dispose() {
    _qtyAController.dispose();
    _qtyBController.dispose();
    _locAController.dispose();
    _locBController.dispose();
    super.dispose();
  }

  void _validateInputs() {
    if (_selectedParent == null) {
      setState(() => _validationError = 'Please select a parent medicine pack.');
      return;
    }

    final qtyA = int.tryParse(_qtyAController.text.trim()) ?? 0;
    final qtyB = int.tryParse(_qtyBController.text.trim()) ?? 0;

    if (qtyA <= 0 || qtyB <= 0) {
      setState(() => _validationError = 'Portion quantities must be positive integers (> 0).');
      return;
    }

    final total = qtyA + qtyB;
    if (total != _selectedParent!.quantity) {
      setState(() => _validationError =
          'Sum of portions ($total) does not match parent total (${_selectedParent!.quantity}).');
      return;
    }

    setState(() => _validationError = null);
  }

  Future<void> _executeSplit() async {
    _validateInputs();
    if (_validationError != null) return;
    if (_selectedParent == null) return;

    setState(() {
      _isProcessing = true;
    });

    final qtyA = int.parse(_qtyAController.text.trim());
    final qtyB = int.parse(_qtyBController.text.trim());
    final locA = _locAController.text.trim();
    final locB = _locBController.text.trim();

    final appState = Provider.of<AppState>(context, listen: false);
    final results = await appState.splitItem(
      parentItemId: _selectedParent!.id,
      quantityA: qtyA,
      quantityB: qtyB,
      locationA: locA,
      locationB: locB,
    );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (results != null && results.length == 2) {
      setState(() {
        _createdChildren = results;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Split & Trace execution successful! Identities derived.'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.errorMessage ?? 'Split execution failed.'),
          backgroundColor: AppColors.critical,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        final eligibleParents = state.inventory
            .where((i) => i.status == ItemStatus.active && !(i.batch?.isRecalled ?? false))
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Split & Trace Lineage'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _createdChildren != null
                ? _buildSuccessView(_createdChildren!)
                : Form(
                    key: _formKey,
                    onChanged: _validateInputs,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.splitBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.split.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.alt_route_rounded, color: AppColors.split, size: 22),
                                  SizedBox(width: 8),
                                  Text(
                                    'Atomic Portion Splitting',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.split,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'When separating tablets or strips into two places (e.g. 4 tablets in pouch, 6 tablets at home), both child portions inherit the exact batch number, expiry date, manufacturer, and recall status.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          '1. Select Active Parent Item',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),

                        DropdownButtonFormField<String>(
                          value: _selectedParent?.id,
                          decoration: const InputDecoration(
                            labelText: 'Parent Medicine Package *',
                            prefixIcon: Icon(Icons.medication_rounded),
                          ),
                          items: eligibleParents.map((item) {
                            final batch = item.batch;
                            return DropdownMenuItem(
                              value: item.id,
                              child: Text(
                                '${batch?.medicineName ?? "Item"} (${item.quantity} ${item.unit} - Batch ${batch?.batchNumber})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              final p = eligibleParents.firstWhere((i) => i.id == val);
                              setState(() {
                                _selectedParent = p;
                              });
                              _presetDefaultSplit(p);
                            }
                          },
                        ),

                        if (_selectedParent != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Selected Package: ${_selectedParent!.quantity} ${_selectedParent!.unit} in ${_selectedParent!.location ?? "Storage"}.',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        const Text(
                          '2. Configure Child Portions (MVP: 2 Portions)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),

                        _PortionInputCard(
                          title: 'Portion A',
                          qtyController: _qtyAController,
                          locController: _locAController,
                          unit: _selectedParent?.unit ?? 'units',
                          color: AppColors.primary,
                        ),

                        const SizedBox(height: 14),

                        _PortionInputCard(
                          title: 'Portion B',
                          qtyController: _qtyBController,
                          locController: _locBController,
                          unit: _selectedParent?.unit ?? 'units',
                          color: AppColors.primaryLight,
                        ),

                        const SizedBox(height: 20),

                        if (_validationError != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.warningBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.warning),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _validationError!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (_selectedParent != null)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.successBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.success),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: AppColors.success),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Valid split configuration! ${_qtyAController.text} + ${_qtyBController.text} = ${_selectedParent!.quantity} ${_selectedParent!.unit}.',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: (_validationError == null && !_isProcessing && _selectedParent != null)
                                ? _executeSplit
                                : null,
                            icon: const Icon(Icons.alt_route_rounded),
                            label: _isProcessing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Confirm & Execute Atomic Split'),
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

  Widget _buildSuccessView(List<MedicineItem> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.successBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.success, width: 1.5),
          ),
          child: Column(
            children: const [
              Icon(Icons.task_alt_rounded, size: 56, color: AppColors.success),
              SizedBox(height: 12),
              Text(
                'Split & Identity Preservation Complete',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                'The parent medicine package has been atomically updated to status "SPLIT", and 2 child portion records were created with inherited batch metadata.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Generated Child Portion Identities & Package Photos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),

        ...children.map(
          (child) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${child.quantity} ${child.unit}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'LOCATION: ${child.location}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Item UUID: ${child.id}',
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.textMuted),
                ),
                Text(
                  'Inherited Batch: ${child.batch?.batchNumber ?? "N/A"} · Exp: ${child.batch?.expiryDate.toIso8601String().split('T')[0]}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PackagePhotoScreen(item: child),
                        ),
                      );
                    },
                    icon: const Icon(Icons.photo_camera_rounded),
                    label: const Text('View Portion Package Photo'),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Return to Inventory'),
          ),
        ),
      ],
    );
  }
}

class _PortionInputCard extends StatelessWidget {
  final String title;
  final TextEditingController qtyController;
  final TextEditingController locController;
  final String unit;
  final Color color;

  const _PortionInputCard({
    required this.title,
    required this.qtyController,
    required this.locController,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Portion Qty ($unit)',
                    prefixIcon: const Icon(Icons.numbers_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: locController,
                  decoration: const InputDecoration(
                    labelText: 'Assigned Location',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
