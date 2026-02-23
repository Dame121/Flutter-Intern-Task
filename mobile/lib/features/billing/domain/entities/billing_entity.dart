// lib/features/billing/domain/entities/billing_entity.dart

import 'package:equatable/equatable.dart';

class CreditPackageEntity extends Equatable {
  final String id;
  final String name;
  final double amount;
  final double price;
  final bool popular;

  const CreditPackageEntity({
    required this.id,
    required this.name,
    required this.amount,
    required this.price,
    this.popular = false,
  });

  @override
  List<Object?> get props => [id, name, amount, price, popular];
}

class BalanceEntity extends Equatable {
  final double balance;
  final double preAuthorizedAmount;

  const BalanceEntity({
    required this.balance,
    required this.preAuthorizedAmount,
  });

  double get availableBalance => balance - preAuthorizedAmount;

  @override
  List<Object?> get props => [balance, preAuthorizedAmount];
}

class TransactionEntity extends Equatable {
  final String id;
  final String type; // credit_purchase, call_deduction, message_deduction, refund
  final double amount;
  final DateTime createdAt;
  final String? description;

  const TransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.createdAt,
    this.description,
  });

  @override
  List<Object?> get props => [id, type, amount, createdAt, description];
}
