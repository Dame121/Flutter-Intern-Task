// lib/features/billing/domain/repositories/billing_repository.dart

import 'package:caller_host_app/features/billing/domain/entities/billing_entity.dart';

abstract class BillingRepository {
  Future<BalanceEntity> getBalance();

  Future<BalanceEntity> purchaseCredits({
    required double amount,
    required double price,
  });

  Future<List<TransactionEntity>> getTransactionHistory();

  Future<BalanceEntity> preAuthorizeCredits({required double amount});

  Future<void> releasePreAuthorization({required double amount});
}
