import 'family_member.dart';

class Medicine {
  final String id;
  final String? userId;
  final String? familyMemberId;
  final String name;
  final String? batchNumber;
  final String? manufacturer;
  final DateTime? mfgDate;
  final DateTime expiryDate;
  final int totalQuantity;
  final int remainingQuantity;
  final String unit; // 'tablets', 'capsules', 'bottles', 'other'
  final String category;
  final String? location;
  final DateTime? dateOpened;
  final String status; // 'active', 'archived', 'finished'
  final String? notes;
  final String? imageFrontUrl;
  final String? imageBackUrl;
  final DateTime createdAt;
  final FamilyMember? familyMember;

  Medicine({
    required this.id,
    this.userId,
    this.familyMemberId,
    required this.name,
    this.batchNumber,
    this.manufacturer,
    this.mfgDate,
    required this.expiryDate,
    required this.totalQuantity,
    required this.remainingQuantity,
    this.unit = 'tablets',
    this.category = 'General',
    this.location,
    this.dateOpened,
    this.status = 'active',
    this.notes,
    this.imageFrontUrl,
    this.imageBackUrl,
    DateTime? createdAt,
    this.familyMember,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isExpired {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return exp.isBefore(today);
  }

  bool get isExpiringSoon {
    if (isExpired) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final days = exp.difference(today).inDays;
    return days >= 0 && days <= 30;
  }

  bool get isLowStock {
    if (remainingQuantity <= 0) return true;
    return remainingQuantity <= 5 || (remainingQuantity / totalQuantity) <= 0.25;
  }

  bool get isOpenedForLongTime {
    if (dateOpened == null) return false;
    final days = DateTime.now().difference(dateOpened!).inDays;
    return days >= 60;
  }

  double get stockProgress {
    if (totalQuantity <= 0) return 0.0;
    final ratio = remainingQuantity / totalQuantity;
    return ratio.clamp(0.0, 1.0);
  }

  Medicine copyWith({
    String? id,
    String? userId,
    String? familyMemberId,
    String? name,
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
    DateTime? createdAt,
    FamilyMember? familyMember,
  }) {
    return Medicine(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      familyMemberId: familyMemberId ?? this.familyMemberId,
      name: name ?? this.name,
      batchNumber: batchNumber ?? this.batchNumber,
      manufacturer: manufacturer ?? this.manufacturer,
      mfgDate: mfgDate ?? this.mfgDate,
      expiryDate: expiryDate ?? this.expiryDate,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      location: location ?? this.location,
      dateOpened: dateOpened ?? this.dateOpened,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      imageFrontUrl: imageFrontUrl ?? this.imageFrontUrl,
      imageBackUrl: imageBackUrl ?? this.imageBackUrl,
      createdAt: createdAt ?? this.createdAt,
      familyMember: familyMember ?? this.familyMember,
    );
  }

  factory Medicine.fromJson(Map<String, dynamic> json, {FamilyMember? member}) {
    FamilyMember? parsedMember = member;
    if (parsedMember == null && json['family_members'] != null) {
      parsedMember = FamilyMember.fromJson(json['family_members'] as Map<String, dynamic>);
    }

    return Medicine(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      familyMemberId: json['family_member_id'] as String?,
      name: json['name'] as String,
      batchNumber: json['batch_number'] as String?,
      manufacturer: json['manufacturer'] as String?,
      mfgDate: json['mfg_date'] != null ? DateTime.parse(json['mfg_date'] as String) : null,
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      totalQuantity: (json['total_quantity'] as num).toInt(),
      remainingQuantity: (json['remaining_quantity'] as num).toInt(),
      unit: json['unit'] as String? ?? 'tablets',
      category: json['category'] as String? ?? 'General',
      location: json['location'] as String?,
      dateOpened: json['date_opened'] != null ? DateTime.parse(json['date_opened'] as String) : null,
      status: json['status'] as String? ?? 'active',
      notes: json['notes'] as String?,
      imageFrontUrl: json['image_front_url'] as String?,
      imageBackUrl: json['image_back_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      familyMember: parsedMember,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'family_member_id': familyMemberId,
      'name': name,
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
      'status': status,
      'notes': notes,
      'image_front_url': imageFrontUrl,
      'image_back_url': imageBackUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
