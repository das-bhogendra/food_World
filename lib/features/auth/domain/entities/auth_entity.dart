import 'package:equatable/equatable.dart';


class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? batchId;
  final String username;
  final String password;
  final String confirmPassword;
  final String role;
  
  final String? profilePicture;
  final DateTime? createdAt; 

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.batchId,
    required this.username,
    required this.password,
    required this.confirmPassword,
    required this.role,
    this.profilePicture,
     this.createdAt,
  });


  @override

  List<Object?> get props =>[authId,fullName,email,phoneNumber,batchId,username,password,confirmPassword,role,profilePicture,createdAt];
}