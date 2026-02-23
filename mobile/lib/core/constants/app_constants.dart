// lib/core/constants/app_constants.dart

class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:3000/api';
  static const String socketUrl = 'http://localhost:3001';
  
  // Timeouts
  static const int apiTimeout = 30; // seconds
  static const int socketTimeout = 10; // seconds
  
  // User Roles
  static const String roleCallerValue = 'caller';
  static const String roleHostValue = 'host';
  
  // Call Durations
  static const int minCallDuration = 60; // seconds
  static const int callTimeoutDuration = 30; // seconds
  static const int reconnectTimeout = 10; // seconds
  
  // Billing
  static const double platformCommission = 0.20; // 20% platform cut
  
  // Agora
  static const String agoraAppId = 'YOUR_AGORA_APP_ID';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String userDataKey = 'user_data';
  static const String fcmTokenKey = 'fcm_token';
  
  // Error Messages
  static const String networkError = 'Network error occurred';
  static const String unauthorized = 'Unauthorized access';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'Unknown error occurred';
}

class ApiEndpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  
  // User
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String hostProfile = '/users/host/:id';
  
  // Discovery
  static const String discoverHosts = '/discovery/hosts';
  static const String searchHosts = '/discovery/hosts/search';
  
  // Billing
  static const String purchaseCredits = '/billing/purchase';
  static const String creditBalance = '/billing/balance';
  static const String transactionHistory = '/billing/history';
  static const String hostEarnings = '/billing/earnings';
  
  // Chat
  static const String chatHistory = '/chat/messages/:hostId';
  static const String sendMessage = '/chat/messages';
  
  // Call
  static const String initiateCall = '/calls/initiate';
  static const String respondCall = '/calls/respond';
  static const String getRtcToken = '/calls/rtc-token';
  static const String endCall = '/calls/end';
  static const String callHistory = '/calls/history';
  
  // Notifications
  static const String registerFcmToken = '/notifications/register-token';
}
