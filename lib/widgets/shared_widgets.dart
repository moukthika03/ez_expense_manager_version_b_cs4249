import 'package:flutter/material.dart';

/// Full-width thin progress bar (light blue track, blue fill)
class StepProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0

  const StepProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 6,
        backgroundColor: const Color(0xFFBDD7FB),
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A73E8)),
      ),
    );
  }
}

/// Dark navy pill option button (unselected)
/// Selected state: same dark button + blue checkmark badge on right
class OptionButton extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionButton({
    super.key,
    required this.label,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: const BoxDecoration(
                color: Color(0xFF0D1117),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: Color(0xFF8A8FA8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 72,
                  color: const Color(0xFF1A73E8),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Grey back button (rounded rectangle)
class BackNavButton extends StatelessWidget {
  final VoidCallback onTap;

  const BackNavButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF6B7280),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
      ),
    );
  }
}

/// Blue forward button (rounded rectangle)
class ForwardNavButton extends StatelessWidget {
  final VoidCallback? onTap;

  const ForwardNavButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: onTap != null
              ? const Color(0xFF1A73E8)
              : const Color(0xFF1A73E8).withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.arrow_forward, color: Colors.white, size: 24),
      ),
    );
  }
}
