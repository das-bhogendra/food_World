import 'package:food_mandu/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String username;
  final String? phoneNumber;
  final String role;
  final String password; // REQUIRED for registration
  final String confirmPassword; // match backend
  final String? profilePicture;
  final DateTime? createdAt;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.username,
    this.phoneNumber,
    required this.role,
    required this.password,
    required this.confirmPassword,
    this.profilePicture,
    this.createdAt,
  });

  // 🔁 TO JSON (Send to Backend)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "fullName": fullName,
      "email": email,
      "username": username,
      "role": role,
      "password": password,
      "confirmPassword": confirmPassword, // <-- fixed
    };
    if (phoneNumber != null) data["phoneNumber"] = phoneNumber;
    if (profilePicture != null) data["profilePicture"] = profilePicture;
    return data;
  }

  // 🔁 FROM JSON (From Backend)
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'] as String?,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      role: json['role'] as String,
      password: json['password'] ?? '', // backend might not return password
      confirmPassword: json['confirmPassword'] ?? '', // <-- fixed
      profilePicture: json['profilePicture'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  // 🔁 TO ENTITY
  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: email,
      username: username,
      phoneNumber: phoneNumber,
      role: role,
      password: password,
      confirmPassword: confirmPassword, // <-- fixed
      profilePicture: profilePicture,
      createdAt: createdAt,
    );
  }

  // 🔁 FROM ENTITY
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      username: entity.username,
      phoneNumber: entity.phoneNumber,
      role: entity.role,
      password: entity.password,
      confirmPassword: entity.confirmPassword, // <-- fixed
      profilePicture: entity.profilePicture,
      createdAt: entity.createdAt,
    );
  }
}
