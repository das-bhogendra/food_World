import 'package:food_mandu/features/auth/domain/entities/auth_entity.dart';
import 'package:hive/hive.dart';


import 'package:uuid/uuid.dart';
import 'package:food_mandu/core/constants/hive_table_constant.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String authId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? phoneNumber;

  @HiveField(4)
  final String? batchId;

  @HiveField(5)
  final String username;

  @HiveField(6)
  final String? password;

  @HiveField(7)
  final String? profilePicture;

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.batchId,
    required this.username,
    this.password,
    this.profilePicture,
  }) : authId = authId ?? const Uuid().v4();

  /// ================= FACTORY FROM ENTITY =================
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      batchId: entity.batchId,
      username: entity.username,
      password: entity.password,
      profilePicture: entity.profilePicture,
    );
  }

  /// ================= TO ENTITY =================
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      batchId: batchId,
      username: username,
      password: password,
      profilePicture: profilePicture,
    );
  }

  /// ================= TO ENTITY LIST =================
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
