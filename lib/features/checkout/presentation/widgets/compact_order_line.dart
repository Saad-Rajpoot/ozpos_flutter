import 'package:flutter/material.dart';
import '../../../menu/domain/utils/modifier_tree_utils.dart';
import '../../../checkout/presentation/bloc/cart_bloc.dart';
import '../constant/checkout_constants.dart';

/// Compact order line item - 2-row layout matching React prototype
///
/// Row 1: Title (ellipsis) + qty ×n + lineTotal (right-aligned)
/// Row 2: Modifier chips (horizontal scroll if needed)
class CompactOrderLine extends StatelessWidget {
  final CartLineItem item;

  const CompactOrderLine({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CheckoutConstants.cardInnerPadding,
        vertical: CheckoutConstants.cardInnerPadding,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CheckoutConstants.border.withOpacity(0.5),
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
                  style: CheckoutConstants.textBody.copyWith(
                    fontWeight: CheckoutConstants.weightMedium,
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
                  color: CheckoutConstants.textMuted.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '×${item.quantity}',
                  style: CheckoutConstants.textMutedSmall.copyWith(
                    fontWeight: CheckoutConstants.weightMedium,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Line total (right-aligned)
              Text(
                '\$${item.lineTotal.toStringAsFixed(2)}',
                style: CheckoutConstants.textBody.copyWith(
                  fontWeight: CheckoutConstants.weightSemiBold,
                ),
              ),
            ],
          ),

          // Row 2: Modifiers as "Group: Option" lines (indented)
          if (_modifierLines(item).isNotEmpty) ...[
            const SizedBox(height: 4),
            ..._modifierLines(item).map((e) => Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 2),
                  child: RichText(
                    text: TextSpan(
                      style: CheckoutConstants.textMutedSmall.copyWith(
                        height: 1.35,
                        color: CheckoutConstants.textMuted,
                      ),
                      children: [
                        TextSpan(
                          text: '${e.groupName}: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: e.optionName),
                      ],
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  List<({String groupName, String optionName})> _modifierLines(
    CartLineItem item,
  ) {
    return ModifierTreeUtils.getModifierDisplayLines(
      item.menuItem,
      item.selectedModifiers,
    );
  }
}
