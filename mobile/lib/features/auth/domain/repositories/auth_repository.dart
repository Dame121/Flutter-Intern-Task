// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:caller_host_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<AuthResultEntity> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
  });
  
  Future<AuthResultEntity> login({
    required String email,
    required String password,
    String? fcmToken,
  });
  
  Future<AuthTokenEntity> refreshToken({
    required String refreshToken,
  });
  
  Future<void> logout();
  
  Future<bool> isLoggedIn();
  
  Future<UserEntity?> getCurrentUser();
}
