import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/menu_edit_state.dart';
import 'step5_review/validation_banner.dart';
import 'step5_review/menu_item_preview_widget.dart';
import 'step5_review/review_section_widget.dart';
import 'step5_review/review_row_widget.dart';
import 'step5_review/image_preview_widget.dart';
import 'step5_review/size_card_widget.dart';
import 'step5_review/dietary_flags_widget.dart';
import 'step5_review/empty_message_widget.dart';
import '../bloc/menu_edit_bloc.dart';

/// Step 5: Review & Save - Review all details before saving
class Step5Review extends StatelessWidget {
  const Step5Review({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuEditBloc, MenuEditState>(
      builder: (context, state) {
        return Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Validation banner
              ValidationBanner(state: state),
              const SizedBox(height: 32),

              // Visual Menu Preview
              MenuItemPreviewWidget(state: state),
              const SizedBox(height: 32),

              // Item Details Summary
              ReviewSectionWidget(
                title: 'Item Details',
                icon: Icons.restaurant_menu,
                stepNumber: 1,
                content: [
                  ReviewRowWidget(
                    label: 'Name',
                    value: state.item.name.isNotEmpty
                        ? state.item.name
                        : 'Not set',
                  ),
                  if (state.item.description.isNotEmpty)
                    ReviewRowWidget(
                      label: 'Description',
                      value: state.item.description,
                    ),
                  if (state.item.sku.isNotEmpty)
                    ReviewRowWidget(
                      label: 'SKU',
                      value: state.item.sku,
                    ),
                  ReviewRowWidget(
                    label: 'Category',
                    value: state.item.categoryId.isNotEmpty
                        ? state.item.categoryId
                        : 'Not set',
                  ),
                  if (state.item.badges.isNotEmpty)
                    ReviewRowWidget(
                      label: 'Badges',
                      value: state.item.badges.map((b) => b.label).join(', '),
                    ),
                  if (state.item.displayImagePath != null &&
                      state.item.displayImagePath!.isNotEmpty)
                    ImagePreviewWidget(
                      imageUrl: state.item.displayImagePath!,
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Sizes & Pricing Summary
              ReviewSectionWidget(
                title: 'Sizes & Pricing',
                icon: Icons.straighten,
                stepNumber: 2,
                content: [
                  if (state.item.sizes.isEmpty)
                    const EmptyMessageWidget(message: 'No sizes configured')
                  else
                    ...state.item.sizes.map(
                      (size) => SizeCardWidget(size: size),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Upsells Summary
              ReviewSectionWidget(
                title: 'Upsells & Related Items',
                icon: Icons.add_shopping_cart,
                stepNumber: 3,
                content: [
                  ReviewRowWidget(
                    label: 'Upsell Items',
                    value: state.item.upsellItemIds.isEmpty
                        ? 'None'
                        : '${state.item.upsellItemIds.length} items',
                  ),
                  ReviewRowWidget(
                    label: 'Related Items',
                    value: state.item.relatedItemIds.isEmpty
                        ? 'None'
                        : '${state.item.relatedItemIds.length} items',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Availability Summary
              ReviewSectionWidget(
                title: 'Availability & Settings',
                icon: Icons.settings,
                stepNumber: 4,
                content: [
                  ReviewRowWidget(
                    label: 'Dine-In',
                    value: state.item.dineInAvailable
                        ? 'Available'
                        : 'Not available',
                  ),
                  ReviewRowWidget(
                    label: 'Takeaway',
                    value: state.item.takeawayAvailable
                        ? 'Available'
                        : 'Not available',
                  ),
                  ReviewRowWidget(
                    label: 'Delivery',
                    value: state.item.deliveryAvailable
                        ? 'Available'
                        : 'Not available',
                  ),
                  if (state.item.prepTimeMinutes != null &&
                      state.item.prepTimeMinutes! > 0)
                    ReviewRowWidget(
                      label: 'Prep Time',
                      value: '${state.item.prepTimeMinutes} minutes',
                    ),
                  if (state.item.kitchenStation != null &&
                      state.item.kitchenStation!.isNotEmpty)
                    ReviewRowWidget(
                      label: 'Kitchen Station',
                      value: state.item.kitchenStation!,
                    ),
                  if (state.item.taxCategory.isNotEmpty)
                    ReviewRowWidget(
                      label: 'Tax Category',
                      value: state.item.taxCategory,
                    ),
                  if (state.item.isVegetarian ||
                      state.item.isVegan ||
                      state.item.isGlutenFree ||
                      state.item.isDairyFree ||
                      state.item.isNutFree ||
                      state.item.isHalal)
                    DietaryFlagsWidget(state: state),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
