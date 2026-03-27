enum UnitSystem { metric, imperial }

class UserSettings {
  const UserSettings({
    required this.userId,
    required this.unitSystem,
    required this.aiScansUsed,
    required this.isPremium,
    required this.createdAt,
    this.ravelryToken,
  });

  final String userId;
  final UnitSystem unitSystem;
  final int aiScansUsed;
  final bool isPremium;
  final String? ravelryToken;
  final DateTime createdAt;

  bool get hasRavelry => (ravelryToken ?? '').isNotEmpty;

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      userId: map['user_id'] as String,
      unitSystem: (map['unit_system'] as String?) == 'imperial'
          ? UnitSystem.imperial
          : UnitSystem.metric,
      aiScansUsed: (map['ai_scans_used'] as num?)?.toInt() ?? 0,
      isPremium: map['is_premium'] as bool? ?? false,
      ravelryToken: map['ravelry_token'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'unit_system': unitSystem.name,
      'ai_scans_used': aiScansUsed,
      'is_premium': isPremium,
      'ravelry_token': ravelryToken,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserSettings copyWith({
    UnitSystem? unitSystem,
    int? aiScansUsed,
    bool? isPremium,
    String? ravelryToken,
    bool clearRavelryToken = false,
  }) {
    return UserSettings(
      userId: userId,
      unitSystem: unitSystem ?? this.unitSystem,
      aiScansUsed: aiScansUsed ?? this.aiScansUsed,
      isPremium: isPremium ?? this.isPremium,
      ravelryToken: clearRavelryToken ? null : (ravelryToken ?? this.ravelryToken),
      createdAt: createdAt,
    );
  }
}

