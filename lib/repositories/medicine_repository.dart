import '../models/medicine.dart';
import '../models/family_member.dart';
import '../models/medicine_history.dart';

abstract class MedicineRepository {
  Future<List<Medicine>> getMedicines({String? familyMemberId, String? searchKeyword});
  Future<Medicine?> getMedicineById(String id);
  
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
  });

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
  });

  Future<Medicine> markMedicineAsTaken(String id, int quantity, {String? notes});

  Future<List<FamilyMember>> getFamilyMembers();
  Future<FamilyMember> addFamilyMember({required String name, required String relation, String? notes});
  Future<FamilyMember> updateFamilyMember(String id, {String? name, String? relation, String? notes});

  Future<List<MedicineHistory>> getMedicineHistory(String medicineId);
  Future<List<Medicine>> getAlerts();
  Future<List<Medicine>> getArchivedMedicines();
}
