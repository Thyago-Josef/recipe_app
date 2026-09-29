import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class IngredientChip extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback? onTap;
  final bool showCheckmark;

  const IngredientChip({
    super.key,
    required this.ingredient,
    this.onTap,
    this.showCheckmark = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ingredient.isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ingredient.isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ingredient.name,
              style: TextStyle(
                color: ingredient.isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: ingredient.isSelected ? FontWeight.w600 : FontWeight.normal,
                decoration: ingredient.isSelected ? TextDecoration.lineThrough : null,
              ),
            ),
            if (showCheckmark && ingredient.isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.check,
                size: 14,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}