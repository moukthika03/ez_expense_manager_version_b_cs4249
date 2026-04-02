import 'package:flutter/material.dart';
import 'amount_paid_screen.dart';
import '../widgets/shared_widgets.dart';

class ChooseCategoryScreen extends StatefulWidget {
  final String expenseType;

  const ChooseCategoryScreen({super.key, required this.expenseType});

  @override
  State<ChooseCategoryScreen> createState() => _ChooseCategoryScreenState();
}

class _ChooseCategoryScreenState extends State<ChooseCategoryScreen> {
  String? _selectedCategory;

  final List<Map<String, String>> _categories = [
    {
      'title': 'Living (e.g. utilities, transport)',
      'subtitle': '-\$1,200 in the last month',
    },
    {
      'title': 'Work-related Expenses',
      'subtitle': '-\$28.00 in the last month',
    },
    {
      'title': "John's Personal Expenses",
      'subtitle': '-\$45.20 in the last month',
    },
  ];

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
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const StepProgressBar(value: 0.35),
                  const SizedBox(height: 40),
                  ..._categories.map((cat) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: OptionButton(
                          label: cat['title']!,
                          subtitle: cat['subtitle'],
                          isSelected: _selectedCategory == cat['title'],
                          onTap: () =>
                              setState(() => _selectedCategory = cat['title']),
                        ),
                      )),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackNavButton(onTap: () => Navigator.pop(context)),
                      ForwardNavButton(
                        onTap: _selectedCategory != null
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AmountPaidScreen(
                                      category: _selectedCategory!,
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
