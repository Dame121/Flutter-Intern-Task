// lib/core/services/api_client.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:caller_host_app/core/constants/app_constants.dart';
import 'package:caller_host_app/core/services/secure_storage_service.dart';

class ApiClient {
  final http.Client _client;
  final SecureStorageService _secureStorage;
  
  ApiClient(this._client, this._secureStorage);
  
  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      
      final response = await _client
          .get(uri, headers: headers)
          .timeout(Duration(seconds: AppConstants.apiTimeout));
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(AppConstants.networkError);
    }
  }
  
  Future<dynamic> post(String endpoint, {required Map<String, dynamic> body}) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      
      final response = await _client
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(Duration(seconds: AppConstants.apiTimeout));
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(AppConstants.networkError);
    }
  }
  
  Future<dynamic> put(String endpoint, {required Map<String, dynamic> body}) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      
      final response = await _client
          .put(uri, headers: headers, body: jsonEncode(body))
          .timeout(Duration(seconds: AppConstants.apiTimeout));
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(AppConstants.networkError);
    }
  }
  
  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      
      final response = await _client
          .delete(uri, headers: headers)
          .timeout(Duration(seconds: AppConstants.apiTimeout));
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(AppConstants.networkError);
    }
  }
  
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw ApiException(AppConstants.unauthorized);
    } else if (response.statusCode >= 500) {
      throw ApiException(AppConstants.serverError);
    } else {
      final error = jsonDecode(response.body)['message'] ?? AppConstants.unknownError;
      throw ApiException(error);
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}
