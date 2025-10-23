import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/menu_item_entity.dart';
import 'item_configurator_dialog.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

/// Menu Item Card - Pixel-perfect match to reference
/// Shows image, name, description, price with Customise/Add buttons
class MenuItemCard extends StatelessWidget {
  final MenuItemEntity item;
  final int maxLines;
  final VoidCallback? onTap;
  final VoidCallback? onCustomize;

  const MenuItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.maxLines = 2,
    this.onCustomize,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge)),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        onTap: item.isFastAdd ? null : onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive image height based on card width
            final imageHeight =
                constraints.maxWidth * AppConstants.imageHeightRatio;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with badges
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppConstants.borderRadiusLarge),
                      ),
                      child: item.image != null
                          ? CachedNetworkImage(
                              imageUrl: item.image!,
                              height: imageHeight,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  _buildPlaceholderImage(imageHeight),
                              errorWidget: (context, url, error) =>
                                  _buildPlaceholderImage(imageHeight),
                            )
                          : _buildPlaceholderImage(imageHeight),
                    ),
                    // Popular badge
                    if (item.tags.contains('Popular'))
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.badgePopular,
                            borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusSmall),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.star, size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Popular',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Price badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.whiteOpacity95,
                          borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusSmall),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '\$${item.basePrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Content - Use Expanded to prevent overflow
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Name
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),

                              // Description - Flexible to take available space
                              Flexible(
                                child: Text(
                                  item.description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    height: 1.3,
                                  ),
                                  maxLines: maxLines,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action buttons
                        Row(
                          children: [
                            // Customise button
                            Expanded(
                              child: OutlinedButton(
                                onPressed: item.isFastAdd
                                    ? null
                                    : () {
                                        ItemConfiguratorDialog.show(
                                            context, item);
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: item.isFastAdd
                                      ? AppColors.textSecondary
                                      : AppColors.buttonPrimary,
                                  side: BorderSide(
                                    color: item.isFastAdd
                                        ? AppColors.borderMedium
                                        : AppColors.buttonPrimary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  minimumSize: const Size(0, 32),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.tune,
                                        size: 14,
                                        color: item.isFastAdd
                                            ? AppColors.textSecondary
                                            : AppColors.buttonPrimary),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Customise',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: item.isFastAdd
                                              ? AppColors.textSecondary
                                              : AppColors.buttonPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Add to Cart button
                            Expanded(
                              child: ElevatedButton(
                                onPressed: item.isFastAdd ? onTap : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: item.isFastAdd
                                      ? AppColors.buttonPrimary
                                      : AppColors.buttonSecondary,
                                  foregroundColor: AppColors.textWhite,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  minimumSize: const Size(0, 32),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add,
                                        size: 14,
                                        color: item.isFastAdd
                                            ? AppColors.textWhite
                                            : AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        item.isFastAdd ? 'Add' : 'Select Size',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: item.isFastAdd
                                              ? AppColors.textWhite
                                              : AppColors.textSecondary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.borderRadiusLarge)),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant,
          color: AppColors.textSecondary,
          size: height * 0.3, // Scale icon with height
        ),
      ),
    );
  }
}
