class MedicineHistory {
  final String id;
  final String medicineId;
  final String eventType; // 'added', 'taken', 'updated', 'archived'
  final int quantityChange;
  final String? notes;
  final DateTime createdAt;

  MedicineHistory({
    required this.id,
    required this.medicineId,
    required this.eventType,
    required this.quantityChange,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MedicineHistory.fromJson(Map<String, dynamic> json) {
    return MedicineHistory(
      id: json['id'] as String,
      medicineId: json['medicine_id'] as String,
      eventType: json['event_type'] as String,
      quantityChange: (json['quantity_change'] as num? ?? 0).toInt(),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicine_id': medicineId,
      'event_type': eventType,
      'quantity_change': quantityChange,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get title {
    switch (eventType) {
      case 'added':
        return 'Medicine Added';
      case 'taken':
        return 'Dose Consumed';
      case 'updated':
        return 'Details Updated';
      case 'archived':
        return 'Medicine Archived';
      default:
        return 'Activity Logged';
    }
  }

  String get description {
    switch (eventType) {
      case 'added':
        return notes ?? 'Added new medicine to family inventory.';
      case 'taken':
        return 'Consumed $quantityChange dose${quantityChange > 1 ? "s" : ""}.${notes != null ? " $notes" : ""}';
      case 'updated':
        return notes ?? 'Updated record information.';
      case 'archived':
        return notes ?? 'Archived from active inventory.';
      default:
        return notes ?? 'Event recorded.';
    }
  }
}
