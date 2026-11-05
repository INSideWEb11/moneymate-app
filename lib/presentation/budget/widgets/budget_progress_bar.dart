// lib/presentation/budget/widgets/budget_progress_bar.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class BudgetProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0+
  final double height;
  final bool animated;

  const BudgetProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final color = AppTheme.getStatusColor(value);

    if (animated) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: clamped),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        builder: (_, animValue, __) {
          return _buildBar(context, animValue, color);
        },
      );
    }

    return _buildBar(context, clamped, color);
  }

  Widget _buildBar(BuildContext context, double val, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: val,
        minHeight: height,
        backgroundColor:
            Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
