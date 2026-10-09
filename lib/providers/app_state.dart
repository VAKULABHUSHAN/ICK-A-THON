import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/medicine.dart';
import '../models/family_member.dart';
import '../models/medicine_history.dart';
import '../repositories/medicine_repository.dart';
import '../repositories/mock_medicine_repository.dart';
import '../repositories/supabase_medicine_repository.dart';

class AppState extends ChangeNotifier {
  late MedicineRepository _repository;
  bool _isMockMode = true;
  bool _isSupabaseInitialized = false;

  List<Medicine> _medicines = [];
  List<FamilyMember> _familyMembers = [];
  bool _isLoading = false;
  String? _errorMessage;

  String? _selectedFamilyMemberId; // null = "All"
  String _searchQuery = '';

  AppState() {
    _repository = MockMedicineRepository();
    _tryInitSupabase();
    refreshData();
  }

  bool get isMockMode => _isMockMode;
  bool get isSupabaseInitialized => _isSupabaseInitialized;
  List<Medicine> get medicines => _medicines;
  List<FamilyMember> get familyMembers => _familyMembers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedFamilyMemberId => _selectedFamilyMemberId;
  String get searchQuery => _searchQuery;

  // Filtered medicines list
  List<Medicine> get filteredMedicines {
    return _medicines.where((med) {
      if (med.status == 'archived') return false;
      if (_selectedFamilyMemberId != null && med.familyMemberId != _selectedFamilyMemberId) {
        return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final kw = _searchQuery.trim().toLowerCase();
        final matchesName = med.name.toLowerCase().contains(kw);
        final matchesBatch = (med.batchNumber ?? '').toLowerCase().contains(kw);
        final matchesCat = med.category.toLowerCase().contains(kw);
        final matchesMfr = (med.manufacturer ?? '').toLowerCase().contains(kw);
        if (!matchesName && !matchesBatch && !matchesCat && !matchesMfr) return false;
      }
      return true;
    }).toList();
  }

  // Dashboard metric counts
  int get totalActiveMedicines => _medicines.where((m) => m.status == 'active').length;
  int get expiringSoonCount => _medicines.where((m) => m.status == 'active' && m.isExpiringSoon && !m.isExpired).length;
  int get lowStockCount => _medicines.where((m) => m.status == 'active' && m.isLowStock).length;
  int get expiredCount => _medicines.where((m) => m.isExpired).length;

  List<Medicine> get alertMedicines {
    return _medicines
        .where((m) => m.status == 'active' && (m.isExpired || m.isExpiringSoon || m.isLowStock || m.isOpenedForLongTime))
        .toList();
  }

  // Medicines grouped by family member
  Map<FamilyMember, List<Medicine>> get medicinesGroupedByFamily {
    final Map<FamilyMember, List<Medicine>> map = {};
    for (var member in _familyMembers) {
      final list = filteredMedicines.where((m) => m.familyMemberId == member.id).toList();
      if (list.isNotEmpty) {
        map[member] = list;
      }
    }
    return map;
  }

  void setSelectedFamilyMember(String? memberId) {
    _selectedFamilyMemberId = memberId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void _tryInitSupabase() {
    const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const key = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

    if (url.isNotEmpty && key.isNotEmpty) {
      try {
        // ignore: deprecated_member_use
        Supabase.initialize(url: url, anonKey: key);
        _isSupabaseInitialized = true;
      } catch (e) {
        debugPrint('Supabase init failed: $e');
      }
    }
  }

  void toggleMode(bool useMock) {
    if (useMock) {
      _isMockMode = true;
      _repository = MockMedicineRepository();
      refreshData();
    } else {
      if (_isSupabaseInitialized) {
        _isMockMode = false;
        _repository = SupabaseMedicineRepository(Supabase.instance.client);
        refreshData();
      } else {
        _errorMessage = 'Supabase credentials not configured. Please supply SUPABASE_URL & SUPABASE_ANON_KEY.';
        notifyListeners();
      }
    }
  }

  Future<void> refreshData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _familyMembers = await _repository.getFamilyMembers();
      _medicines = await _repository.getMedicines();
    } catch (e) {
      _errorMessage = 'Failed to load inventory: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Medicine?> getMedicineById(String id) async {
    try {
      return await _repository.getMedicineById(id);
    } catch (e) {
      _errorMessage = 'Failed to fetch record: $e';
      notifyListeners();
      return null;
    }
  }

  Future<Medicine?> addMedicine({
    required String name,
    String? familyMemberId,
    String? batchNumber,
    String? manufacturer,
    DateTime? mfgDate,
    required DateTime expiryDate,
    required int totalQuantity,
    required int remainingQuantity,
    required String unit,
    required String category,
    String? location,
    DateTime? dateOpened,
    String? notes,
    String? imageFrontUrl,
    String? imageBackUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newMed = await _repository.addMedicine(
        name: name,
        familyMemberId: familyMemberId,
        batchNumber: batchNumber,
        manufacturer: manufacturer,
        mfgDate: mfgDate,
        expiryDate: expiryDate,
        totalQuantity: totalQuantity,
        remainingQuantity: remainingQuantity,
        unit: unit,
        category: category,
        location: location,
        dateOpened: dateOpened,
        notes: notes,
        imageFrontUrl: imageFrontUrl,
        imageBackUrl: imageBackUrl,
      );
      await refreshData();
      return newMed;
    } catch (e) {
      _errorMessage = 'Failed to save medicine: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> markMedicineAsTaken(String id, int quantity, {String? notes}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.markMedicineAsTaken(id, quantity, notes: notes);
      await refreshData();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to log dose consumption: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMedicine(
    String id, {
    String? name,
    String? familyMemberId,
    String? batchNumber,
    String? manufacturer,
    DateTime? mfgDate,
    DateTime? expiryDate,
    int? totalQuantity,
    int? remainingQuantity,
    String? unit,
    String? category,
    String? location,
    DateTime? dateOpened,
    String? status,
    String? notes,
    String? imageFrontUrl,
    String? imageBackUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateMedicine(
        id,
        name: name,
        familyMemberId: familyMemberId,
        batchNumber: batchNumber,
        manufacturer: manufacturer,
        mfgDate: mfgDate,
        expiryDate: expiryDate,
        totalQuantity: totalQuantity,
        remainingQuantity: remainingQuantity,
        unit: unit,
        category: category,
        location: location,
        dateOpened: dateOpened,
        status: status,
        notes: notes,
        imageFrontUrl: imageFrontUrl,
        imageBackUrl: imageBackUrl,
      );
      await refreshData();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update record: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<FamilyMember?> addFamilyMember({required String name, required String relation, String? notes}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newMember = await _repository.addFamilyMember(name: name, relation: relation, notes: notes);
      await refreshData();
      return newMember;
    } catch (e) {
      _errorMessage = 'Failed to add family member: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<List<MedicineHistory>> getMedicineHistory(String medicineId) async {
    return await _repository.getMedicineHistory(medicineId);
  }

  Future<List<Medicine>> getArchivedMedicines() async {
    return await _repository.getArchivedMedicines();
  }
}
