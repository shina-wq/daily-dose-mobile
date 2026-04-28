class UserModel {
  final String uid;
  final String name;
  final String email;
  final int age;
  final String? gender;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.age,
    this.gender,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'],
    );
  }
}