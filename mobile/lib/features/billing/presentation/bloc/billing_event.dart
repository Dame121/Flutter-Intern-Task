// lib/features/billing/presentation/bloc/billing_event.dart

import 'package:equatable/equatable.dart';

abstract class BillingEvent extends Equatable {
  const BillingEvent();

  @override
  List<Object?> get props => [];
}

class GetBalanceEvent extends BillingEvent {
  const GetBalanceEvent();
}

class PurchaseCreditsEvent extends BillingEvent {
  final double amount;
  final double price;

  const PurchaseCreditsEvent({
    required this.amount,
    required this.price,
  });

  @override
  List<Object?> get props => [amount, price];
}

class RefreshBalanceEvent extends BillingEvent {
  const RefreshBalanceEvent();
}

class GetTransactionHistoryEvent extends BillingEvent {
  const GetTransactionHistoryEvent();
}
