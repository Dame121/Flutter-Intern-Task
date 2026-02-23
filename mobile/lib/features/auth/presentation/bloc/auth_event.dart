// lib/features/auth/presentation/bloc/auth_event.dart

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  final String role; // 'caller' or 'host'
  
  const RegisterEvent({
    required this.email,
    required this.password,
    required this.displayName,
    required this.role,
  });
  
  @override
  List<Object?> get props => [email, password, displayName, role];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final String? fcmToken;
  
  const LoginEvent({
    required this.email,
    required this.password,
    this.fcmToken,
  });
  
  @override
  List<Object?> get props => [email, password, fcmToken];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class RefreshTokenEvent extends AuthEvent {
  final String refreshToken;
  
  const RefreshTokenEvent({required this.refreshToken});
  
  @override
  List<Object?> get props => [refreshToken];
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}
