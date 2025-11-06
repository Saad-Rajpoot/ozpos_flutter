import 'package:flutter/material.dart';
import '../../../domain/entities/menu_item_edit_entity.dart';

/// Size card widget displaying size information with prices
class SizeCardWidget extends StatelessWidget {
  final SizeEditEntity size;

  const SizeCardWidget({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            size.name.isNotEmpty ? size.name : 'Unnamed Size',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PriceInfoWidget(
                  channel: 'Dine-In',
                  price: size.dineInPrice,
                ),
              ),
              Expanded(
                child: _PriceInfoWidget(
                  channel: 'Takeaway',
                  price: size.takeawayPrice,
                ),
              ),
              Expanded(
                child: _PriceInfoWidget(
                  channel: 'Delivery',
                  price: size.deliveryPrice,
                ),
              ),
            ],
          ),
          if (size.addOnItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: size.addOnItems.map((addOnItem) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    addOnItem.itemName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Price info widget for displaying channel and price
class _PriceInfoWidget extends StatelessWidget {
  final String channel;
  final double? price;

  const _PriceInfoWidget({
    required this.channel,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          channel,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          (price != null && price! > 0) ? '\$${price!.toStringAsFixed(2)}' : '-',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}

