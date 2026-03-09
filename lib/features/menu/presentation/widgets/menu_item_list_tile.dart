import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/menu_item_entity.dart';
import 'item_configurator_dialog.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

/// Compact list-tile style card for menu items (list view).
/// Matches MenuItemCard styling: image, name, description, price, Customise/Add.
class MenuItemListTile extends StatelessWidget {
  final MenuItemEntity item;

  const MenuItemListTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    const thumbSize = 88.0;

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        onTap: () => ItemConfiguratorDialog.show(context, item),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
                child: SizedBox(
                  width: thumbSize,
                  height: thumbSize,
                  child: item.image != null
                      ? CachedNetworkImage(
                          imageUrl: item.image!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _placeholder(thumbSize),
                          errorWidget: (_, __, ___) => _placeholder(thumbSize),
                        )
                      : _placeholder(thumbSize),
                ),
              ),
              const SizedBox(width: 14),
              // Name, description, badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.tags.contains('Popular'))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.badgePopular,
                            borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusSmall),
                          ),
                          child: const Text(
                            'Popular',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Price + actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bgPrimary,
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadiusSmall),
                    ),
                    child: Text(
                      '\$${item.basePrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: () =>
                            ItemConfiguratorDialog.show(context, item),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                          side:
                              const BorderSide(color: AppColors.buttonPrimary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          minimumSize: const Size(0, 32),
                        ),
                        child: const Icon(Icons.tune, size: 16),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        onPressed: () =>
                            ItemConfiguratorDialog.show(context, item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonPrimary,
                          foregroundColor: AppColors.textWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          minimumSize: const Size(0, 32),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add,
                                size: 16, color: AppColors.textWhite),
                            SizedBox(width: 4),
                            Text('Add',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(double size) {
    return Container(
      width: size,
      height: size,
      color: AppColors.bgPrimary,
      child: Icon(Icons.restaurant,
          color: AppColors.textSecondary, size: size * 0.4),
    );
  }
}
