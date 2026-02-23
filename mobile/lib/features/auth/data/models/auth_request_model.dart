// lib/features/auth/data/models/auth_request_model.dart

class RegisterRequestModel {
  final String email;
  final String password;
  final String displayName;
  final String role; // 'caller' or 'host'
  
  RegisterRequestModel({
    required this.email,
    required this.password,
    required this.displayName,
    required this.role,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'displayName': displayName,
      'role': role,
    };
  }
}

class LoginRequestModel {
  final String email;
  final String password;
  final String? fcmToken;
  
  LoginRequestModel({
    required this.email,
    required this.password,
    this.fcmToken,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }
}

class RefreshTokenRequestModel {
  final String refreshToken;
  
  RefreshTokenRequestModel({required this.refreshToken});
  
  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}
