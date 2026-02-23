// lib/features/auth/domain/entities/user_entity.dart

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String role; // 'caller' or 'host'
  final String? profilePhotoUrl;
  final DateTime createdAt;
  final bool isOnline;
  
  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.profilePhotoUrl,
    required this.createdAt,
    this.isOnline = false,
  });
  
  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    role,
    profilePhotoUrl,
    createdAt,
    isOnline,
  ];
}

class AuthTokenEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  
  const AuthTokenEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });
  
  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt];
}

class AuthResultEntity extends Equatable {
  final UserEntity user;
  final AuthTokenEntity token;
  
  const AuthResultEntity({
    required this.user,
    required this.token,
  });
  
  @override
  List<Object?> get props => [user, token];
}
