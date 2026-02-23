// lib/features/billing/data/models/billing_model.dart

import 'package:caller_host_app/features/billing/domain/entities/billing_entity.dart';

class BalanceModel extends BalanceEntity {
  const BalanceModel({
    required double balance,
    required double preAuthorizedAmount,
  }) : super(
    balance: balance,
    preAuthorizedAmount: preAuthorizedAmount,
  );

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      balance: (json['balance'] ?? 0.0).toDouble(),
      preAuthorizedAmount: (json['preAuthorizedAmount'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'preAuthorizedAmount': preAuthorizedAmount,
    };
  }
}

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required String id,
    required String type,
    required double amount,
    required DateTime createdAt,
    String? description,
  }) : super(
    id: id,
    type: type,
    amount: amount,
    createdAt: createdAt,
    description: description,
  );

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'unknown',
      amount: (json['amount'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
    };
  }
}

class CreditPackageModel extends CreditPackageEntity {
  const CreditPackageModel({
    required String id,
    required String name,
    required double amount,
    required double price,
    required bool popular,
  }) : super(
    id: id,
    name: name,
    amount: amount,
    price: price,
    popular: popular,
  );

  factory CreditPackageModel.fromJson(Map<String, dynamic> json) {
    return CreditPackageModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Package',
      amount: (json['amount'] ?? 0.0).toDouble(),
      price: (json['price'] ?? 0.0).toDouble(),
      popular: json['popular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'price': price,
      'popular': popular,
    };
  }
}
