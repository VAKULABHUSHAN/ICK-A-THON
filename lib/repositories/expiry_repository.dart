import '../models/medicine_item.dart';
import '../models/item_event.dart';

abstract class ExpiryRepository {
  Future<List<MedicineItem>> getInventory();
  Future<MedicineItem?> getItemById(String id);
  
  Future<MedicineItem> addMedicine({
    required String medicineName,
    required String batchNumber,
    required DateTime expiryDate,
    String? manufacturer,
    required int quantity,
    required String unit,
    String? location,
    String? imagePath,
  });

  Future<List<MedicineItem>> splitItem({
    required String parentItemId,
    required int quantityA,
    required int quantityB,
    String? locationA,
    String? locationB,
  });

  Future<List<MedicineItem>> getRecalledItems();
  
  Future<bool> flagBatchAsRecalled(String batchId, {String? reason});
  
  Future<List<ItemEvent>> getItemEvents({String? itemId});
  
  Future<MedicineItem> updateMedicineItem(
    String itemId, {
    int? quantity,
    String? location,
    String? imagePath,
  });
}
