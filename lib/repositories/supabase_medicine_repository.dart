import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/medicine.dart';
import '../models/family_member.dart';
import '../models/medicine_history.dart';
import 'medicine_repository.dart';

class SupabaseMedicineRepository implements MedicineRepository {
  final SupabaseClient client;

  SupabaseMedicineRepository(this.client);

  @override
  Future<List<Medicine>> getMedicines({String? familyMemberId, String? searchKeyword}) async {
    var query = client.from('medicines').select('*, family_members(*)');
    query = query.neq('status', 'archived');

    if (familyMemberId != null && familyMemberId.isNotEmpty) {
      query = query.eq('family_member_id', familyMemberId);
    }
    if (searchKeyword != null && searchKeyword.trim().isNotEmpty) {
      query = query.ilike('name', '%${searchKeyword.trim()}%');
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List)
        .map((json) => Medicine.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Medicine?> getMedicineById(String id) async {
    final response = await client
        .from('medicines')
        .select('*, family_members(*)')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Medicine.fromJson(response);
  }

  @override
  Future<Medicine> addMedicine({
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
    final res = await client
        .from('medicines')
        .insert({
          'name': name,
          'family_member_id': familyMemberId,
          'batch_number': batchNumber,
          'manufacturer': manufacturer,
          'mfg_date': mfgDate?.toIso8601String().split('T')[0],
          'expiry_date': expiryDate.toIso8601String().split('T')[0],
          'total_quantity': totalQuantity,
          'remaining_quantity': remainingQuantity,
          'unit': unit,
          'category': category,
          'location': location,
          'date_opened': dateOpened?.toIso8601String().split('T')[0],
          'status': 'active',
          'notes': notes,
          'image_front_url': imageFrontUrl,
          'image_back_url': imageBackUrl,
        })
        .select('*, family_members(*)')
        .single();

    final med = Medicine.fromJson(res);

    await client.from('medicine_history').insert({
      'medicine_id': med.id,
      'event_type': 'added',
      'quantity_change': totalQuantity,
      'notes': 'Added to inventory',
    });

    return med;
  }

  @override
  Future<Medicine> updateMedicine(
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
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (familyMemberId != null) updates['family_member_id'] = familyMemberId;
    if (batchNumber != null) updates['batch_number'] = batchNumber;
    if (manufacturer != null) updates['manufacturer'] = manufacturer;
    if (mfgDate != null) updates['mfg_date'] = mfgDate.toIso8601String().split('T')[0];
    if (expiryDate != null) updates['expiry_date'] = expiryDate.toIso8601String().split('T')[0];
    if (totalQuantity != null) updates['total_quantity'] = totalQuantity;
    if (remainingQuantity != null) updates['remaining_quantity'] = remainingQuantity;
    if (unit != null) updates['unit'] = unit;
    if (category != null) updates['category'] = category;
    if (location != null) updates['location'] = location;
    if (dateOpened != null) updates['date_opened'] = dateOpened.toIso8601String().split('T')[0];
    if (status != null) updates['status'] = status;
    if (notes != null) updates['notes'] = notes;
    if (imageFrontUrl != null) updates['image_front_url'] = imageFrontUrl;
    if (imageBackUrl != null) updates['image_back_url'] = imageBackUrl;

    final res = await client
        .from('medicines')
        .update(updates)
        .eq('id', id)
        .select('*, family_members(*)')
        .single();

    return Medicine.fromJson(res);
  }

  @override
  Future<Medicine> markMedicineAsTaken(String id, int quantity, {String? notes}) async {
    final med = await getMedicineById(id);
    if (med == null) throw Exception('Medicine not found');

    final newRemaining = (med.remainingQuantity - quantity).clamp(0, med.totalQuantity);
    final newStatus = newRemaining == 0 ? 'finished' : med.status;

    final res = await client
        .from('medicines')
        .update({
          'remaining_quantity': newRemaining,
          'status': newStatus,
        })
        .eq('id', id)
        .select('*, family_members(*)')
        .single();

    await client.from('medicine_history').insert({
      'medicine_id': id,
      'event_type': 'taken',
      'quantity_change': quantity,
      'notes': notes ?? 'Dose taken',
    });

    return Medicine.fromJson(res);
  }

  @override
  Future<List<FamilyMember>> getFamilyMembers() async {
    final response = await client.from('family_members').select('*').order('name');
    return (response as List)
        .map((json) => FamilyMember.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FamilyMember> addFamilyMember({required String name, required String relation, String? notes}) async {
    final res = await client
        .from('family_members')
        .insert({
          'name': name,
          'relation': relation,
          'notes': notes,
        })
        .select()
        .single();

    return FamilyMember.fromJson(res);
  }

  @override
  Future<FamilyMember> updateFamilyMember(String id, {String? name, String? relation, String? notes}) async {
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (relation != null) updates['relation'] = relation;
    if (notes != null) updates['notes'] = notes;

    final res = await client
        .from('family_members')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    return FamilyMember.fromJson(res);
  }

  @override
  Future<List<MedicineHistory>> getMedicineHistory(String medicineId) async {
    final response = await client
        .from('medicine_history')
        .select('*')
        .eq('medicine_id', medicineId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => MedicineHistory.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Medicine>> getAlerts() async {
    final response = await client
        .from('medicines')
        .select('*, family_members(*)')
        .eq('status', 'active');

    final list = (response as List)
        .map((json) => Medicine.fromJson(json as Map<String, dynamic>))
        .toList();

    return list
        .where((m) => m.isExpired || m.isExpiringSoon || m.isLowStock || m.isOpenedForLongTime)
        .toList();
  }

  @override
  Future<List<Medicine>> getArchivedMedicines() async {
    final response = await client
        .from('medicines')
        .select('*, family_members(*)')
        .or('status.eq.archived,status.eq.finished');

    return (response as List)
        .map((json) => Medicine.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
