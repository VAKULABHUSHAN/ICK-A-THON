import 'package:uuid/uuid.dart';
import '../models/medicine_batch.dart';
import '../models/medicine_item.dart';
import '../models/item_event.dart';
import 'expiry_repository.dart';

class MockExpiryRepository implements ExpiryRepository {
  static final _uuid = const Uuid();

  final Map<String, MedicineBatch> _batches = {};
  final Map<String, MedicineItem> _items = {};
  final List<ItemEvent> _events = [];

  MockExpiryRepository() {
    _seedInitialData();
  }

  void _seedInitialData() {
    final now = DateTime.now();

    // 1. Seed Demo Medicine A (Split lineage demo)
    final batchAId = 'batch-demo-a';
    final parentAId = 'item-demo-parent';
    final childA1Id = 'item-demo-child-1';
    final childA2Id = 'item-demo-child-2';

    final batchA = MedicineBatch(
      id: batchAId,
      medicineName: 'Demo Medicine A',
      batchNumber: 'B23184',
      expiryDate: DateTime(2028, 8, 31),
      manufacturer: 'Apex Pharma Ltd',
      isRecalled: false,
      createdAt: now.subtract(const Duration(days: 15)),
    );
    _batches[batchAId] = batchA;

    _items[parentAId] = MedicineItem(
      id: parentAId,
      batchId: batchAId,
      quantity: 10,
      unit: 'tablets',
      location: 'Main Cabinet (Original Strip)',
      imagePath: 'assets/images/app_icon.png',
      status: ItemStatus.split,
      createdAt: now.subtract(const Duration(days: 15)),
      batch: batchA,
    );

    _items[childA1Id] = MedicineItem(
      id: childA1Id,
      batchId: batchAId,
      parentItemId: parentAId,
      quantity: 4,
      unit: 'tablets',
      location: 'First Aid Pouch',
      imagePath: 'assets/images/app_icon.png',
      status: ItemStatus.active,
      createdAt: now.subtract(const Duration(days: 2)),
      batch: batchA,
    );

    _items[childA2Id] = MedicineItem(
      id: childA2Id,
      batchId: batchAId,
      parentItemId: parentAId,
      quantity: 6,
      unit: 'tablets',
      location: 'Nightstand Pillbox',
      imagePath: 'assets/images/app_icon.png',
      status: ItemStatus.active,
      createdAt: now.subtract(const Duration(days: 2)),
      batch: batchA,
    );

    _events.add(ItemEvent(
      id: _uuid.v4(),
      itemId: parentAId,
      eventType: 'added',
      details: {
        'medicine_name': 'Demo Medicine A',
        'batch_number': 'B23184',
        'quantity': 10,
        'unit': 'tablets',
        'location': 'Main Cabinet',
      },
      createdAt: now.subtract(const Duration(days: 15)),
    ));

    _events.add(ItemEvent(
      id: _uuid.v4(),
      itemId: parentAId,
      eventType: 'split',
      details: {
        'medicine_name': 'Demo Medicine A',
        'batch_number': 'B23184',
        'parent_quantity': 10,
        'child_a_quantity': 4,
        'child_b_quantity': 6,
        'child_a_id': childA1Id,
        'child_b_id': childA2Id,
      },
      createdAt: now.subtract(const Duration(days: 2)),
    ));

    // 2. Seed Expiring Soon Sample
    final batchBId = 'batch-amx-902';
    final itemBId = 'item-amx-active';
    final batchB = MedicineBatch(
      id: batchBId,
      medicineName: 'Amoxicillin Trihydrate 500mg',
      batchNumber: 'AMX-902',
      expiryDate: now.add(const Duration(days: 14)),
      manufacturer: 'BioMed Corp',
      isRecalled: false,
      createdAt: now.subtract(const Duration(days: 45)),
    );
    _batches[batchBId] = batchB;
    _items[itemBId] = MedicineItem(
      id: itemBId,
      batchId: batchBId,
      quantity: 12,
      unit: 'capsules',
      location: 'Kitchen Shelf B',
      imagePath: 'assets/images/app_icon.png',
      status: ItemStatus.active,
      createdAt: now.subtract(const Duration(days: 45)),
      batch: batchB,
    );

    // 3. Seed Recalled Sample
    final batchCId = 'batch-vls-401';
    final itemCId = 'item-vls-active';
    final batchC = MedicineBatch(
      id: batchCId,
      medicineName: 'Valsartan 80mg',
      batchNumber: 'VLS-401',
      expiryDate: DateTime(2027, 5, 20),
      manufacturer: 'CardioCare Labs',
      isRecalled: true,
      recallReason: 'Impurity trace detected in active ingredient supplier batch.',
      createdAt: now.subtract(const Duration(days: 60)),
    );
    _batches[batchCId] = batchC;
    _items[itemCId] = MedicineItem(
      id: itemCId,
      batchId: batchCId,
      quantity: 28,
      unit: 'tablets',
      location: 'Medicine Box #1',
      imagePath: 'assets/images/app_icon.png',
      status: ItemStatus.active,
      createdAt: now.subtract(const Duration(days: 60)),
      batch: batchC,
    );

    // 4. Seed Vitamin C
    final batchDId = 'batch-vitc-100';
    final itemDId = 'item-vitc-active';
    final batchD = MedicineBatch(
      id: batchDId,
      medicineName: 'Vitamin C 1000mg Effervescent',
      batchNumber: 'VTC-889',
      expiryDate: DateTime(2028, 12, 31),
      manufacturer: 'NutraHealth',
      isRecalled: false,
      createdAt: now.subtract(const Duration(days: 10)),
    );
    _batches[batchDId] = batchD;
    _items[itemDId] = MedicineItem(
      id: itemDId,
      batchId: batchDId,
      quantity: 20,
      unit: 'tablets',
      location: 'Office Desk Drawer',
      imagePath: 'assets/images/app_icon.png',
      status: ItemStatus.active,
      createdAt: now.subtract(const Duration(days: 10)),
      batch: batchD,
    );
  }

