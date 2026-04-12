import 'package:flutter/material.dart';
import 'expense_added_screen.dart';
import '../widgets/shared_widgets.dart';
import '../services/expense_service.dart';
import '../models/expense_model.dart';
import '../services/analytics_service.dart';
import '../services/flow_state_service.dart';

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
  String? _selectedElectronicMethod;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView(AnalyticsService.screenPaymentMethod);
  }

  void _selectMethod(String method) {
    AnalyticsService.logPaymentMethodClicked(AnalyticsService.screenPaymentMethod);
    if (_selectedMethod == method) {
      // Tapping the already-selected option deselects it
      AnalyticsService.logPaymentMethodDeselected(method, AnalyticsService.screenPaymentMethod);
      setState(() {
        _selectedMethod = null;
        _selectedElectronicMethod = null;
      });
    } else {
      final label = method == 'electronic'
          ? 'Electronic transfer'
          : method == 'card'
          ? 'Credit/debit card'
          : 'Other';
      AnalyticsService.logPaymentMethodSelected(label, AnalyticsService.screenPaymentMethod);
      setState(() {
        _selectedMethod = method;
        if (method != 'electronic') _selectedElectronicMethod = null;
      });
    }
  }

  DateTime _getSavedDate() {
    final savedDateStr = FlowStateService.savedData['date'] as String?;
    if (savedDateStr != null) {
      return DateTime.tryParse(savedDateStr) ?? DateTime.now();
    }
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Payment Method',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'optional',
                          style: TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const StepProgressBar(value: 0.88),
                  const SizedBox(height: 40),

                  OptionButton(
                    label: 'Electronic transfer',
                    isSelected: _selectedMethod == 'electronic',
                    onTap: () => _selectMethod('electronic'),
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
                        spacing: 10,
                        runSpacing: 10,
                        children: ['DBS PayLah', 'GrabPay', 'dash', 'fave', 'Singtel Dash']
                            .map((name) => GestureDetector(
                          onTap: () => setState(() => _selectedElectronicMethod = name),
                          child: Chip(
                            label: Text(name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _selectedElectronicMethod == name ? Colors.white : Colors.black87,
                                )),
                            backgroundColor: _selectedElectronicMethod == name
                                ? const Color(0xFF1A73E8)
                                : Colors.grey.shade100,
                          ),
                        ))
                            .toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  OptionButton(
                    label: 'Credit/debit card',
                    isSelected: _selectedMethod == 'card',
                    onTap: () => _selectMethod('card'),
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
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
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
                                Text('12/27', style: TextStyle(color: Colors.white70, fontSize: 12)),
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
                    onTap: () => _selectMethod('other'),
                  ),

                  const SizedBox(height: 32),
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
                      ElevatedButton(
                        onPressed: () async {
                          AnalyticsService.logTransition(
                            fromScreen: AnalyticsService.screenPaymentMethod,
                            destination: AnalyticsService.screenExpenseAdded,
                            navButtonId: 'confirm',
                          );

                          final selectedPayment = _selectedMethod == 'electronic'
                              ? 'Electronic transfer'
                              : _selectedMethod == 'card'
                              ? 'Credit/debit card'
                              : _selectedMethod == 'other'
                              ? 'Other'
                              : '';

                          final expenseDate = _getSavedDate();

                          AnalyticsService.logConfirmClicked(
                            fromScreen: AnalyticsService.screenPaymentMethod,
                            amount: widget.amount,
                            category: widget.category,
                            description: widget.description,
                            paymentMethod: selectedPayment,
                            date: expenseDate, // ← user-selected date
                          );

                          await AnalyticsService.flushEvents();

                          await ExpenseService.addExpense(
                            ExpenseModel(
                              title: widget.payee,
                              description: widget.description,
                              amount: double.tryParse(widget.amount) ?? 0.0,
                              date: expenseDate, // ← user-selected date
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
                      ),
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