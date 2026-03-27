class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final int targetScore;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.targetScore,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      role: json['role'],
      targetScore: json['target_score'] ?? 0,
    );
  }
}