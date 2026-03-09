import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/limit_reached_toast.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/modifier_group_entity.dart';
import '../../domain/services/modifier_validator.dart';
import '../../domain/utils/modifier_tree_utils.dart';
import '../bloc/item_config_bloc.dart';
import '../bloc/item_config_event.dart';
import '../bloc/item_config_state.dart';
import '../bloc/menu_bloc.dart';
import '../bloc/menu_state.dart';
import '../../../checkout/presentation/bloc/cart_bloc.dart';

/// Item Configurator Dialog - Pixel-perfect match to reference
class ItemConfiguratorDialog extends StatelessWidget {
  final MenuItemEntity item;

  const ItemConfiguratorDialog({super.key, required this.item});

  static Future<void> show(BuildContext context, MenuItemEntity item) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => BlocProvider(
        create: (_) => ItemConfigBloc()..add(InitializeItemConfig(item: item)),
        child: BlocProvider.value(
          value: context.read<CartBloc>(),
          child: BlocProvider.value(
            value: context.read<MenuBloc>(),
            child: ItemConfiguratorDialog(item: item),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final bottomInset = viewInsets.bottom;
    final size = MediaQuery.sizeOf(context);
    // Stay above keyboard: content height must fit in (size.height - bottomInset).
    const topInset = 40.0;
    final maxHeight = size.height - bottomInset - topInset;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Align(
        alignment: bottomInset > 0 ? Alignment.topCenter : Alignment.center,
        child: Padding(
          padding: EdgeInsets.only(top: bottomInset > 0 ? 40 : 0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 520, maxHeight: maxHeight),
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
              child: BlocListener<ItemConfigBloc, ItemConfigState>(
                listenWhen: (_, current) {
                  if (current is! ItemConfigLoaded) return false;
                  final msg = current.feedbackMessage;
                  return msg != null && msg.isNotEmpty;
                },
                listener: (context, state) {
                  if (state is ItemConfigLoaded &&
                      state.feedbackMessage != null &&
                      state.feedbackMessage!.isNotEmpty) {
                    LimitReachedToast.show(
                      context,
                      title: 'Limit Reached',
                      message: state.feedbackMessage!,
                    );
                    Future.delayed(
                      const Duration(seconds: 3),
                      () {
                        if (context.mounted) {
                          context
                              .read<ItemConfigBloc>()
                              .add(const ClearFeedbackMessage());
                        }
                      },
                    );
                  }
                },
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildHeader(context),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: _buildContentColumn(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildFooter(context),
                      ],
                    ),
                    // Sticky close button
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
                ),
              ),
            ),
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
            child: Container(
              height: 200,
              width: double.infinity,
              color: AppColors.bgPrimary,
              child: CachedNetworkImage(
                imageUrl: item.image!,
                fit: BoxFit.contain,
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
          ),
      ],
    );
  }

