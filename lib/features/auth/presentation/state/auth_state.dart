import 'package:equatable/equatable.dart';
import 'package:food_mandu/features/auth/domain/entities/auth_entity.dart';


enum AuthStatus{initial, loading, authenticated,loaded, unauthenticated,registered, error}

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? authEntity;
  final String? errorMessage;
  final String? uploadedPhotoUrl;

  const AuthState({
    this.status = AuthStatus.initial,
    this.authEntity,
    this.errorMessage,
    this.uploadedPhotoUrl,
  });

  //copywith
  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? authEntity,
    String? errorMessage,
    String? uploadedPhotoUrl,
    bool resetUploadedPhotoUrl = false,
  }){
    return AuthState(
      status: status?? this.status,
      authEntity: authEntity?? this.authEntity,
      errorMessage: errorMessage?? this.errorMessage,
       uploadedPhotoUrl: resetUploadedPhotoUrl
          ? null
          : (uploadedPhotoUrl ?? this.uploadedPhotoUrl),
    );
  }
 @override
 List<Object?> get props => [status,authEntity,errorMessage,uploadedPhotoUrl];
}