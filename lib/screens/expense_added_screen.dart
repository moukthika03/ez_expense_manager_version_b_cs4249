import 'package:flutter/material.dart';
import '../services/flow_state_service.dart';
import '../services/analytics_service.dart';

class ExpenseAddedScreen extends StatefulWidget {
  const ExpenseAddedScreen({super.key});

  @override
  State<ExpenseAddedScreen> createState() => _ExpenseAddedScreenState();
}

class _ExpenseAddedScreenState extends State<ExpenseAddedScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView(AnalyticsService.screenExpenseAdded);
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF1A73E8), width: 4),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 64,
                      color: Color(0xFF1A73E8),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Expense added!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your expense has been successfully logged.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.black45),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        AnalyticsService.logBackToHome(AnalyticsService.screenExpenseAdded);
                        // Flow is complete — remove persisted session state so a
                        // refresh after this point starts a fresh flow.
                        FlowStateService.clear();
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ),
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