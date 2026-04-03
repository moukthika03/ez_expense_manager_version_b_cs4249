import 'package:flutter/material.dart';
import 'expense_added_screen.dart';
import '../widgets/shared_widgets.dart';
import '../services/expense_service.dart';
import '../models/expense_model.dart';
import '../services/analytics_service.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String category;
  final String amount;
  final String payee;
  final String description;

  const PaymentMethodScreen({
    super.key,
    required this.category,
    required this.amount,
    required this.payee,
    required this.description,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Payment Method',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 16),
                  const StepProgressBar(value: 0.88),
                  const SizedBox(height: 40),

                  OptionButton(
                    label: 'Electronic transfer',
                    isSelected: _selectedMethod == 'electronic',
                    onTap: () => setState(() => _selectedMethod = 'electronic'),
                  ),
                  if (_selectedMethod == 'electronic') ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: Wrap(
                        spacing: 10, runSpacing: 10,
                        children: ['DBS PayLah', 'GrabPay', 'dash', 'fave', 'Singtel Dash']
                            .map((name) => Chip(
                          label: Text(name, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.grey.shade100,
                        ))
                            .toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  OptionButton(
                    label: 'Credit/debit card',
                    isSelected: _selectedMethod == 'card',
                    onTap: () => setState(() => _selectedMethod = 'card'),
                  ),
                  if (_selectedMethod == 'card') ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A73E8), Color(0xFF9C27B0)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('1234 5678 9012 3456',
                                style: TextStyle(color: Colors.white, fontSize: 15, letterSpacing: 2, fontWeight: FontWeight.w600)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('John Doe', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                Text('12/27',    style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  OptionButton(
                    label: 'Other',
                    isSelected: _selectedMethod == 'other',
                    onTap: () => setState(() => _selectedMethod = 'other'),
                  ),

                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackNavButton(onTap: () {
                        AnalyticsService.logTransition(
                          fromScreen: AnalyticsService.screenPaymentMethod,
                          destination: AnalyticsService.screenTransactionDetails,
                          navButtonId: 'back',
                        );
                        Navigator.pop(context);
                      }),
                      if (_selectedMethod != null)
                        ElevatedButton(
                          onPressed: () async {
                            // Analytics fires instantly, no await
                            AnalyticsService.logTransition(
                              fromScreen: AnalyticsService.screenPaymentMethod,
                              destination: AnalyticsService.screenExpenseAdded,
                              navButtonId: 'confirm',
                            );
                            AnalyticsService.logCompleted();

                            // Expense saving still awaited (local Hive write — fast)
                            await ExpenseService.addExpense(
                              ExpenseModel(
                                title: widget.payee,
                                description: widget.description,
                                amount: double.tryParse(widget.amount) ?? 0.0,
                                date: DateTime.now(),
                                category: widget.category,
                              ),
                            );
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ExpenseAddedScreen()),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A73E8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: const Text('Confirm Log',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        )
                      else
                        ForwardNavButton(onTap: null),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}