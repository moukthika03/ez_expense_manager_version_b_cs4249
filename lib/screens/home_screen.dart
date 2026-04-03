import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';
import 'new_expense_screen.dart';
import '../services/analytics_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double _mobileBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder rebuilds whenever the Hive box changes
    // (e.g. after a new expense is saved from NewExpenseScreen).
    return ValueListenableBuilder<Box<ExpenseModel>>(
      valueListenable: ExpenseService.listenable(),
      builder: (context, box, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < _mobileBreakpoint;
            return isMobile
                ? _MobileHomeLayout(box: box)
                : _WebHomeLayout(box: box);
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// MOBILE LAYOUT
// ─────────────────────────────────────────────
class _MobileHomeLayout extends StatelessWidget {
  final Box<ExpenseModel> box;
  const _MobileHomeLayout({required this.box});

  @override
  Widget build(BuildContext context) {
    final recent = ExpenseService.getAll().take(5).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Greeting ────────────────────────────────────────────────
              const Center(
                child: Text(
                  'Hey there!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Summary cards ────────────────────────────────────────────
              const Text(
                'Expense summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.55,
                children: [
                  _SummaryCard(
                    label: 'Today',
                    amount: ExpenseService.totalToday(),
                    icon: Icons.today,
                    color: const Color(0xFF1A73E8),
                  ),
                  _SummaryCard(
                    label: 'This week',
                    amount: ExpenseService.totalThisWeek(),
                    icon: Icons.date_range,
                    color: const Color(0xFF00897B),
                  ),
                  _SummaryCard(
                    label: 'This month',
                    amount: ExpenseService.totalThisMonth(),
                    icon: Icons.calendar_month,
                    color: const Color(0xFF7B1FA2),
                  ),
                  _SummaryCard(
                    label: 'This year',
                    amount: ExpenseService.totalThisYear(),
                    icon: Icons.bar_chart,
                    color: const Color(0xFFE65100),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Action buttons ───────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _MobileActionButton(
                      label: 'Add income',
                      icon: Icons.savings,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _MobileActionButton(
                      label: 'Add expense',
                      icon: Icons.account_balance_wallet,
                      onTap: () async {
                        await AnalyticsService.startSession();
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NewExpenseScreen(),
                          ),
                        );
                        // No setState needed — ValueListenableBuilder handles refresh.
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Recent transactions ──────────────────────────────────────
              const Text(
                'Recent transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 14),

              if (recent.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'No expenses yet.\nTap "Add expense" to get started!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black45, fontSize: 14),
                    ),
                  ),
                )
              else
                ...recent.map(
                      (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MobileTransactionCard(
                      name: e.title,
                      description: e.description,
                      amount: '-\$${e.amount.toStringAsFixed(2)}',
                      avatarColor: _categoryColor(e.category),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WEB LAYOUT
// ─────────────────────────────────────────────
class _WebHomeLayout extends StatelessWidget {
  final Box<ExpenseModel> box;
  const _WebHomeLayout({required this.box});

  @override
  Widget build(BuildContext context) {
    final recent = ExpenseService.getAll().take(5).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Hey there!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Summary cards (4 across) ───────────────────────────
                  Row(
                    children: [
                      _WebSummaryCard(
                        label: 'Today',
                        amount: ExpenseService.totalToday(),
                        icon: Icons.today,
                        color: const Color(0xFF1A73E8),
                      ),
                      const SizedBox(width: 16),
                      _WebSummaryCard(
                        label: 'This week',
                        amount: ExpenseService.totalThisWeek(),
                        icon: Icons.date_range,
                        color: const Color(0xFF00897B),
                      ),
                      const SizedBox(width: 16),
                      _WebSummaryCard(
                        label: 'This month',
                        amount: ExpenseService.totalThisMonth(),
                        icon: Icons.calendar_month,
                        color: const Color(0xFF7B1FA2),
                      ),
                      const SizedBox(width: 16),
                      _WebSummaryCard(
                        label: 'This year',
                        amount: ExpenseService.totalThisYear(),
                        icon: Icons.bar_chart,
                        color: const Color(0xFFE65100),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Body: transactions left, actions right ─────────────
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left — recent transactions
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Recent transactions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (recent.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 24),
                                  child: Text(
                                    'No expenses yet.',
                                    style: TextStyle(color: Colors.black45),
                                  ),
                                )
                              else
                                ...recent.map(
                                      (e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _WebTransactionCard(
                                      name: e.title,
                                      amount:
                                      '-\$${e.amount.toStringAsFixed(2)}',
                                      description: e.description,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Divider
                        Container(
                          width: 1,
                          margin:
                          const EdgeInsets.symmetric(horizontal: 28),
                          color: Colors.grey.shade200,
                        ),

                        // Right — quick actions
                        SizedBox(
                          width: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Quick actions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _WebActionButton(
                                label: 'Add expense',
                                icon: Icons.account_balance_wallet,
                                onTap: () async {
                                  await AnalyticsService.startSession();
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const NewExpenseScreen(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _WebActionButton(
                                label: 'Add income',
                                icon: Icons.savings,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                      ],
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

// ─────────────────────────────────────────────
// Summary card — mobile (compact grid tile)
// ─────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Summary card — web (wider Expanded tile)
// ─────────────────────────────────────────────
class _WebSummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _WebSummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Mobile action button
// ─────────────────────────────────────────────
class _MobileActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _MobileActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xFF1A73E8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Mobile transaction card
// ─────────────────────────────────────────────
class _MobileTransactionCard extends StatelessWidget {
  final String name;
  final String description;
  final String amount;
  final Color avatarColor;

  const _MobileTransactionCard({
    required this.name,
    required this.description,
    required this.amount,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: avatarColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF8A8FA8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Web action button
// ─────────────────────────────────────────────
class _WebActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _WebActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A73E8),
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Web transaction card
// ─────────────────────────────────────────────
class _WebTransactionCard extends StatelessWidget {
  final String name;
  final String amount;
  final String description;

  const _WebTransactionCard({
    required this.name,
    required this.amount,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A73E8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade200,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(description,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black45)),
              ],
            ),
          ),
          Text(amount,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Helper: pick avatar colour by category
// ─────────────────────────────────────────────
Color _categoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return const Color(0xFF00897B);
    case 'transport':
      return const Color(0xFF1A73E8);
    case 'shopping':
      return const Color(0xFF7B1FA2);
    default:
      return const Color(0xFFE65100);
  }
}