import 'package:flutter/material.dart';
import 'payment_method_screen.dart';
import '../widgets/shared_widgets.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final String category;
  final String amount;

  const TransactionDetailsScreen({
    super.key,
    required this.category,
    required this.amount,
  });

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  final TextEditingController _payeeController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  final List<Map<String, String>> _suggestions = [
    {'name': 'Netflix', 'subtitle': 'Entertainment'},
    {'name': 'Starbucks', 'subtitle': 'Food & Beverage'},
  ];

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Transaction Details',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const StepProgressBar(value: 0.72),
                  const SizedBox(height: 32),

                  // Payee Name label
                  const Text(
                    'Payee Name',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Search field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _payeeController,
                      decoration: const InputDecoration(
                        hintText: 'E.g. Youtube Premium',
                        hintStyle:
                            TextStyle(color: Color(0xFFAAAAAA), fontSize: 16),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: InputBorder.none,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),

                  // Most recent suggestions dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Text(
                            'Most recent',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                        ),
                        ..._suggestions.asMap().entries.map((entry) {
                          final i = entry.key;
                          final s = entry.value;
                          return Column(
                            children: [
                              if (i > 0)
                                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                              InkWell(
                                onTap: () {
                                  _payeeController.text = s['name']!;
                                  setState(() {});
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: s['name'] == 'Netflix'
                                              ? Colors.black
                                              : const Color(0xFF00704A),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            s['name']![0],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s['name']!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            s['subtitle']!,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black54,
                                            ),
                                          ),
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

                  // Description
                  const Text(
                    'Description of expense',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'for my monthly subscription payment',
                        hintStyle:
                            TextStyle(color: Color(0xFFAAAAAA), fontSize: 15),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackNavButton(onTap: () => Navigator.pop(context)),
                      ForwardNavButton(
                        onTap: _payeeController.text.isNotEmpty
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PaymentMethodScreen(
                                      category: widget.category,
                                      amount: widget.amount,
                                      payee: _payeeController.text,
                                      description: _descController.text,
                                    ),
                                  ),
                                )
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
