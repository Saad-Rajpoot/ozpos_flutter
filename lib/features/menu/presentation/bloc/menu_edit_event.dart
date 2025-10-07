import 'dart:io';
import '../../domain/entities/menu_item_edit_entity.dart';

abstract class MenuEditEvent {
  const MenuEditEvent();
}

class InitializeMenuEdit extends MenuEditEvent {
  final MenuItemEditEntity? existingItem;
  const InitializeMenuEdit({this.existingItem});
}

class LoadCategoriesAndBadges extends MenuEditEvent {
  const LoadCategoriesAndBadges();
}

class LoadAvailableItems extends MenuEditEvent {
  const LoadAvailableItems();
}

class UpdateItemName extends MenuEditEvent {
  final String name;
  const UpdateItemName(this.name);
}

class UpdateItemDescription extends MenuEditEvent {
  final String description;
  const UpdateItemDescription(this.description);
}

class UpdateItemCategory extends MenuEditEvent {
  final String categoryId;
  const UpdateItemCategory(this.categoryId);
}

class UpdateImageUrl extends MenuEditEvent {
  final String imageUrl;
  const UpdateImageUrl(this.imageUrl);
}

class UpdateImageFile extends MenuEditEvent {
  final File imageFile;
  const UpdateImageFile(this.imageFile);
}

class RemoveImage extends MenuEditEvent {
  const RemoveImage();
}

class ToggleBadge extends MenuEditEvent {
  final BadgeEntity badge;
  const ToggleBadge(this.badge);
}

class SetHasSizes extends MenuEditEvent {
  final bool hasSizes;
  const SetHasSizes(this.hasSizes);
}

class AddSize extends MenuEditEvent {
  const AddSize();
}

class UpdateSize extends MenuEditEvent {
  final int index;
  final SizeEditEntity size;
  const UpdateSize(this.index, this.size);
}

class DeleteSize extends MenuEditEvent {
  final int index;
  const DeleteSize(this.index);
}

class SetDefaultSize extends MenuEditEvent {
  final int index;
  const SetDefaultSize(this.index);
}

class AddAddOnItemToSize extends MenuEditEvent {
  final int sizeIndex;
  final AddOnItemEditEntity addOnItem;
  const AddAddOnItemToSize(this.sizeIndex, this.addOnItem);
}

class RemoveAddOnItemFromSize extends MenuEditEvent {
  final int sizeIndex;
  final String itemId;
  const RemoveAddOnItemFromSize(this.sizeIndex, this.itemId);
}

class UpdateAddOnItemPrice extends MenuEditEvent {
  final int sizeIndex;
  final String itemId;
  final double price;
  const UpdateAddOnItemPrice(this.sizeIndex, this.itemId, this.price);
}

class ToggleAddOnItemEnabled extends MenuEditEvent {
  final int sizeIndex;
  final String itemId;
  const ToggleAddOnItemEnabled(this.sizeIndex, this.itemId);
}

class UpdateBasePrice extends MenuEditEvent {
  final double basePrice;
  const UpdateBasePrice(this.basePrice);
}

class AddUpsellItem extends MenuEditEvent {
  final String itemId;
  const AddUpsellItem(this.itemId);
}

class RemoveUpsellItem extends MenuEditEvent {
  final String itemId;
  const RemoveUpsellItem(this.itemId);
}

class AddRelatedItem extends MenuEditEvent {
  final String itemId;
  const AddRelatedItem(this.itemId);
}

class RemoveRelatedItem extends MenuEditEvent {
  final String itemId;
  const RemoveRelatedItem(this.itemId);
}

class UpdateChannelAvailability extends MenuEditEvent {
  final bool? dineInAvailable;
  final bool? takeawayAvailable;
  final bool? deliveryAvailable;

  const UpdateChannelAvailability({
    this.dineInAvailable,
    this.takeawayAvailable,
    this.deliveryAvailable,
  });
}

class UpdateKitchenSettings extends MenuEditEvent {
  final String? kitchenStation;
  final int? prepTimeMinutes;
  final String? specialInstructions;

  const UpdateKitchenSettings({
    this.kitchenStation,
    this.prepTimeMinutes,
    this.specialInstructions,
  });
}

class UpdateTaxCategory extends MenuEditEvent {
  final String taxCategory;
  const UpdateTaxCategory(this.taxCategory);
}

class UpdateSKU extends MenuEditEvent {
  final String sku;
  const UpdateSKU(this.sku);
}

class ToggleStockTracking extends MenuEditEvent {
  const ToggleStockTracking();
}

class UpdateDietaryPreferences extends MenuEditEvent {
  final bool? isVegetarian;
  final bool? isVegan;
  final bool? isGlutenFree;
  final bool? isDairyFree;
  final bool? isNutFree;
  final bool? isHalal;

  const UpdateDietaryPreferences({
    this.isVegetarian,
    this.isVegan,
    this.isGlutenFree,
    this.isDairyFree,
    this.isNutFree,
    this.isHalal,
  });
}

class NavigateToStep extends MenuEditEvent {
  final int step;
  const NavigateToStep(this.step);
}

class SaveDraft extends MenuEditEvent {
  const SaveDraft();
}

class SaveItem extends MenuEditEvent {
  const SaveItem();
}

class DuplicateItem extends MenuEditEvent {
  const DuplicateItem();
}

class CancelEdit extends MenuEditEvent {
  const CancelEdit();
}