  /// Content column only (used when whole dialog is scrollable).
  Widget _buildContentColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: _contentColumnChildren(context),
    );
  }

  List<Widget> _contentColumnChildren(BuildContext context) {
    return [
      // Name - large bold dark
      Text(
        item.name,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
      ),
      const SizedBox(height: 6),
          // Description - smaller regular grey
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.normal,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Price and Calories row (card style)
          Row(
            children: [
              BlocBuilder<ItemConfigBloc, ItemConfigState>(
                builder: (context, state) {
                  final price = state is ItemConfigLoaded
                      ? state.totalPrice
                      : item.basePrice;
                  return Text(
                    'From \$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  );
                },
              ),
              const Spacer(),
              BlocBuilder<ItemConfigBloc, ItemConfigState>(
                builder: (context, state) {
                  final cals = state is ItemConfigLoaded
                      ? state.totalCalories
                      : item.calories;
                  if (cals == null) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 18,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$cals kcal',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          if (item.tags.contains('Popular')) ...[
            const SizedBox(height: 8),
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
          const SizedBox(height: 24),
          // Dietary labels row
          if (item.dietaryLabels.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.dietaryLabels.map((label) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: label.badgeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    label.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          // Allergen / Ingredients / Additives tabs
          if (item.allergens.isNotEmpty ||
              item.ingredients.isNotEmpty ||
              item.additives.isNotEmpty) ...[
            _NutritionTabsSection(item: item),
            const SizedBox(height: 24),
          ],
          // Modifier Groups
          ...item.modifierGroups.map(
            (group) => _buildModifierGroup(context, group),
          ),
          // Combo Options
          if (item.comboOptions.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildComboSection(context),
          ],
      // Special Instructions (at end of dialog, per item)
      const SizedBox(height: 24),
      _buildSpecialInstructionsSection(context),
    ];
  }

  Widget _buildSpecialInstructionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SPECIAL INSTRUCTIONS',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        BlocBuilder<ItemConfigBloc, ItemConfigState>(
          buildWhen: (_, curr) => curr is ItemConfigLoaded,
          builder: (context, state) {
            final initial =
                state is ItemConfigLoaded ? state.specialInstructions : null;
            return _SpecialInstructionsField(
              itemKey: item.id,
              initialValue: initial,
            );
          },
        ),
      ],
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
            // Options (with nested groups shown when option is selected)
            ...group.options.expand((option) {
              final isSelected = selectedOptions.contains(option.id);
              return [
                _buildOptionTile(
                  context,
                  group,
                  option.id,
                  option.name,
                  option.priceDelta,
                  option.calories,
                  isSelected,
                  group.maxSelection == 1, // Radio style
                  hasNestedModifiers: option.hasNestedModifiers,
                ),
                if (isSelected && option.hasNestedModifiers) ...[
                  const SizedBox(height: 12),
                  ...option.nestedModifierGroups.map(
                    (nestedGroup) => Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: _buildModifierGroup(context, nestedGroup),
                    ),
                  ),
                ],
              ];
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
    int? calories,
    bool isSelected,
    bool isRadio, {
    bool hasNestedModifiers = false,
  }) {
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
              if (hasNestedModifiers)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    isSelected
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    size: 20,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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
                  if (calories != null)
                    Text(
                      '$calories cal',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
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
                  onPressed: () {
                    if (state.canAddToCart) {
                      _addToCart(context, state);
                    } else {
                      final missing =
                          ModifierValidator.getMissingRequiredGroupNames(
                        item: state.item,
                        selectedModifiers: state.selectedOptions,
                      );
                      final message = missing.isEmpty
                          ? 'Please select required options before adding to cart.'
                          : 'Please select:';
                      LimitReachedToast.show(
                        context,
                        title: 'Required options',
                        message: message,
                        bulletItems: missing.isEmpty ? null : missing,
                        backgroundColor: AppColors.error,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.canAddToCart
                        ? AppColors.buttonPrimary
                        : AppColors.textSecondary.withOpacity(0.4),
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
    // Build modifier strings (supports nested groups)
    final modifierStrings = <String>[];
    for (final entry in state.selectedOptions.entries) {
      final group = ModifierTreeUtils.findGroupById(state.item, entry.key);
      if (group == null) continue;
      for (final optionId in entry.value) {
        try {
          final option = group.options.firstWhere((o) => o.id == optionId);
          modifierStrings.add(option.name);
        } catch (_) {}
      }
    }

    if (state.selectedComboId != null) {
      final combo = state.item.comboOptions.firstWhere(
        (c) => c.id == state.selectedComboId,
      );
      modifierStrings.add(combo.name);
    }

    // Add to cart using CartBloc (pass active menu id for cart invalidation when menu changes)
    final menuState = context.read<MenuBloc>().state;
    final activeMenuId =
        menuState is MenuLoaded ? menuState.activeMenuId : null;
    context.read<CartBloc>().add(
          AddItemToCart(
            menuItem: state.item,
            quantity: state.quantity,
            unitPrice: state.totalPrice / state.quantity,
            selectedComboId: state.selectedComboId,
            selectedModifiers: state.selectedOptions,
            modifierSummary: modifierStrings.join(', '),
            specialInstructions: state.specialInstructions,
            activeMenuId: activeMenuId,
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

/// Special instructions text field (owns controller to preserve value).
class _SpecialInstructionsField extends StatefulWidget {
  final String itemKey;
  final String? initialValue;

  const _SpecialInstructionsField({
    required this.itemKey,
    this.initialValue,
  });

  @override
  State<_SpecialInstructionsField> createState() =>
      _SpecialInstructionsFieldState();
}

class _SpecialInstructionsFieldState extends State<_SpecialInstructionsField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(_SpecialInstructionsField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        _controller.text != (widget.initialValue ?? '')) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
      onChanged: (value) {
        context.read<ItemConfigBloc>().add(
              UpdateSpecialInstructions(instructions: value),
            );
      },
      maxLines: 4,
      minLines: 2,
      decoration: InputDecoration(
        hintText: 'Add a note for the kitchen...',
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
    );
  }
}

/// Tabbed section for Allergen Info, Ingredients, Additives
class _NutritionTabsSection extends StatefulWidget {
  final MenuItemEntity item;

  const _NutritionTabsSection({required this.item});

  @override
  State<_NutritionTabsSection> createState() => _NutritionTabsSectionState();
}

class _NutritionTabsSectionState extends State<_NutritionTabsSection> {
  int _selectedIndex = 0;
  bool _isExpanded = false;

  void _onTabTap(int i) {
    setState(() {
      if (_selectedIndex == i) {
        _isExpanded = !_isExpanded; // toggle collapse when same tab clicked
      } else {
        _selectedIndex = i;
        _isExpanded = true; // switching tabs always shows content
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasAllergens = widget.item.allergens.isNotEmpty;
    final hasIngredients = widget.item.ingredients.isNotEmpty;
    final hasAdditives = widget.item.additives.isNotEmpty;

    final tabs = <_TabInfo>[];
    if (hasAllergens)
      tabs.add(
          _TabInfo('ALLERGEN INFO', widget.item.allergens, _TabType.allergen));
    if (hasIngredients)
      tabs.add(_TabInfo(
          'INGREDIENTS', widget.item.ingredients, _TabType.ingredients));
    if (hasAdditives)
      tabs.add(
          _TabInfo('ADDITIVES', widget.item.additives, _TabType.additives));

    if (tabs.isEmpty) return const SizedBox.shrink();

    // Normalize selected index if it's out of range
    final selectedIndex = _selectedIndex.clamp(0, tabs.length - 1);
    if (selectedIndex != _selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedIndex = selectedIndex);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(tabs.length, (i) {
            final isSelected = _isExpanded && _selectedIndex == i;
            final tab = tabs[i];
            return GestureDetector(
              onTap: () => _onTabTap(i),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? tab.lightBgColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? tab.color : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 3,
                      width: 100,
                      decoration: BoxDecoration(
                        color: isSelected ? tab.color : Colors.transparent,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(2)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        if (tabs.isNotEmpty && _isExpanded) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgPrimary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      tabs[_selectedIndex].icon,
                      size: 20,
                      color: tabs[_selectedIndex].color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tabs[_selectedIndex].contentTitle ??
                          tabs[_selectedIndex].label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: tabs[_selectedIndex].color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 100),
                  child: SingleChildScrollView(
                    child: Text(
                      tabs[_selectedIndex].items.join(', '),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

enum _TabType { allergen, ingredients, additives }

class _TabInfo {
  final String label;
  final List<String> items;
  final _TabType type;

  _TabInfo(this.label, this.items, this.type);

  Color get color {
    switch (type) {
      case _TabType.allergen:
        return const Color(0xFFD32F2F); // red
      case _TabType.ingredients:
        return const Color(0xFF4CAF50); // green
      case _TabType.additives:
        return const Color(0xFF2196F3); // blue
    }
  }

  Color get lightBgColor {
    switch (type) {
      case _TabType.allergen:
        return const Color(0xFFFFEBEE); // light red
      case _TabType.ingredients:
        return const Color(0xFFE8F5E9); // light green
      case _TabType.additives:
        return const Color(0xFFE3F2FD); // light blue
    }
  }

  IconData get icon {
    switch (type) {
      case _TabType.allergen:
        return Icons.warning_amber_rounded;
      case _TabType.ingredients:
        return Icons.eco;
      case _TabType.additives:
        return Icons.science;
    }
  }

  String? get contentTitle {
    if (type == _TabType.allergen) return 'CONTAINS ALLERGENS';
    return null; // use label for others
  }
}
