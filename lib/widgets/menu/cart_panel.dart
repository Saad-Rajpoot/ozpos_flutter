import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/tokens.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';

class CartPanel extends StatelessWidget {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(
          left: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: AppColors.bgPrimary,
              border: Border(
                bottom: BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: AppColors.textPrimary,
                  size: AppSizes.iconBase,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Cart',
                  style: AppTypography.heading3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                BlocBuilder<CartBloc, CartState>(
                  builder: (context, state) {
                    if (state is CartLoaded) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                        ),
                        child: Text(
                          '${state.items.length}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textOnPrimary,
                            fontWeight: AppTypography.medium,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                if (state is CartLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (state is CartError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  );
                }
                
                if (state is CartLoaded) {
                  if (state.items.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  return Column(
                    children: [
                      // Cart items
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          itemCount: state.items.length,
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            return _CartItemTile(item: item);
                          },
                        ),
                      ),
                      
                      // Order summary
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.base),
                        decoration: BoxDecoration(
                          color: AppColors.bgPrimary,
                          border: Border(
                            top: BorderSide(color: AppColors.borderLight),
                          ),
                        ),
                        child: Column(
                          children: [
                            _OrderSummaryRow(
                              label: 'Subtotal',
                              amount: state.subtotal,
                            ),
                            _OrderSummaryRow(
                              label: 'Tax',
                              amount: state.tax,
                            ),
                            const Divider(),
                            _OrderSummaryRow(
                              label: 'Total',
                              amount: state.total,
                              isTotal: true,
                            ),
                            const SizedBox(height: AppSpacing.base),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Navigate to checkout
                                },
                                child: const Text('Checkout'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: AppSizes.iconXl * 2,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Your cart is empty',
            style: AppTypography.heading4.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add items from the menu to get started',
            style: AppTypography.body2.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final dynamic item; // TODO: Replace with CartItemEntity

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Item Name', // TODO: Use item.name
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTypography.medium,
                  ),
                ),
                Text(
                  'Qty: 1', // TODO: Use item.quantity
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Price and controls
          Column(
            children: [
              Text(
                '\$0.00', // TODO: Use item.totalPrice
                style: AppTypography.body2.copyWith(
                  color: AppColors.primary,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      // TODO: Decrease quantity
                    },
                    icon: const Icon(Icons.remove, size: AppSizes.iconSm),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Increase quantity
                    },
                    icon: const Icon(Icons.add, size: AppSizes.iconSm),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isTotal;

  const _OrderSummaryRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal 
                ? AppTypography.body1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTypography.semiBold,
                  )
                : AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: isTotal 
                ? AppTypography.body1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTypography.semiBold,
                  )
                : AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
          ),
        ],
      ),
    );
  }
}
