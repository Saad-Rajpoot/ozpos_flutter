import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/combo_management_bloc.dart';
import '../../bloc/combo_management_event.dart';
import '../../bloc/combo_management_state.dart';
import '../../../domain/entities/combo_pricing_entity.dart';

class PricingTab extends StatefulWidget {
  const PricingTab({super.key});

  @override
  State<PricingTab> createState() => _PricingTabState();
}

class _PricingTabState extends State<PricingTab> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _mixQuantityController = TextEditingController();
  final TextEditingController _mixPriceController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    _percentageController.dispose();
    _amountController.dispose();
    _mixQuantityController.dispose();
    _mixPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComboManagementBloc, ComboManagementState>(
      builder: (context, state) {
        final combo = state.editingCombo;
        if (combo == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pricing Strategy',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose how customers will be charged for this combo',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),

              // Pricing mode selection - 2x2 grid
              Column(
                children: [
                  Row(
                    children: [
                      _buildPricingModeCard(
                        title: 'Fixed Price',
                        subtitle: 'Set a specific combo price',
                        icon: Icons.attach_money,
                        isSelected: combo.pricing.mode == PricingMode.fixed,
                        onTap: () => _selectPricingMode(PricingMode.fixed),
                      ),
                      const SizedBox(width: 16),
                      _buildPricingModeCard(
                        title: 'Percentage Off',
                        subtitle: 'Discount by percentage',
                        icon: Icons.percent,
                        isSelected:
                            combo.pricing.mode == PricingMode.percentage,
                        onTap: () => _selectPricingMode(PricingMode.percentage),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildPricingModeCard(
                        title: 'Amount Off',
                        subtitle: 'Discount by fixed amount',
                        icon: Icons.money_off,
                        isSelected: combo.pricing.mode == PricingMode.amount,
                        onTap: () => _selectPricingMode(PricingMode.amount),
                      ),
                      const SizedBox(width: 16),
                      _buildPricingModeCard(
                        title: 'Mix & Match',
                        subtitle: 'Set quantity + price deal',
                        icon: Icons.shopping_basket,
                        isSelected:
                            combo.pricing.mode == PricingMode.mixAndMatch,
                        onTap: () =>
                            _selectPricingMode(PricingMode.mixAndMatch),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Pricing configuration
              _buildPricingConfiguration(combo),

              const SizedBox(height: 32),

              // Pricing breakdown
              _buildPricingBreakdown(combo),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPricingModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF8B5CF6)
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF8B5CF6).withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? const Color(0xFF8B5CF6)
                          : const Color(0xFF9CA3AF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF8B5CF6)
                            : const Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 8),
                Icon(
                  Icons.check,
                  color: const Color(0xFF10B981),
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingConfiguration(combo) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Set Your Price',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 24),

          // Price input based on selected mode
          if (combo.pricing.mode == PricingMode.fixed) ...[
            const Text(
              'Combo Price',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, color: Color(0xFF6B7280)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '22',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      final price = double.tryParse(value) ?? 0.0;
                      _updatePricing(PricingMode.fixed, fixedPrice: price);
                    },
                  ),
                ),
              ],
            ),
          ] else if (combo.pricing.mode == PricingMode.percentage) ...[
            const Text(
              'Percentage Off',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _percentageController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '20',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      final percent = double.tryParse(value) ?? 0.0;
                      _updatePricing(PricingMode.percentage,
                          percentOff: percent);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Text('% OFF',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ] else if (combo.pricing.mode == PricingMode.amount) ...[
            const Text(
              'Amount Off',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, color: Color(0xFF6B7280)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '7.50',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      final amount = double.tryParse(value) ?? 0.0;
                      _updatePricing(PricingMode.amount, amountOff: amount);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Text('OFF',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ] else if (combo.pricing.mode == PricingMode.mixAndMatch) ...[
            const Text(
              'Mix & Match Deal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _mixQuantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '2',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          final quantity = int.tryParse(value) ?? 0;
                          final price =
                              double.tryParse(_mixPriceController.text) ?? 0.0;
                          _updatePricing(PricingMode.mixAndMatch,
                              mixQuantity: quantity, mixPrice: price);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'for',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Price',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _mixPriceController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          hintText: '25.00',
                          prefixIcon: const Icon(Icons.attach_money, size: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          final price = double.tryParse(value) ?? 0.0;
                          final quantity =
                              int.tryParse(_mixQuantityController.text) ?? 0;
                          _updatePricing(PricingMode.mixAndMatch,
                              mixQuantity: quantity, mixPrice: price);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF8B5CF6),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Customers can choose any ${_mixQuantityController.text.isNotEmpty ? _mixQuantityController.text : '2'} items from this combo for \$${_mixPriceController.text.isNotEmpty ? _mixPriceController.text : '25.00'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingBreakdown(combo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pricing Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF059669),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total if purchased separately:',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                ),
              ),
              Text(
                '\$${combo.pricing.totalIfSeparate.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Combo Price:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF059669),
                ),
              ),
              Text(
                '\$${combo.pricing.finalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF059669),
                ),
              ),
            ],
          ),
          if (combo.pricing.savings > 0) ...[
            const Divider(height: 24, color: Color(0xFF10B981)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Customer Saves:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF059669),
                  ),
                ),
                Text(
                  '\$${combo.pricing.savings.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectPricingMode(PricingMode mode) {
    final totalSeparate =
        38.96; // Mock value - in real app, calculate from slots

    ComboPricingEntity newPricing;

    switch (mode) {
      case PricingMode.fixed:
        newPricing = ComboPricingEntity.fixed(
          fixedPrice: 22.00,
          totalIfSeparate: totalSeparate,
        );
        _priceController.text = '22.00';
        break;
      case PricingMode.percentage:
        newPricing = ComboPricingEntity.percentage(
          percentOff: 20.0,
          totalIfSeparate: totalSeparate,
        );
        _percentageController.text = '20';
        break;
      case PricingMode.amount:
        newPricing = ComboPricingEntity.amount(
          amountOff: 7.50,
          totalIfSeparate: totalSeparate,
        );
        _amountController.text = '7.50';
        break;
      case PricingMode.mixAndMatch:
        newPricing = ComboPricingEntity.mixAndMatch(
          quantity: 2,
          fixedPrice: 25.00,
          totalIfSeparate: totalSeparate,
        );
        _mixQuantityController.text = '2';
        _mixPriceController.text = '25.00';
        break;
    }

    context.read<ComboManagementBloc>().add(
          UpdateComboPricing(pricing: newPricing),
        );
  }

  void _updatePricing(
    PricingMode mode, {
    double? fixedPrice,
    double? percentOff,
    double? amountOff,
    int? mixQuantity,
    double? mixPrice,
  }) {
    final totalSeparate =
        38.96; // Mock value - in real app, calculate from slots

    ComboPricingEntity newPricing;

    switch (mode) {
      case PricingMode.fixed:
        newPricing = ComboPricingEntity.fixed(
          fixedPrice: fixedPrice ?? 22.00,
          totalIfSeparate: totalSeparate,
        );
        break;
      case PricingMode.percentage:
        newPricing = ComboPricingEntity.percentage(
          percentOff: percentOff ?? 20.0,
          totalIfSeparate: totalSeparate,
        );
        break;
      case PricingMode.amount:
        newPricing = ComboPricingEntity.amount(
          amountOff: amountOff ?? 7.50,
          totalIfSeparate: totalSeparate,
        );
        break;
      case PricingMode.mixAndMatch:
        newPricing = ComboPricingEntity.mixAndMatch(
          quantity: mixQuantity ?? 2,
          fixedPrice: mixPrice ?? 25.00,
          totalIfSeparate: totalSeparate,
        );
        break;
    }

    context.read<ComboManagementBloc>().add(
          UpdateComboPricing(pricing: newPricing),
        );
  }
}
