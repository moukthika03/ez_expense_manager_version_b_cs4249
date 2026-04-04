import 'package:flutter/material.dart';
import 'amount_paid_screen.dart';
import '../widgets/shared_widgets.dart';
import '../services/expense_service.dart';
import '../services/analytics_service.dart';
import '../services/flow_state_service.dart';

class ChooseCategoryScreen extends StatefulWidget {
  final String expenseType;

  const ChooseCategoryScreen({super.key, required this.expenseType});

  @override
  State<ChooseCategoryScreen> createState() => _ChooseCategoryScreenState();
}

class _ChooseCategoryScreenState extends State<ChooseCategoryScreen> {
  String? _selectedCategory;

  final List<String> _taskCategories = [
    'Transport', 'Food', 'Groceries', 'Appliances', 'Healthcare',
    'Utilities', 'Furniture', 'Shopping', 'Travel', 'Entertainment',
  ];

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView(AnalyticsService.screenChooseCategory);
  }

  List<Map<String, String>> get _categories {
    String monthTotal(String category) {
      final total = ExpenseService.totalThisMonthByCategory(category.toLowerCase());
      return total > 0
          ? '-\$${total.toStringAsFixed(2)} this month'
          : 'No expenses this month';
    }
    return _taskCategories.map((category) {
      return {'title': category, 'subtitle': monthTotal(category)};
    }).toList();
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
                    'Choose Category',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  const StepProgressBar(value: 0.35),
                  const SizedBox(height: 60),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Select Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    hint: const Text("Select the expense category"),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: _categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['title'],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(cat['title']!, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)),
                            Text(cat['subtitle']!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      );
                    }).toList(),
                    onTap: () {
                      AnalyticsService.logCategoryClicked(AnalyticsService.screenChooseCategory);
                    },
                    onChanged: (value) {
                      if (value != null) {
                        AnalyticsService.logCategorySelected(value, AnalyticsService.screenChooseCategory);
                      }
                      setState(() => _selectedCategory = value);
                    },
                    selectedItemBuilder: (BuildContext context) {
                      return _taskCategories.map<Widget>((String item) => Text(item)).toList();
                    },
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackNavButton(onTap: () {
                        AnalyticsService.logTransition(
                          fromScreen: AnalyticsService.screenChooseCategory,
                          destination: AnalyticsService.screenNewExpense,
                          navButtonId: 'back',
                        );
                        Navigator.pop(context);
                      }),
                      ForwardNavButton(
                        onTap: _selectedCategory != null
                            ? () {
                          AnalyticsService.logTransition(
                            fromScreen: AnalyticsService.screenChooseCategory,
                            destination: AnalyticsService.screenAmountPaid,
                            navButtonId: 'forward',
                          );
                          // Persist progress — carry forward expenseType from previous step.
                          final prev = FlowStateService.savedData;
                          FlowStateService.save(
                            step: FlowStateService.stepAmountPaid,
                            data: {
                              ...prev,
                              'category': _selectedCategory!,
                            },
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AmountPaidScreen(category: _selectedCategory!),
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