import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'transaction_details_screen.dart';
import '../widgets/shared_widgets.dart';
import '../services/analytics_service.dart';
import '../services/flow_state_service.dart';

class AmountPaidScreen extends StatefulWidget {
  final String category;

  const AmountPaidScreen({super.key, required this.category});

  @override
  State<AmountPaidScreen> createState() => _AmountPaidScreenState();
}

class _AmountPaidScreenState extends State<AmountPaidScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasFocusedOnce = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView(AnalyticsService.screenAmountPaid);
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && !_hasFocusedOnce) {
      _hasFocusedOnce = true;
      AnalyticsService.logAmountClicked(AnalyticsService.screenAmountPaid);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Amount Paid',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const StepProgressBar(value: 0.55),
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '\$',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          autofocus: true,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w300,
                            color: Colors.black87,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Type amount paid',
                            hintStyle: TextStyle(
                              fontSize: 36,
                              color: Color(0xFFCCCCCC),
                              fontWeight: FontWeight.w300,
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 1.5),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF1A73E8), width: 2),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 1.5),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackNavButton(onTap: () {
                        AnalyticsService.logTransition(
                          fromScreen: AnalyticsService.screenAmountPaid,
                          destination: AnalyticsService.screenChooseCategory,
                          navButtonId: 'back',
                        );
                        Navigator.pop(context);
                      }),
                      ForwardNavButton(
                        onTap: _controller.text.isNotEmpty
                            ? () {
                          AnalyticsService.logAmountEntered(_controller.text, AnalyticsService.screenAmountPaid);
                          AnalyticsService.logTransition(
                            fromScreen: AnalyticsService.screenAmountPaid,
                            destination: AnalyticsService.screenTransactionDetails,
                            navButtonId: 'forward',
                          );
                          // Persist progress — carry forward everything collected so far.
                          final prev = FlowStateService.savedData;
                          FlowStateService.save(
                            step: FlowStateService.stepTransactionDetails,
                            data: {
                              ...prev,
                              'amount': _controller.text,
                            },
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TransactionDetailsScreen(
                                category: widget.category,
                                amount: _controller.text,
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