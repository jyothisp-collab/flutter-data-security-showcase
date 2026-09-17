import 'dart:convert';

class AppProfile {
  const AppProfile({
    required this.id,
    required this.displayName,
    required this.note,
    required this.updatedAt,
  });

  final String id;
  final String displayName;
  final String note;
  final DateTime updatedAt;

  AppProfile copyWith({
    String? displayName,
    String? note,
    DateTime? updatedAt,
  }) {
    return AppProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'note': note,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static AppProfile fromJson(Map<String, Object?> json) {
    return AppProfile(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      note: json['note'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String encode() => jsonEncode(toJson());

  static AppProfile decode(String value) {
    return fromJson(jsonDecode(value) as Map<String, Object?>);
  }
}
