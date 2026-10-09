import 'package:flutter/material.dart';

class FamilyMember {
  final String id;
  final String name;
  final String relation;
  final String? avatarUrl;
  final String? notes;
  final DateTime createdAt;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    this.avatarUrl,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  FamilyMember copyWith({
    String? id,
    String? name,
    String? relation,
    String? avatarUrl,
    String? notes,
    DateTime? createdAt,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String,
      name: json['name'] as String,
      relation: json['relation'] as String? ?? 'Family',
      avatarUrl: json['avatar_url'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relation': relation,
      'avatar_url': avatarUrl,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  IconData get defaultIcon {
    final lowerName = name.toLowerCase();
    final lowerRel = relation.toLowerCase();
    if (lowerName.contains('grandma') || lowerRel.contains('grandmother')) {
      return Icons.elderly_woman_rounded;
    } else if (lowerName.contains('grandpa') || lowerRel.contains('grandfather')) {
      return Icons.elderly_rounded;
    } else if (lowerName.contains('dad') || lowerRel.contains('father')) {
      return Icons.face_5_rounded;
    } else if (lowerName.contains('mom') || lowerRel.contains('mother')) {
      return Icons.face_3_rounded;
    } else if (lowerName.contains('sister') || lowerName.contains('daughter')) {
      return Icons.face_4_rounded;
    } else if (lowerName.contains('son') || lowerName.contains('brother')) {
      return Icons.face_6_rounded;
    }
    return Icons.person_rounded;
  }

  Color get avatarBgColor {
    final hash = name.hashCode;
    final colors = [
      const Color(0xFF6516D5),
      const Color(0xFF0284C7),
      const Color(0xFF10B981),
      const Color(0xFFD97706),
      const Color(0xFFE11D48),
      const Color(0xFF8B5CF6),
    ];
    return colors[hash.abs() % colors.length];
  }
}
