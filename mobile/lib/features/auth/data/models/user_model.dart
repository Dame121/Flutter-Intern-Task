// lib/features/auth/data/models/user_model.dart

import 'dart:convert';
import 'package:caller_host_app/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required String id,
    required String email,
    required String displayName,
    required String role,
    String? profilePhotoUrl,
    required DateTime createdAt,
    bool isOnline = false,
  }) : super(
    id: id,
    email: email,
    displayName: displayName,
    role: role,
    profilePhotoUrl: profilePhotoUrl,
    createdAt: createdAt,
    isOnline: isOnline,
  );
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      role: json['role'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }
  
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      role: entity.role,
      profilePhotoUrl: entity.profilePhotoUrl,
      createdAt: entity.createdAt,
      isOnline: entity.isOnline,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role,
      'profilePhotoUrl': profilePhotoUrl,
      'createdAt': createdAt.toIso8601String(),
      'isOnline': isOnline,
    };
  }
  
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? role,
    String? profilePhotoUrl,
    DateTime? createdAt,
    bool? isOnline,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class AuthTokenModel {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  
  AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });
  
  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}

class AuthResponseModel {
  final UserModel user;
  final AuthTokenModel token;
  
  AuthResponseModel({
    required this.user,
    required this.token,
  });
  
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: AuthTokenModel.fromJson(json['token'] as Map<String, dynamic>),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token.toJson(),
    };
  }
}
