// lib/features/billing/presentation/bloc/billing_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:caller_host_app/features/billing/domain/repositories/billing_repository.dart';
import 'billing_event.dart';
import 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final BillingRepository repository;

  BillingBloc({required this.repository}) : super(const BillingInitialState()) {
    on<GetBalanceEvent>(_onGetBalance);
    on<RefreshBalanceEvent>(_onRefreshBalance);
    on<PurchaseCreditsEvent>(_onPurchaseCredits);
    on<GetTransactionHistoryEvent>(_onGetTransactionHistory);
  }

  Future<void> _onGetBalance(
    GetBalanceEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingLoadingState());
    try {
      final balance = await repository.getBalance();
      final transactions = await repository.getTransactionHistory();
      emit(BillingLoadedState(
        balance: balance,
        transactions: transactions,
      ));
    } catch (e) {
      emit(BillingErrorState(message: e.toString()));
    }
  }

  Future<void> _onRefreshBalance(
    RefreshBalanceEvent event,
    Emitter<BillingState> emit,
  ) async {
    try {
      final balance = await repository.getBalance();
      final transactions = await repository.getTransactionHistory();
      emit(BillingLoadedState(
        balance: balance,
        transactions: transactions,
      ));
    } catch (e) {
      emit(BillingErrorState(message: e.toString()));
    }
  }

  Future<void> _onPurchaseCredits(
    PurchaseCreditsEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingLoadingState());
    try {
      final newBalance = await repository.purchaseCredits(
        amount: event.amount,
        price: event.price,
      );
      emit(BillingPurchaseSuccessState(newBalance: newBalance));

      // Refresh balance after purchase
      await Future.delayed(const Duration(milliseconds: 500));
      add(const RefreshBalanceEvent());
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('insufficient')) {
        emit(BillingInsufficientFundsState(message: errorMessage));
      } else {
        emit(BillingErrorState(message: errorMessage));
      }
    }
  }

  Future<void> _onGetTransactionHistory(
    GetTransactionHistoryEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingLoadingState());
    try {
      final balance = await repository.getBalance();
      final transactions = await repository.getTransactionHistory();
      emit(BillingLoadedState(
        balance: balance,
        transactions: transactions,
      ));
    } catch (e) {
      emit(BillingErrorState(message: e.toString()));
    }
  }
}
