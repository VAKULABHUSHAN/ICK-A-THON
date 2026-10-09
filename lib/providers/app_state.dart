import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/medicine_item.dart';
import '../models/item_event.dart';
import '../repositories/expiry_repository.dart';
import '../repositories/mock_expiry_repository.dart';
import '../repositories/supabase_expiry_repository.dart';

enum InventoryFilter {
  all,
  expiringSoon,
  expired,
  recalled,
}

class AppState extends ChangeNotifier {
  late ExpiryRepository _repository;
  bool _isMockMode = true;
  bool _isSupabaseInitialized = false;

  List<MedicineItem> _inventory = [];
  List<ItemEvent> _events = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  String _searchQuery = '';
  InventoryFilter _selectedFilter = InventoryFilter.all;

  AppState() {
    _repository = MockExpiryRepository();
    _tryInitSupabase();
    refreshData();
  }

  bool get isMockMode => _isMockMode;
  bool get isSupabaseInitialized => _isSupabaseInitialized;
  List<MedicineItem> get inventory => _inventory;
  List<ItemEvent> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  InventoryFilter get selectedFilter => _selectedFilter;

  List<MedicineItem> get filteredInventory {
    return _inventory.where((item) {
      final batch = item.batch;
      if (batch == null) return false;

      final matchesSearch = _searchQuery.isEmpty ||
          batch.medicineName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          batch.batchNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item.location ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      switch (_selectedFilter) {
        case InventoryFilter.all:
          return true;
        case InventoryFilter.expiringSoon:
          return batch.isExpiringSoon && !batch.isExpired;
        case InventoryFilter.expired:
          return batch.isExpired;
        case InventoryFilter.recalled:
          return batch.isRecalled;
      }
    }).toList();
  }

  int get totalActiveItems => _inventory.where((i) => i.status == ItemStatus.active).length;
  int get expiringSoonCount => _inventory.where((i) => i.status == ItemStatus.active && (i.batch?.isExpiringSoon ?? false)).length;
  int get expiredCount => _inventory.where((i) => (i.batch?.isExpired ?? false)).length;
  int get recalledCount => _inventory.where((i) => (i.batch?.isRecalled ?? false)).length;

  List<MedicineItem> get recentlyAddedItems {
    final list = List<MedicineItem>.from(_inventory);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.take(5).toList();
  }

  List<MedicineItem> get upcomingExpiryItems {
    final list = _inventory.where((i) => i.status == ItemStatus.active && !(i.batch?.isExpired ?? true)).toList();
    list.sort((a, b) {
      final dateA = a.batch?.expiryDate ?? DateTime(2099);
      final dateB = b.batch?.expiryDate ?? DateTime(2099);
      return dateA.compareTo(dateB);
    });
    return list.take(5).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(InventoryFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void _tryInitSupabase() {
    const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const key = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

    if (url.isNotEmpty && key.isNotEmpty) {
      try {
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
      _repository = MockExpiryRepository();
      refreshData();
    } else {
      if (_isSupabaseInitialized) {
        _isMockMode = false;
        _repository = SupabaseExpiryRepository(Supabase.instance.client);
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
      _inventory = await _repository.getInventory();
      _events = await _repository.getItemEvents();
    } catch (e) {
      _errorMessage = 'Failed to load data: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<MedicineItem?> getItemById(String id) async {
    try {
      return await _repository.getItemById(id);
    } catch (e) {
      _errorMessage = 'Failed to fetch item: $e';
      notifyListeners();
      return null;
    }
  }

  Future<MedicineItem?> addMedicine({
    required String medicineName,
    required String batchNumber,
    required DateTime expiryDate,
    String? manufacturer,
    required int quantity,
    required String unit,
    String? location,
    String? imagePath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newItem = await _repository.addMedicine(
        medicineName: medicineName,
        batchNumber: batchNumber,
        expiryDate: expiryDate,
        manufacturer: manufacturer,
        quantity: quantity,
        unit: unit,
        location: location,
        imagePath: imagePath,
      );
      await refreshData();
      return newItem;
    } catch (e) {
      _errorMessage = 'Error adding medicine: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<List<MedicineItem>?> splitItem({
    required String parentItemId,
    required int quantityA,
    required int quantityB,
    String? locationA,
    String? locationB,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final children = await _repository.splitItem(
        parentItemId: parentItemId,
        quantityA: quantityA,
        quantityB: quantityB,
        locationA: locationA,
        locationB: locationB,
      );
      await refreshData();
      return children;
    } catch (e) {
      _errorMessage = 'Split failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> simulateBatchRecall(String batchId, {String? reason}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.flagBatchAsRecalled(batchId, reason: reason);
      await refreshData();
      return success;
    } catch (e) {
      _errorMessage = 'Recall simulation failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMedicineItem(String itemId, {int? quantity, String? location, String? imagePath}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateMedicineItem(itemId, quantity: quantity, location: location, imagePath: imagePath);
      await refreshData();
      return true;
    } catch (e) {
      _errorMessage = 'Update failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  MedicineItem? getParentItem(String? parentItemId) {
    if (parentItemId == null) return null;
    try {
      return _inventory.firstWhere((i) => i.id == parentItemId);
    } catch (_) {
      return null;
    }
  }

  List<MedicineItem> getChildItems(String parentItemId) {
    return _inventory.where((i) => i.parentItemId == parentItemId).toList();
  }
}
