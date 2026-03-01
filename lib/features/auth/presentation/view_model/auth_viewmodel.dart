import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/features/auth/domain/usecases/login_usecase.dart';
import 'package:food_mandu/features/auth/domain/usecases/register_usecase.dart';
import 'package:food_mandu/features/auth/domain/usecases/uploadphoto_usecase.dart';
import 'package:food_mandu/features/auth/domain/usecases/logout_usecase.dart';
import 'package:food_mandu/features/auth/presentation/state/auth_state.dart';

/// ================= AUTH NOTIFIER =================
class AuthViewModel extends Notifier<AuthState> {
  final RegisterUsecase _registerUsecase;
  final LoginUsecase _loginUsecase;
  final UploadPhotoUsecase _uploadPhotoUsecase;
  final LogoutUsecase _logoutUsecase;

  /// ✅ Constructor injection
  AuthViewModel({
    required RegisterUsecase registerUsecase,
    required LoginUsecase loginUsecase,
    required UploadPhotoUsecase uploadPhotoUsecase,
    required LogoutUsecase logoutUsecase,
  })  : _registerUsecase = registerUsecase,
        _loginUsecase = loginUsecase,
        _uploadPhotoUsecase = uploadPhotoUsecase,
        _logoutUsecase = logoutUsecase;

  @override
  AuthState build() => const AuthState();

  /// ================= REGISTER =================
  Future<void> register({
    required String fullName,
    required String email,
    String? phoneNumber,
    String? batchId,
    required String username,
    required String password,
    required String confirmPassword,
    required String role,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final params = RegisterUsecaseParams(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      batchId: batchId,
      username: username,
      password: password,
      confirmPassword: confirmPassword,
      role: role,
    );

    final result = await _registerUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(status: AuthStatus.registered);
      },
    );
  }

  /// ================= LOGIN =================
  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final params = LoginUsecaseParams(
      username: username,
      password: password,
    );

    final result = await _loginUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }

  /// ================= UPLOAD PROFILE PHOTO =================
  Future<String?> uploadPhoto(File photo) async {
    state = state.copyWith(status: AuthStatus.loaded);

    final result = await _uploadPhotoUsecase(photo);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (url) {
        state = state.copyWith(
          status: AuthStatus.loading,
          uploadedPhotoUrl: url,
        );
        return url;
      },
    );
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase.call();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        // Clear the auth entity and reset state
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          authEntity: null,
          uploadedPhotoUrl: null,
        );
      },
    );
  }

  /// ================= CLEAR ERROR =================
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}