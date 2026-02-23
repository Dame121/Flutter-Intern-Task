// lib/features/billing/presentation/widgets/balance_display_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:caller_host_app/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:caller_host_app/features/billing/presentation/bloc/billing_event.dart';
import 'package:caller_host_app/features/billing/presentation/bloc/billing_state.dart';

class BalanceDisplayWidget extends StatefulWidget {
  const BalanceDisplayWidget({Key? key}) : super(key: key);

  @override
  State<BalanceDisplayWidget> createState() => _BalanceDisplayWidgetState();
}

class _BalanceDisplayWidgetState extends State<BalanceDisplayWidget> {
  @override
  void initState() {
    super.initState();
    // Fetch balance when widget is created
    context.read<BillingBloc>().add(const GetBalanceEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillingBloc, BillingState>(
      builder: (context, state) {
        if (state is BillingLoadedState) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.blue),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Balance',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '\$${state.balance.availableBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                if (state.balance.preAuthorizedAmount > 0) ...[
                  const Spacer(),
                  Tooltip(
                    message:
                        'Pre-authorized: \$${state.balance.preAuthorizedAmount.toStringAsFixed(2)}',
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange[600],
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        if (state is BillingErrorState) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error loading balance',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const SizedBox(
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}
