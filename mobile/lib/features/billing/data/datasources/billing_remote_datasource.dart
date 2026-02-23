// lib/features/billing/data/datasources/billing_remote_datasource.dart

import 'package:caller_host_app/core/services/api_client.dart';
import 'package:caller_host_app/features/billing/data/models/billing_model.dart';

abstract class BillingRemoteDataSource {
  Future<BalanceModel> fetchBalance();

  Future<BalanceModel> purchaseCredits({
    required double amount,
    required double price,
  });

  Future<List<TransactionModel>> fetchTransactionHistory();

  Future<BalanceModel> preAuthorizeCredits({required double amount});

  Future<void> releasePreAuthorization({required double amount});
}

class BillingRemoteDataSourceImpl implements BillingRemoteDataSource {
  final ApiClient apiClient;

  BillingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<BalanceModel> fetchBalance() async {
    try {
      final response = await apiClient.get('/api/billing/balance');

      if (response.statusCode == 200) {
        final data = response.body;
        return BalanceModel.fromJson(data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch balance: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching balance: $e');
    }
  }

  @override
  Future<BalanceModel> purchaseCredits({
    required double amount,
    required double price,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/billing/purchase',
        body: {
          'amount': amount,
          'price': price,
        },
      );

      if (response.statusCode == 200) {
        final data = response.body;
        return BalanceModel.fromJson(data as Map<String, dynamic>);
      } else if (response.statusCode == 402) {
        throw Exception('Insufficient funds');
      } else {
        throw Exception('Failed to purchase credits: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error purchasing credits: $e');
    }
  }

  @override
  Future<List<TransactionModel>> fetchTransactionHistory() async {
    try {
      final response = await apiClient.get('/api/billing/history');

      if (response.statusCode == 200) {
        final data = response.body;
        
        // Handle response - could be a list or a map with transactions
        List<dynamic> transactions = data is List
            ? data
            : (data is Map && data['transactions'] != null
                ? data['transactions']
                : []);

        return transactions
            .map((t) => TransactionModel.fromJson(t as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch transaction history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching transaction history: $e');
    }
  }

  @override
  Future<BalanceModel> preAuthorizeCredits({required double amount}) async {
    try {
      final response = await apiClient.post(
        '/api/billing/pre-authorize',
        body: {'amount': amount},
      );

      if (response.statusCode == 200) {
        final data = response.body;
        return BalanceModel.fromJson(data as Map<String, dynamic>);
      } else {
        throw Exception(
            'Failed to pre-authorize credits: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error pre-authorizing credits: $e');
    }
  }

  @override
  Future<void> releasePreAuthorization({required double amount}) async {
    try {
      final response = await apiClient.post(
        '/api/billing/release-pre-auth',
        body: {'amount': amount},
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to release pre-authorization: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error releasing pre-authorization: $e');
    }
  }
}
