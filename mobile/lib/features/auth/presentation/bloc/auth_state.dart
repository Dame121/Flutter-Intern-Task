// lib/features/auth/presentation/bloc/auth_state.dart

import 'package:equatable/equatable.dart';
import 'package:caller_host_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

class AuthCheckingState extends AuthState {
  const AuthCheckingState();
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

class AuthSuccessState extends AuthState {
  final UserEntity user;
  final String role;
  
  const AuthSuccessState({
    required this.user,
    required this.role,
  });
  
  @override
  List<Object?> get props => [user, role];
}

class AuthFailureState extends AuthState {
  final String message;
  
  const AuthFailureState({required this.message});
  
  @override
  List<Object?> get props => [message];
}

class AuthLoggedOutState extends AuthState {
  const AuthLoggedOutState();
}

class AuthUnauthenticatedState extends AuthState {
  const AuthUnauthenticatedState();
}
