// lib/features/auth/data/datasources/auth_remote_datasource.dart

import 'package:caller_host_app/core/constants/app_constants.dart';
import 'package:caller_host_app/core/services/api_client.dart';
import 'package:caller_host_app/features/auth/data/models/auth_request_model.dart';
import 'package:caller_host_app/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
  });
  
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    String? fcmToken,
  });
  
  Future<AuthTokenModel> refreshToken({
    required String refreshToken,
  });
  
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  
  AuthRemoteDataSourceImpl(this.apiClient);
  
  @override
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    final request = RegisterRequestModel(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
    );
    
    final response = await apiClient.post(
      ApiEndpoints.register,
      body: request.toJson(),
    );
    
    return AuthResponseModel.fromJson(response);
  }
  
  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    final request = LoginRequestModel(
      email: email,
      password: password,
      fcmToken: fcmToken,
    );
    
    final response = await apiClient.post(
      ApiEndpoints.login,
      body: request.toJson(),
    );
    
    return AuthResponseModel.fromJson(response);
  }
  
  @override
  Future<AuthTokenModel> refreshToken({
    required String refreshToken,
  }) async {
    final request = RefreshTokenRequestModel(refreshToken: refreshToken);
    
    final response = await apiClient.post(
      ApiEndpoints.refreshToken,
      body: request.toJson(),
    );
    
    return AuthTokenModel.fromJson(response);
  }
  
  @override
  Future<void> logout() async {
    await apiClient.post(ApiEndpoints.logout, body: {});
  }
}
