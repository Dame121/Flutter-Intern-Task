// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:caller_host_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:caller_host_app/core/services/secure_storage_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final SecureStorageService secureStorage;
  
  AuthBloc({
    required this.authRepository,
    required this.secureStorage,
  }) : super(const AuthInitialState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<RefreshTokenEvent>(_onRefreshToken);
  }
  
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthCheckingState());
    try {
      final isLoggedIn = await authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          final role = await secureStorage.getUserRole();
          emit(AuthSuccessState(user: user, role: role ?? 'caller'));
        } else {
          emit(const AuthUnauthenticatedState());
        }
      } else {
        emit(const AuthUnauthenticatedState());
      }
    } catch (e) {
      emit(const AuthUnauthenticatedState());
    }
  }
  
  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      final result = await authRepository.register(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
        role: event.role,
      );
      
      emit(AuthSuccessState(user: result.user, role: event.role));
    } catch (e) {
      emit(AuthFailureState(message: e.toString()));
    }
  }
  
  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      final result = await authRepository.login(
        email: event.email,
        password: event.password,
        fcmToken: event.fcmToken,
      );
      
      emit(AuthSuccessState(user: result.user, role: result.user.role));
    } catch (e) {
      emit(AuthFailureState(message: e.toString()));
    }
  }
  
  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await authRepository.logout();
      emit(const AuthLoggedOutState());
    } catch (e) {
      emit(AuthFailureState(message: 'Logout failed: ${e.toString()}'));
    }
  }
  
  Future<void> _onRefreshToken(
    RefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await authRepository.refreshToken(refreshToken: event.refreshToken);
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        final role = await secureStorage.getUserRole();
        emit(AuthSuccessState(user: user, role: role ?? 'caller'));
      }
    } catch (e) {
      emit(AuthFailureState(message: 'Token refresh failed: ${e.toString()}'));
    }
  }
}
