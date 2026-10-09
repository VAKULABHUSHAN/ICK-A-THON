import 'medicine_batch.dart';

enum ItemStatus {
  active,
  split,
  archived,
}

extension ItemStatusX on ItemStatus {
  String toDbString() {
    switch (this) {
      case ItemStatus.active:
        return 'active';
      case ItemStatus.split:
        return 'split';
      case ItemStatus.archived:
        return 'archived';
    }
  }

  static ItemStatus fromDbString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return ItemStatus.active;
      case 'split':
        return ItemStatus.split;
      case 'archived':
        return ItemStatus.archived;
      default:
        return ItemStatus.active;
    }
  }
}

class MedicineItem {
  final String id;
  final String batchId;
  final String? parentItemId;
  final int quantity;
  final String unit; // 'tablets', 'capsules', 'bottles', 'other'
  final String? location;
  final String? imagePath;
  final ItemStatus status;
  final DateTime createdAt;
  final MedicineBatch? batch;

  MedicineItem({
    required this.id,
    required this.batchId,
    this.parentItemId,
    required this.quantity,
    required this.unit,
    this.location,
    this.imagePath,
    this.status = ItemStatus.active,
    DateTime? createdAt,
    this.batch,
  }) : createdAt = createdAt ?? DateTime.now();

  MedicineItem copyWith({
    String? id,
    String? batchId,
    String? parentItemId,
    int? quantity,
    String? unit,
    String? location,
    String? imagePath,
    ItemStatus? status,
    DateTime? createdAt,
    MedicineBatch? batch,
  }) {
    return MedicineItem(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      parentItemId: parentItemId ?? this.parentItemId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      location: location ?? this.location,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      batch: batch ?? this.batch,
    );
  }

  factory MedicineItem.fromJson(Map<String, dynamic> json, {MedicineBatch? batch}) {
    MedicineBatch? parsedBatch = batch;
    if (parsedBatch == null && json['batches'] != null) {
      parsedBatch = MedicineBatch.fromJson(json['batches'] as Map<String, dynamic>);
    }

    return MedicineItem(
      id: json['id'] as String,
      batchId: json['batch_id'] as String,
      parentItemId: json['parent_item_id'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      unit: json['unit'] as String? ?? 'tablets',
      location: json['location'] as String?,
      imagePath: json['image_path'] as String?,
      status: ItemStatusX.fromDbString(json['status'] as String? ?? 'active'),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      batch: parsedBatch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_id': batchId,
      'parent_item_id': parentItemId,
      'quantity': quantity,
      'unit': unit,
      'location': location,
      'image_path': imagePath,
      'status': status.toDbString(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
