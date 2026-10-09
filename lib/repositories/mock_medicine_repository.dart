import 'package:uuid/uuid.dart';
import '../models/medicine.dart';
import '../models/family_member.dart';
import '../models/medicine_history.dart';
import 'medicine_repository.dart';

class MockMedicineRepository implements MedicineRepository {
  static final _uuid = const Uuid();

  final Map<String, FamilyMember> _familyMembers = {};
  final Map<String, Medicine> _medicines = {};
  final List<MedicineHistory> _historyLogs = [];

  MockMedicineRepository() {
    _seedInitialData();
  }

  void _seedInitialData() {
    final now = DateTime.now();

    // 1. Seed Family Members (Grandma, Grandpa, Mom, Dad, Son, Sister)
    final grandma = FamilyMember(
      id: 'family-grandma',
      name: 'Grandma',
      relation: 'Grandmother',
      notes: 'Requires daily blood pressure monitoring',
      createdAt: now.subtract(const Duration(days: 90)),
    );
    final dad = FamilyMember(
      id: 'family-dad',
      name: 'Dad',
      relation: 'Father',
      notes: 'Diabetes management',
      createdAt: now.subtract(const Duration(days: 90)),
    );
    final mom = FamilyMember(
      id: 'family-mom',
      name: 'Mom',
      relation: 'Mother',
      notes: 'Daily vitamins',
      createdAt: now.subtract(const Duration(days: 90)),
    );
    final grandpa = FamilyMember(
      id: 'family-grandpa',
      name: 'Grandpa',
      relation: 'Grandfather',
      notes: 'Cholesterol & heart care',
      createdAt: now.subtract(const Duration(days: 90)),
    );
    final son = FamilyMember(
      id: 'family-son',
      name: 'Son',
      relation: 'Son',
      notes: 'Seasonal allergy relief',
      createdAt: now.subtract(const Duration(days: 90)),
    );
    final sister = FamilyMember(
      id: 'family-sister',
      name: 'Sister',
      relation: 'Daughter',
      notes: 'Asthma & allergies',
      createdAt: now.subtract(const Duration(days: 90)),
    );

    _familyMembers[grandma.id] = grandma;
    _familyMembers[dad.id] = dad;
    _familyMembers[mom.id] = mom;
    _familyMembers[grandpa.id] = grandpa;
    _familyMembers[son.id] = son;
    _familyMembers[sister.id] = sister;

    // 2. Seed Exact Demo Medicines specified in Prompt
    // Amlodipine 5 mg — Grandma — 4 tablets left — expires 20 Oct 2026
    final med1 = Medicine(
      id: 'med-amlodipine',
      familyMemberId: grandma.id,
      name: 'Amlodipine 5 mg',
      batchNumber: 'AML-8823',
      manufacturer: 'Pfizer',
      mfgDate: DateTime(2024, 10, 1),
      expiryDate: DateTime(2026, 10, 20),
      totalQuantity: 30,
      remainingQuantity: 4,
      unit: 'tablets',
      category: 'Cardiology',
      location: 'Grandma Nightstand Box',
      dateOpened: now.subtract(const Duration(days: 26)),
      status: 'active',
      notes: 'Take 1 tablet every morning after breakfast',
      imageFrontUrl: 'assets/images/app_icon.png',
      familyMember: grandma,
      createdAt: now.subtract(const Duration(days: 26)),
    );

    // Metformin 500 mg — Dad — 12 tablets left — expires 12 Jan 2027
    final med2 = Medicine(
      id: 'med-metformin',
      familyMemberId: dad.id,
      name: 'Metformin 500 mg',
      batchNumber: 'MTF-9901',
      manufacturer: 'Merck Healthcare',
      mfgDate: DateTime(2025, 1, 12),
      expiryDate: DateTime(2027, 1, 12),
      totalQuantity: 60,
      remainingQuantity: 12,
      unit: 'tablets',
      category: 'Diabetes',
      location: 'Kitchen Medicine Cabinet',
      dateOpened: now.subtract(const Duration(days: 48)),
      status: 'active',
      notes: 'Take with evening meal',
      imageFrontUrl: 'assets/images/app_icon.png',
      familyMember: dad,
      createdAt: now.subtract(const Duration(days: 48)),
    );

    // Vitamin D3 1000 IU — Mom — 2 tablets left — expires 15 Sep 2026
    final med3 = Medicine(
      id: 'med-vitamind3',
      familyMemberId: mom.id,
      name: 'Vitamin D3 1000 IU',
      batchNumber: 'VTD-4011',
      manufacturer: 'NatureMade',
      mfgDate: DateTime(2024, 9, 15),
      expiryDate: DateTime(2026, 9, 15),
      totalQuantity: 30,
      remainingQuantity: 2,
      unit: 'tablets',
      category: 'Vitamins',
      location: 'Mom Dressing Table',
      dateOpened: now.subtract(const Duration(days: 28)),
      status: 'active',
      notes: 'Take 1 tablet with water',
      imageFrontUrl: 'assets/images/app_icon.png',
      familyMember: mom,
      createdAt: now.subtract(const Duration(days: 28)),
    );

    // Atorvastatin 20 mg — Grandpa — 8 tablets left — expires 05 Dec 2026
    final med4 = Medicine(
      id: 'med-atorvastatin',
      familyMemberId: grandpa.id,
      name: 'Atorvastatin 20 mg',
      batchNumber: 'ATV-3390',
      manufacturer: 'Novartis',
      expiryDate: DateTime(2026, 12, 5),
      totalQuantity: 30,
      remainingQuantity: 8,
      unit: 'tablets',
      category: 'Cardiology',
      location: 'Grandpa Pillbox',
      dateOpened: now.subtract(const Duration(days: 22)),
      status: 'active',
      notes: 'Take 1 tablet at bedtime',
      imageFrontUrl: 'assets/images/app_icon.png',
      familyMember: grandpa,
      createdAt: now.subtract(const Duration(days: 22)),
    );

    // Paracetamol 500 mg — Son — 15 tablets left — expires 30 Aug 2027
    final med5 = Medicine(
      id: 'med-paracetamol',
      familyMemberId: son.id,
      name: 'Paracetamol 500 mg',
      batchNumber: 'PCT-7703',
      manufacturer: 'GSK Consumer',
      expiryDate: DateTime(2027, 8, 30),
      totalQuantity: 20,
      remainingQuantity: 15,
      unit: 'tablets',
      category: 'Pain Relief',
      location: 'First Aid Kit',
      status: 'active',
      notes: 'As needed for fever or headache',
      imageFrontUrl: 'assets/images/app_icon.png',
      familyMember: son,
      createdAt: now.subtract(const Duration(days: 10)),
    );

    _medicines[med1.id] = med1;
    _medicines[med2.id] = med2;
    _medicines[med3.id] = med3;
    _medicines[med4.id] = med4;
    _medicines[med5.id] = med5;

    // Seed History Logs
    _historyLogs.add(MedicineHistory(
      id: _uuid.v4(),
      medicineId: med1.id,
      eventType: 'added',
      quantityChange: 30,
      notes: 'Registered initial 30 tablet strip for Grandma',
      createdAt: now.subtract(const Duration(days: 26)),
    ));
    _historyLogs.add(MedicineHistory(
      id: _uuid.v4(),
      medicineId: med1.id,
      eventType: 'taken',
      quantityChange: 1,
      notes: 'Morning dose recorded',
      createdAt: now.subtract(const Duration(hours: 4)),
    ));
  }

