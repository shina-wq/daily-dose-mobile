class ProfileModel {
  const ProfileModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.age,
    this.gender,
    this.conditionSummary,
    this.careTeamSummary,
    this.healthLogsSummary,
    this.avatarUrl,
    this.onboarding,
  });

  final String uid;
  final String name;
  final String email;
  final int age;
  final String? gender;
  final String? conditionSummary;
  final String? careTeamSummary;
  final String? healthLogsSummary;
  final String? avatarUrl;
  final Map<String, dynamic>? onboarding;

  ProfileModel copyWith({
    String? uid,
    String? name,
    String? email,
    int? age,
    String? gender,
    String? conditionSummary,
    String? careTeamSummary,
    String? healthLogsSummary,
    String? avatarUrl,
    Map<String, dynamic>? onboarding,
  }) {
    return ProfileModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      conditionSummary: conditionSummary ?? this.conditionSummary,
      careTeamSummary: careTeamSummary ?? this.careTeamSummary,
      healthLogsSummary: healthLogsSummary ?? this.healthLogsSummary,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      onboarding: onboarding ?? this.onboarding,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'profile': {
        'conditionSummary': conditionSummary,
        'careTeamSummary': careTeamSummary,
        'healthLogsSummary': healthLogsSummary,
        'avatarUrl': avatarUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      'onboarding': onboarding,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    final profileMap = (map['profile'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};

    return ProfileModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      age: (map['age'] as num?)?.toInt() ?? 0,
      gender: map['gender'] as String?,
      conditionSummary: profileMap['conditionSummary'] as String?,
      careTeamSummary: profileMap['careTeamSummary'] as String?,
      healthLogsSummary: profileMap['healthLogsSummary'] as String?,
      avatarUrl: profileMap['avatarUrl'] as String?,
      onboarding: (map['onboarding'] as Map?)?.cast<String, dynamic>(),
    );
  }

  factory ProfileModel.empty({
    required String uid,
    required String email,
  }) {
    return ProfileModel(
      uid: uid,
      name: '',
      email: email,
      age: 0,
    );
  }
}