import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/modifier_group_entity.dart';
import '../bloc/item_config_bloc.dart';
import '../bloc/item_config_event.dart';
import '../bloc/item_config_state.dart';
import '../../../checkout/presentation/bloc/cart_bloc.dart';

/// Item Configurator Dialog - Pixel-perfect match to reference
class ItemConfiguratorDialog extends StatelessWidget {
  final MenuItemEntity item;

  const ItemConfiguratorDialog({super.key, required this.item});

  static Future<void> show(BuildContext context, MenuItemEntity item) {
    return showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (_) => ItemConfigBloc()..add(InitializeItemConfig(item: item)),
        child: BlocProvider.value(
          value: context.read<CartBloc>(),
          child: ItemConfiguratorDialog(item: item),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              Flexible(child: _buildContent(context)),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // Hero Image
        if (item.image != null)
          ClipRRect(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppConstants.borderRadiusExtraLarge)),
            child: CachedNetworkImage(
              imageUrl: item.image!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: AppColors.bgPrimary,
                child: const Icon(
                  Icons.restaurant,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: AppColors.bgPrimary,
                child: const Icon(
                  Icons.restaurant,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        // Close button
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    BlocBuilder<ItemConfigBloc, ItemConfigState>(
                      builder: (context, state) {
                        if (state is ItemConfigLoaded) {
                          return Text(
                            'From \$${state.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          );
                        }
                        return Text(
                          'From \$${item.basePrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Popular badge
              if (item.tags.contains('Popular'))
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.statusPendingBg,
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadiusMedium),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star,
                          size: AppConstants.popularBadgeSize,
                          color: AppColors.badgePopular),
                      const SizedBox(width: 4),
                      Text(
                        'Popular',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Description
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          // Modifier Groups
          ...item.modifierGroups.map(
            (group) => _buildModifierGroup(context, group),
          ),
          // Combo Options
          if (item.comboOptions.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildComboSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildModifierGroup(BuildContext context, ModifierGroupEntity group) {
    return BlocBuilder<ItemConfigBloc, ItemConfigState>(
      builder: (context, state) {
        if (state is! ItemConfigLoaded) return const SizedBox.shrink();

        final selectedOptions = state.selectedOptions[group.id] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group header
            Row(
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                if (group.isRequired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.statusUnpaidBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'REQUIRED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                        letterSpacing: AppConstants.letterSpacingSmall,
                      ),
                    ),
                  ),
                const Spacer(),
                if (group.maxSelection < 999)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.orderDineInBgStart,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Max ${group.maxSelection}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Options
            ...group.options.map((option) {
              final isSelected = selectedOptions.contains(option.id);
              return _buildOptionTile(
                context,
                group,
                option.id,
                option.name,
                option.priceDelta,
                isSelected,
                group.maxSelection == 1, // Radio style
              );
            }),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    ModifierGroupEntity group,
    String optionId,
    String name,
    double priceDelta,
    bool isSelected,
    bool isRadio,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          context.read<ItemConfigBloc>().add(
                SelectModifierOption(
                  groupId: group.id,
                  optionId: optionId,
                  selected: isRadio ? true : !isSelected,
                ),
              );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? (isRadio
                        ? Icons.radio_button_checked
                        : Icons.check_circle)
                    : (isRadio
                        ? Icons.radio_button_unchecked
                        : Icons.circle_outlined),
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                priceDelta == 0.0
                    ? 'Free'
                    : '+\$${priceDelta.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: priceDelta == 0.0
                      ? const Color(0xFF6B7280)
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComboSection(BuildContext context) {
    return BlocBuilder<ItemConfigBloc, ItemConfigState>(
      builder: (context, state) {
        if (state is! ItemConfigLoaded) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Make it a Combo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Max 1',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...item.comboOptions.map((combo) {
              final isSelected = state.selectedComboId == combo.id;
              return _buildComboOption(
                context,
                combo.id,
                combo.name,
                combo.priceDelta,
                isSelected,
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildComboOption(
    BuildContext context,
    String comboId,
    String name,
    double priceDelta,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          context.read<ItemConfigBloc>().add(
                SelectComboOption(comboId: isSelected ? null : comboId),
              );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              Text(
                '+\$${priceDelta.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return BlocBuilder<ItemConfigBloc, ItemConfigState>(
      builder: (context, state) {
        if (state is! ItemConfigLoaded) {
          return const SizedBox(height: 80);
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.borderLight)),
            borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppConstants.borderRadiusExtraLarge)),
          ),
          child: Row(
            children: [
              // Quantity stepper
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: state.quantity > 1
                          ? () => context.read<ItemConfigBloc>().add(
                                UpdateQuantity(quantity: state.quantity - 1),
                              )
                          : null,
                      icon: const Icon(Icons.remove),
                      iconSize: 18,
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 32),
                      alignment: Alignment.center,
                      child: Text(
                        '${state.quantity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.read<ItemConfigBloc>().add(
                            UpdateQuantity(quantity: state.quantity + 1),
                          ),
                      icon: const Icon(Icons.add),
                      iconSize: 18,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Reset button
              TextButton(
                onPressed: () {
                  context.read<ItemConfigBloc>().add(
                        const ResetConfiguration(),
                      );
                },
                child: const Text('Reset'),
              ),
              const Spacer(),
              // Add to cart button
              Expanded(
                child: ElevatedButton(
                  onPressed: state.canAddToCart
                      ? () => _addToCart(context, state)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_shopping_cart, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Add \$${state.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addToCart(BuildContext context, ItemConfigLoaded state) {
    // Build modifier strings
    final modifierStrings = <String>[];
    for (final entry in state.selectedOptions.entries) {
      final group = state.item.modifierGroups.firstWhere(
        (g) => g.id == entry.key,
      );
      for (final optionId in entry.value) {
        final option = group.options.firstWhere((o) => o.id == optionId);
        modifierStrings.add(option.name);
      }
    }

    if (state.selectedComboId != null) {
      final combo = state.item.comboOptions.firstWhere(
        (c) => c.id == state.selectedComboId,
      );
      modifierStrings.add(combo.name);
    }

    // Add to cart using CartBloc
    context.read<CartBloc>().add(
          AddItemToCart(
            menuItem: state.item,
            quantity: state.quantity,
            unitPrice: state.totalPrice / state.quantity,
            selectedComboId: state.selectedComboId,
            selectedModifiers: state.selectedOptions,
            modifierSummary: modifierStrings.join(', '),
          ),
        );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${state.item.name} to cart'),
        duration: AppConstants.snackbarShortDuration,
        backgroundColor: AppColors.success,
      ),
    );
  }
}
