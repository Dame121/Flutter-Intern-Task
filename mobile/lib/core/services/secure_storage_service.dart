// lib/core/services/secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caller_host_app/core/constants/app_constants.dart';

class SecureStorageService {
  static const _secureStorage = FlutterSecureStorage();
  late SharedPreferences _preferences;
  
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }
  
  // Token Management
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }
  
  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }
  
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: token);
  }
  
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.refreshTokenKey);
  }
  
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }
  
  // User Data
  Future<void> saveUserId(String userId) async {
    await _preferences.setString(AppConstants.userIdKey, userId);
  }
  
  Future<String?> getUserId() async {
    return _preferences.getString(AppConstants.userIdKey);
  }
  
  Future<void> saveUserRole(String role) async {
    await _preferences.setString(AppConstants.userRoleKey, role);
  }
  
  Future<String?> getUserRole() async {
    return _preferences.getString(AppConstants.userRoleKey);
  }
  
  Future<void> saveUserData(String userData) async {
    await _preferences.setString(AppConstants.userDataKey, userData);
  }
  
  Future<String?> getUserData() async {
    return _preferences.getString(AppConstants.userDataKey);
  }
  
  // FCM Token
  Future<void> saveFcmToken(String token) async {
    await _preferences.setString(AppConstants.fcmTokenKey, token);
  }
  
  Future<String?> getFcmToken() async {
    return _preferences.getString(AppConstants.fcmTokenKey);
  }
  
  // Clear All
  Future<void> clearAll() async {
    await clearTokens();
    await _preferences.remove(AppConstants.userIdKey);
    await _preferences.remove(AppConstants.userRoleKey);
    await _preferences.remove(AppConstants.userDataKey);
    await _preferences.remove(AppConstants.fcmTokenKey);
  }
  
  // Session Check
  Future<bool> hasValidSession() async {
    final token = await getToken();
    final userId = await getUserId();
    return token != null && userId != null;
  }
}
