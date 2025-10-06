import 'package:flutter/material.dart';
import '../../../bloc/cart_bloc.dart';
import '../checkout_tokens.dart';

/// Compact order line item - 2-row layout matching React prototype
/// 
/// Row 1: Title (ellipsis) + qty ×n + lineTotal (right-aligned)
/// Row 2: Modifier chips (horizontal scroll if needed)
class CompactOrderLine extends StatelessWidget {
  final CartLineItem item;

  const CompactOrderLine({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CheckoutTokens.cardInnerPadding,
        vertical: CheckoutTokens.cardInnerPadding,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CheckoutTokens.border.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Title + Qty + Price
          Row(
            children: [
              // Title (flexible, ellipsis)
              Expanded(
                child: Text(
                  item.menuItem.name,
                  style: CheckoutTokens.textBody.copyWith(
                    fontWeight: CheckoutTokens.weightMedium,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              
              // Quantity badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CheckoutTokens.textMuted.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '×${item.quantity}',
                  style: CheckoutTokens.textMutedSmall.copyWith(
                    fontWeight: CheckoutTokens.weightMedium,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Line total (right-aligned)
              Text(
                '\$${item.lineTotal.toStringAsFixed(2)}',
                style: CheckoutTokens.textBody.copyWith(
                  fontWeight: CheckoutTokens.weightSemiBold,
                ),
              ),
            ],
          ),
          
          // Row 2: Modifier chips (if any)
          if (item.modifierSummary.isNotEmpty) ...[
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buildModifierChips(item.modifierSummary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildModifierChips(String summary) {
    final modifiers = summary.split(', ');
    return modifiers.map((mod) {
      return Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: CheckoutTokens.primaryLight,
          borderRadius: BorderRadius.circular(CheckoutTokens.radiusChip),
        ),
        child: Text(
          mod,
          style: CheckoutTokens.textMutedSmall.copyWith(
            color: CheckoutTokens.primary,
            fontWeight: CheckoutTokens.weightMedium,
          ),
        ),
      );
    }).toList();
  }
}
