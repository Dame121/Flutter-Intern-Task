// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'dart:convert';
import 'package:caller_host_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:caller_host_app/features/auth/data/models/user_model.dart';
import 'package:caller_host_app/features/auth/domain/entities/user_entity.dart';
import 'package:caller_host_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:caller_host_app/core/services/secure_storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorage;
  
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });
  
  @override
  Future<AuthResultEntity> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    final response = await remoteDataSource.register(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
    );
    
    // Save tokens and user data
    await _saveAuthData(response);
    
    return AuthResultEntity(
      user: response.user,
      token: AuthTokenEntity(
        accessToken: response.token.accessToken,
        refreshToken: response.token.refreshToken,
        expiresAt: response.token.expiresAt,
      ),
    );
  }
  
  @override
  Future<AuthResultEntity> login({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    final response = await remoteDataSource.login(
      email: email,
      password: password,
      fcmToken: fcmToken,
    );
    
    // Save tokens and user data
    await _saveAuthData(response);
    
    return AuthResultEntity(
      user: response.user,
      token: AuthTokenEntity(
        accessToken: response.token.accessToken,
        refreshToken: response.token.refreshToken,
        expiresAt: response.token.expiresAt,
      ),
    );
  }
  
  @override
  Future<AuthTokenEntity> refreshToken({
    required String refreshToken,
  }) async {
    final response = await remoteDataSource.refreshToken(
      refreshToken: refreshToken,
    );
    
    // Update token
    await secureStorage.saveToken(response.accessToken);
    
    return AuthTokenEntity(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      expiresAt: response.expiresAt,
    );
  }
  
  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } finally {
      await secureStorage.clearAll();
    }
  }
  
  @override
  Future<bool> isLoggedIn() async {
    return await secureStorage.hasValidSession();
  }
  
  @override
  Future<UserEntity?> getCurrentUser() async {
    final userDataJson = await secureStorage.getUserData();
    if (userDataJson == null) return null;
    
    try {
      final userMap = jsonDecode(userDataJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }
  
  Future<void> _saveAuthData(AuthResponseModel response) async {
    await secureStorage.saveToken(response.token.accessToken);
    await secureStorage.saveRefreshToken(response.token.refreshToken);
    await secureStorage.saveUserId(response.user.id);
    await secureStorage.saveUserRole(response.user.role);
    await secureStorage.saveUserData(jsonEncode(response.user.toJson()));
  }
}
