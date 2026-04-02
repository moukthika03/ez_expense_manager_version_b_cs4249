import 'package:flutter/material.dart';
import 'new_expense_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double _mobileBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < _mobileBreakpoint;
    return isMobile ? const _MobileHomeLayout() : const _WebHomeLayout();
  }
}

// ─────────────────────────────────────────────
// MOBILE LAYOUT
// ─────────────────────────────────────────────
class _MobileHomeLayout extends StatelessWidget {
  const _MobileHomeLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 160),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Center(
                    child: Text(
                      'Hey there John!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Balance
                  const Text(
                    'Current balance: \$5,600.00',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Chart
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: CustomPaint(painter: _LineChartPainter()),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'January 2026',
                      style: TextStyle(fontSize: 13, color: Colors.black45),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Two big square action buttons
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
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NewExpenseScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Recent transactions
                  const Text(
                    'Recent transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _MobileTransactionCard(
                    name: 'FairPrice',
                    description: 'groceries for baking sesh',
                    amount: '-\$42.90',
                    avatarColor: const Color(0xFF1A73E8),
                  ),
                  const SizedBox(height: 12),
                  _MobileTransactionCard(
                    name: 'Starbucks',
                    description: 'luncheon with friends',
                    amount: '-\$30.00',
                    avatarColor: const Color(0xFF00704A),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
                name[0],
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
// WEB LAYOUT
// ─────────────────────────────────────────────
class _WebHomeLayout extends StatelessWidget {
  const _WebHomeLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Hey there John!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Recent transactions
                        SizedBox(
                          width: 260,
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
                              _WebTransactionCard(
                                name: 'FairPrice',
                                amount: '-\$42.90',
                                description: 'groceries for baking session',
                              ),
                              const SizedBox(height: 12),
                              _WebTransactionCard(
                                name: 'Starbucks',
                                amount: '-\$30.00',
                                description: 'luncheon with my friends',
                              ),
                            ],
                          ),
                        ),
                        // Vertical divider
                        Container(
                          width: 1,
                          margin:
                          const EdgeInsets.symmetric(horizontal: 24),
                          color: Colors.grey.shade200,
                        ),
                        // Right: Balance + Chart
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current balance: \$5,600.00',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: CustomPaint(
                                    painter: _LineChartPainter(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Center(
                                child: Text(
                                  'January 2026',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _WebActionButton(
                        label: 'Add expense',
                        icon: Icons.account_balance_wallet,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NewExpenseScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _WebActionButton(
                        label: 'Add income',
                        icon: Icons.savings,
                        onTap: () {},
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
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A73E8),
        padding:
        const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    );
  }
}

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
              name[0],
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
                Text(amount,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(description,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED: Line chart painter
// ─────────────────────────────────────────────
class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final pts = [
      Offset(size.width * 0.00, size.height * 0.52),
      Offset(size.width * 0.12, size.height * 0.62),
      Offset(size.width * 0.28, size.height * 0.78),
      Offset(size.width * 0.38, size.height * 0.88),
      Offset(size.width * 0.58, size.height * 0.30),
      Offset(size.width * 0.72, size.height * 0.38),
      Offset(size.width * 0.84, size.height * 0.44),
      Offset(size.width * 1.00, size.height * 0.06),
    ];

    final linePaint = Paint()
      ..color = const Color(0xFF1A73E8)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(path, linePaint);

    void drawLabel(String text, Offset pos) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos);
    }

    drawLabel('\$5,210.90', Offset(4, pts[0].dy + 6));
    drawLabel('\$5,600.00', Offset(size.width - 76, pts.last.dy - 22));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}