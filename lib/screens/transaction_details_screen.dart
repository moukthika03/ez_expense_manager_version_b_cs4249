import 'package:flutter/material.dart';
import 'payment_method_screen.dart';
import '../widgets/shared_widgets.dart';
import '../services/analytics_service.dart';
import '../services/flow_state_service.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final String category;
  final String amount;

  const TransactionDetailsScreen({super.key, required this.category, required this.amount});

  @override
  State<TransactionDetailsScreen> createState() => _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  final TextEditingController _payeeController = TextEditingController();
  final TextEditingController _descController  = TextEditingController();

  final List<Map<String, String>> _suggestions = [
    {'name': 'Netflix',   'subtitle': 'Entertainment'},
    {'name': 'Starbucks', 'subtitle': 'Food & Beverage'},
  ];

  // Forward is enabled only when BOTH payee and description are filled in.
  bool get _canProceed =>
      _payeeController.text.isNotEmpty && _descController.text.isNotEmpty;

  @override
  void dispose() {
    _payeeController.dispose();
    _descController.dispose();
    super.dispose();
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text('Transaction Details',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ),
                  const SizedBox(height: 16),
                  const StepProgressBar(value: 0.72),
                  const SizedBox(height: 32),

                  const Text('Payee Name',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      controller: _payeeController,
                      decoration: const InputDecoration(
                        hintText: 'E.g. Youtube Premium',
                        hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: 16),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: InputBorder.none,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Text('Most recent', style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA))),
                        ),
                        ..._suggestions.asMap().entries.map((entry) {
                          final i = entry.key;
                          final s = entry.value;
                          return Column(
                            children: [
                              if (i > 0) const Divider(height: 1, color: Color(0xFFEEEEEE)),
                              InkWell(
                                onTap: () { _payeeController.text = s['name']!; setState(() {}); },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40, height: 40,
                                        decoration: BoxDecoration(
                                          color: s['name'] == 'Netflix' ? Colors.black : const Color(0xFF00704A),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(child: Text(s['name']![0],
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(s['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                          Text(s['subtitle']!, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Description is required — label reflects this.
                  const Text('Description of expense',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      controller: _descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'for my monthly subscription payment',
                        hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: 15),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: InputBorder.none,
                      ),
                      // Rebuild so the forward button reacts immediately.
                      onChanged: (_) => setState(() {}),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackNavButton(onTap: () {
                        AnalyticsService.logTransition(
                          fromScreen: AnalyticsService.screenTransactionDetails,
                          destination: AnalyticsService.screenAmountPaid,
                          navButtonId: 'back',
                        );
                        Navigator.pop(context);
                      }),
                      ForwardNavButton(
                        onTap: _canProceed
                            ? () {
                          AnalyticsService.logTransition(
                            fromScreen: AnalyticsService.screenTransactionDetails,
                            destination: AnalyticsService.screenPaymentMethod,
                            navButtonId: 'forward',
                          );
                          // Persist progress — carry forward all previous data.
                          final prev = FlowStateService.savedData;
                          FlowStateService.save(
                            step: FlowStateService.stepPaymentMethod,
                            data: {
                              ...prev,
                              'payee'      : _payeeController.text,
                              'description': _descController.text,
                            },
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentMethodScreen(
                                category   : widget.category,
                                amount     : widget.amount,
                                payee      : _payeeController.text,
                                description: _descController.text,
                              ),
                            ),
                          );
                        }
                            : null,
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