import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
class AppProfile {
  const AppProfile({
    required this.id,
    required this.displayName,
    required this.note,
    required this.updatedAt,
  });

  factory AppProfile.fromJson(Map<String, Object?> json) {
    return AppProfile(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      note: json['note'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  factory AppProfile.decode(String value) {
    return AppProfile.fromJson(
      jsonDecode(value) as Map<String, Object?>,
    );
  }

  final String id;
  final String displayName;
  final String note;
  final DateTime updatedAt;

  AppProfile copyWith({
    String? id,
    String? displayName,
    String? note,
    DateTime? updatedAt,
  }) {
    return AppProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'displayName': displayName,
      'note': note,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String encode() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          displayName == other.displayName &&
          note == other.note &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(id, displayName, note, updatedAt);

  @override
  String toString() =>
      'AppProfile{id: $id, displayName: $displayName, note: $note, '
      'updatedAt: $updatedAt}';
}
