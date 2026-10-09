import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/medicine_batch.dart';
import '../models/medicine_item.dart';
import '../models/item_event.dart';
import 'expiry_repository.dart';

class SupabaseExpiryRepository implements ExpiryRepository {
  final SupabaseClient client;

  SupabaseExpiryRepository(this.client);

  @override
  Future<List<MedicineItem>> getInventory() async {
    final response = await client
        .from('items')
        .select('*, batches(*)')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => MedicineItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MedicineItem?> getItemById(String id) async {
    final response = await client
        .from('items')
        .select('*, batches(*)')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return MedicineItem.fromJson(response as Map<String, dynamic>);
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
    final batchResponse = await client
        .from('batches')
        .select()
        .eq('batch_number', batchNumber)
        .maybeSingle();

    String batchId;
    MedicineBatch batch;

    if (batchResponse != null) {
      batch = MedicineBatch.fromJson(batchResponse as Map<String, dynamic>);
      batchId = batch.id;
    } else {
      final newBatchRes = await client
          .from('batches')
          .insert({
            'medicine_name': medicineName,
            'batch_number': batchNumber,
            'expiry_date': expiryDate.toIso8601String().split('T')[0],
            'manufacturer': manufacturer,
            'is_recalled': false,
          })
          .select()
          .single();
      batch = MedicineBatch.fromJson(newBatchRes as Map<String, dynamic>);
      batchId = batch.id;
    }

    final itemRes = await client
        .from('items')
        .insert({
          'batch_id': batchId,
          'quantity': quantity,
          'unit': unit,
          'location': location,
          'image_path': imagePath,
          'status': 'active',
        })
        .select('*, batches(*)')
        .single();

    final item = MedicineItem.fromJson(itemRes as Map<String, dynamic>, batch: batch);

    await client.from('item_events').insert({
      'item_id': item.id,
      'event_type': 'added',
      'details': {
        'medicine_name': medicineName,
        'batch_number': batchNumber,
        'quantity': quantity,
        'unit': unit,
        'location': location,
        'image_path': imagePath,
      },
    });

    return item;
  }

  @override
  Future<List<MedicineItem>> splitItem({
    required String parentItemId,
    required int quantityA,
    required int quantityB,
    String? locationA,
    String? locationB,
  }) async {
    final parent = await getItemById(parentItemId);
    if (parent == null) throw Exception('Parent item not found.');

    await client
        .from('items')
        .update({'status': 'split'})
        .eq('id', parentItemId);

    final childARes = await client
        .from('items')
        .insert({
          'batch_id': parent.batchId,
          'parent_item_id': parentItemId,
          'quantity': quantityA,
          'unit': parent.unit,
          'location': locationA ?? '${parent.location ?? "Storage"} (Portion A)',
          'image_path': parent.imagePath,
          'status': 'active',
        })
        .select('*, batches(*)')
        .single();

    final childBRes = await client
        .from('items')
        .insert({
          'batch_id': parent.batchId,
          'parent_item_id': parentItemId,
          'quantity': quantityB,
          'unit': parent.unit,
          'location': locationB ?? '${parent.location ?? "Storage"} (Portion B)',
          'image_path': parent.imagePath,
          'status': 'active',
        })
        .select('*, batches(*)')
        .single();

    final childA = MedicineItem.fromJson(childARes as Map<String, dynamic>);
    final childB = MedicineItem.fromJson(childBRes as Map<String, dynamic>);

    await client.from('item_events').insert({
      'item_id': parentItemId,
      'event_type': 'split',
      'details': {
        'medicine_name': parent.batch?.medicineName ?? 'Medicine',
        'batch_number': parent.batch?.batchNumber ?? '',
        'parent_quantity': parent.quantity,
        'unit': parent.unit,
        'child_a_quantity': quantityA,
        'child_b_quantity': quantityB,
      },
    });

    return [childA, childB];
  }

  @override
  Future<List<MedicineItem>> getRecalledItems() async {
    final response = await client
        .from('items')
        .select('*, batches!inner(*)')
        .eq('batches.is_recalled', true);

    return (response as List)
        .map((json) => MedicineItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<bool> flagBatchAsRecalled(String batchId, {String? reason}) async {
    await client
        .from('batches')
        .update({
          'is_recalled': true,
          'recall_reason': reason ?? 'Simulated recall issued',
        })
        .eq('id', batchId);
    return true;
  }

  @override
  Future<List<ItemEvent>> getItemEvents({String? itemId}) async {
    var query = client.from('item_events').select('*');
    if (itemId != null) {
      query = query.eq('item_id', itemId);
    }
    final response = await query.order('created_at', ascending: false);

    return (response as List)
        .map((json) => ItemEvent.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MedicineItem> updateMedicineItem(
    String itemId, {
    int? quantity,
    String? location,
    String? imagePath,
  }) async {
    final Map<String, dynamic> updates = {};
    if (quantity != null) updates['quantity'] = quantity;
    if (location != null) updates['location'] = location;
    if (imagePath != null) updates['image_path'] = imagePath;

    final response = await client
        .from('items')
        .update(updates)
        .eq('id', itemId)
        .select('*, batches(*)')
        .single();

    return MedicineItem.fromJson(response as Map<String, dynamic>);
  }
}
