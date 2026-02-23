// lib/features/billing/presentation/bloc/billing_state.dart

import 'package:equatable/equatable.dart';
import 'package:caller_host_app/features/billing/domain/entities/billing_entity.dart';

abstract class BillingState extends Equatable {
  const BillingState();

  @override
  List<Object?> get props => [];
}

class BillingInitialState extends BillingState {
  const BillingInitialState();
}

class BillingLoadingState extends BillingState {
  const BillingLoadingState();
}

class BillingLoadedState extends BillingState {
  final BalanceEntity balance;
  final List<TransactionEntity> transactions;

  const BillingLoadedState({
    required this.balance,
    required this.transactions,
  });

  @override
  List<Object?> get props => [balance, transactions];
}

class BillingPurchaseSuccessState extends BillingState {
  final BalanceEntity newBalance;

  const BillingPurchaseSuccessState({required this.newBalance});

  @override
  List<Object?> get props => [newBalance];
}

class BillingErrorState extends BillingState {
  final String message;

  const BillingErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class BillingInsufficientFundsState extends BillingState {
  final String message;

  const BillingInsufficientFundsState({required this.message});

  @override
  List<Object?> get props => [message];
}