  @override
  Future<List<MedicineItem>> getInventory() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _items.values.map((item) {
      final batch = _batches[item.batchId];
      return item.copyWith(batch: batch);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<MedicineItem?> getItemById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final item = _items[id];
    if (item == null) return null;
    final batch = _batches[item.batchId];
    return item.copyWith(batch: batch);
  }

  @override
  Future<MedicineItem> addMedicine({
    required String medicineName,
    required String batchNumber,
    required DateTime expiryDate,
    String? manufacturer,
    required int quantity,
    required String unit,
    String? location,
    String? imagePath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    String batchId = _uuid.v4();
    final existingBatch = _batches.values.firstWhere(
      (b) => b.batchNumber.toLowerCase() == batchNumber.trim().toLowerCase(),
      orElse: () => MedicineBatch(
        id: batchId,
        medicineName: medicineName.trim(),
        batchNumber: batchNumber.trim(),
        expiryDate: expiryDate,
        manufacturer: manufacturer?.trim(),
      ),
    );

    if (!_batches.containsKey(existingBatch.id)) {
      _batches[existingBatch.id] = existingBatch;
    }

    final newItemId = _uuid.v4();
    final newItem = MedicineItem(
      id: newItemId,
      batchId: existingBatch.id,
      quantity: quantity,
      unit: unit,
      location: location?.trim(),
      imagePath: imagePath,
      status: ItemStatus.active,
      createdAt: DateTime.now(),
      batch: existingBatch,
    );

    _items[newItemId] = newItem;

    _events.insert(
      0,
      ItemEvent(
        id: _uuid.v4(),
        itemId: newItemId,
        eventType: 'added',
        details: {
          'medicine_name': medicineName,
          'batch_number': batchNumber,
          'quantity': quantity,
          'unit': unit,
          'location': location,
          'image_path': imagePath,
        },
      ),
    );

    return newItem;
  }

  @override
  Future<List<MedicineItem>> splitItem({
    required String parentItemId,
    required int quantityA,
    required int quantityB,
    String? locationA,
    String? locationB,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final parent = _items[parentItemId];
    if (parent == null) throw Exception('Parent item not found.');
    if (parent.status == ItemStatus.split) throw Exception('Item has already been split.');
    if (quantityA <= 0 || quantityB <= 0) throw Exception('Child quantities must be positive integers.');
    if (quantityA + quantityB != parent.quantity) {
      throw Exception('Sum of child quantities must equal parent quantity.');
    }

    final batch = _batches[parent.batchId];

    final updatedParent = parent.copyWith(status: ItemStatus.split);
    _items[parentItemId] = updatedParent;

    final childAId = _uuid.v4();
    final childA = MedicineItem(
      id: childAId,
      batchId: parent.batchId,
      parentItemId: parentItemId,
      quantity: quantityA,
      unit: parent.unit,
      location: (locationA != null && locationA.trim().isNotEmpty)
          ? locationA.trim()
          : '${parent.location ?? "Storage"} (Portion A)',
      imagePath: parent.imagePath,
      status: ItemStatus.active,
      createdAt: DateTime.now(),
      batch: batch,
    );

    final childBId = _uuid.v4();
    final childB = MedicineItem(
      id: childBId,
      batchId: parent.batchId,
      parentItemId: parentItemId,
      quantity: quantityB,
      unit: parent.unit,
      location: (locationB != null && locationB.trim().isNotEmpty)
          ? locationB.trim()
          : '${parent.location ?? "Storage"} (Portion B)',
      imagePath: parent.imagePath,
      status: ItemStatus.active,
      createdAt: DateTime.now(),
      batch: batch,
    );

    _items[childAId] = childA;
    _items[childBId] = childB;

    _events.insert(
      0,
      ItemEvent(
        id: _uuid.v4(),
        itemId: parentItemId,
        eventType: 'split',
        details: {
          'medicine_name': batch?.medicineName ?? 'Medicine',
          'batch_number': batch?.batchNumber ?? '',
          'parent_quantity': parent.quantity,
          'unit': parent.unit,
          'child_a_quantity': quantityA,
          'child_b_quantity': quantityB,
          'child_a_id': childAId,
          'child_b_id': childBId,
        },
      ),
    );

    return [childA, childB];
  }

  @override
  Future<List<MedicineItem>> getRecalledItems() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final recalledBatchIds = _batches.values
        .where((b) => b.isRecalled)
        .map((b) => b.id)
        .toSet();

    return _items.values
        .where((item) => recalledBatchIds.contains(item.batchId))
        .map((item) => item.copyWith(batch: _batches[item.batchId]))
        .toList();
  }

  @override
  Future<bool> flagBatchAsRecalled(String batchId, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final batch = _batches[batchId];
    if (batch == null) return false;

    final updatedBatch = batch.copyWith(
      isRecalled: true,
      recallReason: reason ?? 'Batch recalled by safety authority for testing.',
    );
    _batches[batchId] = updatedBatch;

    final affectedItems = _items.values.where((i) => i.batchId == batchId);
    for (var item in affectedItems) {
      _events.insert(
        0,
        ItemEvent(
          id: _uuid.v4(),
          itemId: item.id,
          eventType: 'recalled',
          details: {
            'medicine_name': batch.medicineName,
            'batch_number': batch.batchNumber,
            'recall_reason': updatedBatch.recallReason,
            'message': 'Simulated recall issued for batch ${batch.batchNumber}',
          },
        ),
      );
    }

    return true;
  }

  @override
  Future<List<ItemEvent>> getItemEvents({String? itemId}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (itemId != null) {
      return _events.where((e) => e.itemId == itemId).toList();
    }
    return List.from(_events);
  }

  @override
  Future<MedicineItem> updateMedicineItem(
    String itemId, {
    int? quantity,
    String? location,
    String? imagePath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final item = _items[itemId];
    if (item == null) throw Exception('Item not found.');

    final updatedItem = item.copyWith(
      quantity: quantity ?? item.quantity,
      location: location ?? item.location,
      imagePath: imagePath ?? item.imagePath,
    );
    _items[itemId] = updatedItem;
    return updatedItem;
  }
}
