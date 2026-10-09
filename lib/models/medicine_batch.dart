class MedicineBatch {
  final String id;
  final String medicineName;
  final String batchNumber;
  final DateTime expiryDate;
  final String? manufacturer;
  final bool isRecalled;
  final String? recallReason;
  final DateTime createdAt;

  MedicineBatch({
    required this.id,
    required this.medicineName,
    required this.batchNumber,
    required this.expiryDate,
    this.manufacturer,
    this.isRecalled = false,
    this.recallReason,
    DateTime? createdAt,
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
    final differenceInDays = exp.difference(today).inDays;
    return differenceInDays >= 0 && differenceInDays <= 30;
  }

  int get daysUntilExpiry {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return exp.difference(today).inDays;
  }

  MedicineBatch copyWith({
    String? id,
    String? medicineName,
    String? batchNumber,
    DateTime? expiryDate,
    String? manufacturer,
    bool? isRecalled,
    String? recallReason,
    DateTime? createdAt,
  }) {
    return MedicineBatch(
      id: id ?? this.id,
      medicineName: medicineName ?? this.medicineName,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      manufacturer: manufacturer ?? this.manufacturer,
      isRecalled: isRecalled ?? this.isRecalled,
      recallReason: recallReason ?? this.recallReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory MedicineBatch.fromJson(Map<String, dynamic> json) {
    return MedicineBatch(
      id: json['id'] as String,
      medicineName: json['medicine_name'] as String,
      batchNumber: json['batch_number'] as String,
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      manufacturer: json['manufacturer'] as String?,
      isRecalled: json['is_recalled'] as bool? ?? false,
      recallReason: json['recall_reason'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicine_name': medicineName,
      'batch_number': batchNumber,
      'expiry_date': expiryDate.toIso8601String().split('T')[0],
      'manufacturer': manufacturer,
      'is_recalled': isRecalled,
      'recall_reason': recallReason,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
