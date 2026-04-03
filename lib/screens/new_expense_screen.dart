import 'package:flutter/material.dart';
import 'choose_category_screen.dart';
import '../widgets/shared_widgets.dart';
import '../services/analytics_service.dart';

class NewExpenseScreen extends StatefulWidget {
  const NewExpenseScreen({super.key});

  @override
  State<NewExpenseScreen> createState() => _NewExpenseScreenState();
}

class _NewExpenseScreenState extends State<NewExpenseScreen> {
  String? _selected;

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
                    'New Expense',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  const StepProgressBar(value: 0.15),
                  const SizedBox(height: 40),
                  OptionButton(
                    label: 'New Expense',
                    isSelected: _selected == 'new',
                    onTap: () => setState(() => _selected = 'new'),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      OptionButton(
                        label: 'Unlogged Expenses',
                        isSelected: _selected == 'unlogged',
                        onTap: () => setState(() => _selected = 'unlogged'),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(14),
                            bottomRight: Radius.circular(14),
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.receipt_long, color: Colors.grey, size: 40),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ForwardNavButton(
                      onTap: _selected != null
                          ? () {
                        AnalyticsService.logTransition(
                          fromScreen: AnalyticsService.screenNewExpense,
                          destination: AnalyticsService.screenChooseCategory,
                          navButtonId: 'forward',
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChooseCategoryScreen(expenseType: _selected!),
                          ),
                        );
                      }
                          : null,
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