  @override
  Future<List<Medicine>> getMedicines({String? familyMemberId, String? searchKeyword}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _medicines.values.where((med) {
      if (med.status == 'archived') return false;
      if (familyMemberId != null && familyMemberId.isNotEmpty && med.familyMemberId != familyMemberId) {
        return false;
      }
      if (searchKeyword != null && searchKeyword.trim().isNotEmpty) {
        final kw = searchKeyword.trim().toLowerCase();
        final matchesName = med.name.toLowerCase().contains(kw);
        final matchesBatch = (med.batchNumber ?? '').toLowerCase().contains(kw);
        final matchesCategory = med.category.toLowerCase().contains(kw);
        final matchesMfr = (med.manufacturer ?? '').toLowerCase().contains(kw);
        if (!matchesName && !matchesBatch && !matchesCategory && !matchesMfr) return false;
      }
      return true;
    }).map((med) {
      final member = _familyMembers[med.familyMemberId];
      return med.copyWith(familyMember: member);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Medicine?> getMedicineById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final med = _medicines[id];
    if (med == null) return null;
    final member = _familyMembers[med.familyMemberId];
    return med.copyWith(familyMember: member);
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
    await Future.delayed(const Duration(milliseconds: 250));
    final id = _uuid.v4();
    final member = familyMemberId != null ? _familyMembers[familyMemberId] : null;

    final newMed = Medicine(
      id: id,
      familyMemberId: familyMemberId,
      name: name.trim(),
      batchNumber: batchNumber?.trim(),
      manufacturer: manufacturer?.trim(),
      mfgDate: mfgDate,
      expiryDate: expiryDate,
      totalQuantity: totalQuantity,
      remainingQuantity: remainingQuantity,
      unit: unit,
      category: category,
      location: location?.trim(),
      dateOpened: dateOpened,
      notes: notes?.trim(),
      imageFrontUrl: imageFrontUrl,
      imageBackUrl: imageBackUrl,
      status: 'active',
      createdAt: DateTime.now(),
      familyMember: member,
    );

    _medicines[id] = newMed;

    _historyLogs.insert(
      0,
      MedicineHistory(
        id: _uuid.v4(),
        medicineId: id,
        eventType: 'added',
        quantityChange: totalQuantity,
        notes: 'Added $totalQuantity $unit to inventory.',
      ),
    );

    return newMed;
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
    await Future.delayed(const Duration(milliseconds: 200));
    final med = _medicines[id];
    if (med == null) throw Exception('Medicine not found');

    final member = familyMemberId != null ? _familyMembers[familyMemberId] : _familyMembers[med.familyMemberId];

    final updated = med.copyWith(
      name: name ?? med.name,
      familyMemberId: familyMemberId ?? med.familyMemberId,
      batchNumber: batchNumber ?? med.batchNumber,
      manufacturer: manufacturer ?? med.manufacturer,
      mfgDate: mfgDate ?? med.mfgDate,
      expiryDate: expiryDate ?? med.expiryDate,
      totalQuantity: totalQuantity ?? med.totalQuantity,
      remainingQuantity: remainingQuantity ?? med.remainingQuantity,
      unit: unit ?? med.unit,
      category: category ?? med.category,
      location: location ?? med.location,
      dateOpened: dateOpened ?? med.dateOpened,
      status: status ?? med.status,
      notes: notes ?? med.notes,
      imageFrontUrl: imageFrontUrl ?? med.imageFrontUrl,
      imageBackUrl: imageBackUrl ?? med.imageBackUrl,
      familyMember: member,
    );

    _medicines[id] = updated;

    _historyLogs.insert(
      0,
      MedicineHistory(
        id: _uuid.v4(),
        medicineId: id,
        eventType: 'updated',
        quantityChange: 0,
        notes: 'Medicine details updated.',
      ),
    );

    return updated;
  }

  @override
  Future<Medicine> markMedicineAsTaken(String id, int quantity, {String? notes}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final med = _medicines[id];
    if (med == null) throw Exception('Medicine not found');

    if (quantity <= 0) throw Exception('Quantity consumed must be greater than 0.');
    if (quantity > med.remainingQuantity) {
      throw Exception('Consumption ($quantity) cannot exceed remaining quantity (${med.remainingQuantity}).');
    }

    final newRemaining = med.remainingQuantity - quantity;
    final newStatus = newRemaining == 0 ? 'finished' : med.status;

    final updated = med.copyWith(
      remainingQuantity: newRemaining,
      status: newStatus,
    );

    _medicines[id] = updated;

    _historyLogs.insert(
      0,
      MedicineHistory(
        id: _uuid.v4(),
        medicineId: id,
        eventType: 'taken',
        quantityChange: quantity,
        notes: notes ?? 'Logged dose consumption of $quantity ${med.unit}.',
      ),
    );

    return updated;
  }

  @override
  Future<List<FamilyMember>> getFamilyMembers() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _familyMembers.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<FamilyMember> addFamilyMember({required String name, required String relation, String? notes}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final id = _uuid.v4();
    final newMember = FamilyMember(
      id: id,
      name: name.trim(),
      relation: relation.trim(),
      notes: notes?.trim(),
    );
    _familyMembers[id] = newMember;
    return newMember;
  }

  @override
  Future<FamilyMember> updateFamilyMember(String id, {String? name, String? relation, String? notes}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final member = _familyMembers[id];
    if (member == null) throw Exception('Family member not found');

    final updated = member.copyWith(
      name: name ?? member.name,
      relation: relation ?? member.relation,
      notes: notes ?? member.notes,
    );
    _familyMembers[id] = updated;
    return updated;
  }

  @override
  Future<List<MedicineHistory>> getMedicineHistory(String medicineId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _historyLogs.where((h) => h.medicineId == medicineId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Medicine>> getAlerts() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _medicines.values
        .where((m) => m.status == 'active' && (m.isExpired || m.isExpiringSoon || m.isLowStock || m.isOpenedForLongTime))
        .map((m) => m.copyWith(familyMember: _familyMembers[m.familyMemberId]))
        .toList();
  }

  @override
  Future<List<Medicine>> getArchivedMedicines() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _medicines.values
        .where((m) => m.status == 'archived' || m.status == 'finished')
        .map((m) => m.copyWith(familyMember: _familyMembers[m.familyMemberId]))
        .toList();
  }
}
