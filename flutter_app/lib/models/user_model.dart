class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final int targetScore;
  final String membershipPlan;
  final bool isPremium;
  final String? premiumStartedAt;
  final String? premiumExpiresAt;
  final bool premiumCancelAtPeriodEnd;
  final Map<String, dynamic>? latestPremiumRequest;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.targetScore,
    required this.membershipPlan,
    required this.isPremium,
    this.premiumStartedAt,
    this.premiumExpiresAt,
    required this.premiumCancelAtPeriodEnd,
    this.latestPremiumRequest,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value, [int fallback = 0]) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    bool toBool(dynamic value) {
      if (value is bool) return value;
      final normalized = value?.toString().trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }

    return UserModel(
      id: toInt(json['id']),
      fullName: (json['full_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'user').toString(),
      targetScore: toInt(json['target_score']),
      membershipPlan: (json['membership_plan'] ?? 'basic').toString(),
      isPremium: toBool(json['is_premium']),
      premiumStartedAt: json['premium_started_at']?.toString(),
      premiumExpiresAt: json['premium_expires_at']?.toString(),
      premiumCancelAtPeriodEnd: toBool(json['premium_cancel_at_period_end']),
      latestPremiumRequest: json['latest_premium_request'] is Map
          ? Map<String, dynamic>.from(json['latest_premium_request'])
          : null,
    );
  }
}
