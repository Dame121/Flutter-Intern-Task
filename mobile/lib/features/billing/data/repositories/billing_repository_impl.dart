// lib/features/billing/data/repositories/billing_repository_impl.dart

import 'package:caller_host_app/features/billing/data/datasources/billing_remote_datasource.dart';
import 'package:caller_host_app/features/billing/domain/entities/billing_entity.dart';
import 'package:caller_host_app/features/billing/domain/repositories/billing_repository.dart';

class BillingRepositoryImpl implements BillingRepository {
  final BillingRemoteDataSource remoteDataSource;

  BillingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<BalanceEntity> getBalance() async {
    return await remoteDataSource.fetchBalance();
  }

  @override
  Future<BalanceEntity> purchaseCredits({
    required double amount,
    required double price,
  }) async {
    return await remoteDataSource.purchaseCredits(
      amount: amount,
      price: price,
    );
  }

  @override
  Future<List<TransactionEntity>> getTransactionHistory() async {
    return await remoteDataSource.fetchTransactionHistory();
  }

  @override
  Future<BalanceEntity> preAuthorizeCredits({required double amount}) async {
    return await remoteDataSource.preAuthorizeCredits(amount: amount);
  }

  @override
  Future<void> releasePreAuthorization({required double amount}) async {
    await remoteDataSource.releasePreAuthorization(amount: amount);
  }
}
