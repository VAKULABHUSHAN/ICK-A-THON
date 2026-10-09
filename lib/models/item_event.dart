class ItemEvent {
  final String id;
  final String itemId;
  final String eventType; // 'added', 'split', 'location_changed', 'recalled', 'updated'
  final Map<String, dynamic> details;
  final DateTime createdAt;

  ItemEvent({
    required this.id,
    required this.itemId,
    required this.eventType,
    required this.details,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ItemEvent.fromJson(Map<String, dynamic> json) {
    return ItemEvent(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      eventType: json['event_type'] as String,
      details: json['details'] is Map 
          ? Map<String, dynamic>.from(json['details'] as Map)
          : {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'event_type': eventType,
      'details': details,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get title {
    switch (eventType) {
      case 'added':
        return 'Medicine Registered';
      case 'split':
        return 'Portion Split Executed';
      case 'location_changed':
        return 'Storage Location Updated';
      case 'recalled':
        return 'Batch Recall Issued';
      case 'updated':
        return 'Record Updated';
      default:
        return 'Item Activity';
    }
  }

  String get description {
    final medName = details['medicine_name'] ?? details['medicineName'] ?? 'Item';
    final qty = details['quantity'];
    final unit = details['unit'] ?? 'units';
    final loc = details['location'];

    switch (eventType) {
      case 'added':
        return 'Added $qty $unit of $medName${loc != null ? ' to $loc' : ''}.';
      case 'split':
        final parentQty = details['parent_quantity'] ?? 'original';
        final childAQty = details['child_a_quantity'];
        final childBQty = details['child_b_quantity'];
        return 'Split $parentQty $unit of $medName into portions of $childAQty and $childBQty.';
      case 'location_changed':
        return 'Moved $medName to ${loc ?? "new location"}.';
      case 'recalled':
        return 'Batch ${details['batch_number'] ?? ''} flagged as RECALLED. Warning active.';
      default:
        return details['message'] ?? 'Activity recorded for $medName.';
    }
  }
}
