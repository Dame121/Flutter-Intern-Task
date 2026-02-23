// lib/features/billing/presentation/pages/credit_purchase_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:caller_host_app/features/billing/domain/entities/billing_entity.dart';
import 'package:caller_host_app/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:caller_host_app/features/billing/presentation/bloc/billing_event.dart';
import 'package:caller_host_app/features/billing/presentation/bloc/billing_state.dart';

class CreditPurchasePage extends StatefulWidget {
  const CreditPurchasePage({Key? key}) : super(key: key);

  @override
  State<CreditPurchasePage> createState() => _CreditPurchasePageState();
}

class _CreditPurchasePageState extends State<CreditPurchasePage> {
  // Predefined credit packages
  final List<CreditPackageEntity> creditPackages = [
    const CreditPackageEntity(
      id: '1',
      name: 'Starter',
      amount: 10,
      price: 5.0,
      popular: false,
    ),
    const CreditPackageEntity(
      id: '2',
      name: 'Popular',
      amount: 50,
      price: 20.0,
      popular: true,
    ),
    const CreditPackageEntity(
      id: '3',
      name: 'Pro',
      amount: 100,
      price: 35.0,
      popular: false,
    ),
    const CreditPackageEntity(
      id: '4',
      name: 'Enterprise',
      amount: 500,
      price: 150.0,
      popular: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Credits'),
        elevation: 0,
      ),
      body: BlocListener<BillingBloc, BillingState>(
        listener: (context, state) {
          if (state is BillingErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is BillingInsufficientFundsState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state is BillingPurchaseSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Purchase successful! New balance: \$${state.newBalance.balance.toStringAsFixed(2)}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Choose Your Credit Package',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'More credits = lower per-call costs',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),

              // Credit packages grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: creditPackages.length,
                itemBuilder: (context, index) {
                  final package = creditPackages[index];
                  return CreditPackageCard(
                    package: package,
                    onTap: () => _showPurchaseConfirmation(context, package),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Current balance section
              BlocBuilder<BillingBloc, BillingState>(
                builder: (context, state) {
                  if (state is BillingLoadedState) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Current Balance'),
                              Text(
                                '\$${state.balance.balance.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(color: Colors.blue),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Available'),
                              Text(
                                '\$${state.balance.availableBalance.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 32),

              // Info section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.amber[700]),
                        const SizedBox(width: 12),
                        Text(
                          'How Credits Work',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• 1 credit = \$1\n'
                      '• Audio calls cost your agreed per-minute rate\n'
                      '• Video calls usually cost 2x the audio rate\n'
                      '• Credits are deducted per minute during calls\n'
                      '• Unused credits stay in your account',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPurchaseConfirmation(
    BuildContext context,
    CreditPackageEntity package,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Confirm Purchase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Package: ${package.name}'),
            const SizedBox(height: 8),
            Text('Credits: ${package.amount.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Price:'),
                Text(
                  '\$${package.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BillingBloc>().add(
                    PurchaseCreditsEvent(
                      amount: package.amount,
                      price: package.price,
                    ),
                  );
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }
}

class CreditPackageCard extends StatelessWidget {
  final CreditPackageEntity package;
  final VoidCallback onTap;

  const CreditPackageCard({
    Key? key,
    required this.package,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: package.popular ? Colors.blue : Colors.grey[300]!,
            width: package.popular ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: package.popular ? Colors.blue[50] : Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (package.popular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Popular',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (package.popular) const SizedBox(height: 8),
            Text(
              package.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color:
                        package.popular ? Colors.blue : Colors.black,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${package.amount.toStringAsFixed(0)} Credits',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              '\$${package.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
