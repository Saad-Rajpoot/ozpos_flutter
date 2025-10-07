import 'package:equatable/equatable.dart';
import '../../domain/entities/addon_management_entities.dart';

abstract class AddonManagementEvent extends Equatable {
  const AddonManagementEvent();

  @override
  List<Object?> get props => [];
}

/// Load all addon categories from repository
class LoadAddonCategoriesEvent extends AddonManagementEvent {
  const LoadAddonCategoriesEvent();
}

/// Load attachments for a specific menu item
class LoadItemAddonAttachmentsEvent extends AddonManagementEvent {
  final String itemId;

  const LoadItemAddonAttachmentsEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

/// Attach an addon category to an item or size
class AttachAddonCategoryEvent extends AddonManagementEvent {
  final String itemId;
  final String? sizeId; // null for item-level
  final String categoryId;
  final bool appliesToAllSizes;

  const AttachAddonCategoryEvent({
    required this.itemId,
    this.sizeId,
    required this.categoryId,
    this.appliesToAllSizes = true,
  });

  @override
  List<Object?> get props => [itemId, sizeId, categoryId, appliesToAllSizes];
}

/// Remove an addon category attachment
class RemoveAddonCategoryEvent extends AddonManagementEvent {
  final String itemId;
  final String? sizeId;
  final String categoryId;

  const RemoveAddonCategoryEvent({
    required this.itemId,
    this.sizeId,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [itemId, sizeId, categoryId];
}

/// Update rule settings for an attached category
class UpdateAddonRuleEvent extends AddonManagementEvent {
  final String itemId;
  final String? sizeId;
  final AddonRule rule;

  const UpdateAddonRuleEvent({
    required this.itemId,
    this.sizeId,
    required this.rule,
  });

  @override
  List<Object?> get props => [itemId, sizeId, rule];
}

/// Toggle selection of an addon item in a rule
class ToggleAddonItemSelectionEvent extends AddonManagementEvent {
  final String itemId;
  final String? sizeId;
  final String categoryId;
  final String addonItemId;

  const ToggleAddonItemSelectionEvent({
    required this.itemId,
    this.sizeId,
    required this.categoryId,
    required this.addonItemId,
  });

  @override
  List<Object?> get props => [itemId, sizeId, categoryId, addonItemId];
}

/// Override price for a specific addon item
class OverrideAddonItemPriceEvent extends AddonManagementEvent {
  final String itemId;
  final String? sizeId;
  final String categoryId;
  final String addonItemId;
  final double? overridePrice; // null to remove override

  const OverrideAddonItemPriceEvent({
    required this.itemId,
    this.sizeId,
    required this.categoryId,
    required this.addonItemId,
    this.overridePrice,
  });

  @override
  List<Object?> get props => [
    itemId,
    sizeId,
    categoryId,
    addonItemId,
    overridePrice,
  ];
}

/// Update min/max selection rules
class UpdateSelectionRulesEvent extends AddonManagementEvent {
  final String itemId;
  final String? sizeId;
  final String categoryId;
  final int minSelection;
  final int maxSelection;
  final bool isRequired;

  const UpdateSelectionRulesEvent({
    required this.itemId,
    this.sizeId,
    required this.categoryId,
    required this.minSelection,
    required this.maxSelection,
    required this.isRequired,
  });

  @override
  List<Object?> get props => [
    itemId,
    sizeId,
    categoryId,
    minSelection,
    maxSelection,
    isRequired,
  ];
}

/// Duplicate rules from one size to another
class DuplicateRulesToSizeEvent extends AddonManagementEvent {
  final String itemId;
  final String sourceSizeId;
  final String targetSizeId;

  const DuplicateRulesToSizeEvent({
    required this.itemId,
    required this.sourceSizeId,
    required this.targetSizeId,
  });

  @override
  List<Object?> get props => [itemId, sourceSizeId, targetSizeId];
}

/// Reset size-specific rules to inherit from item-level
class ResetSizeRulesToItemLevelEvent extends AddonManagementEvent {
  final String itemId;
  final String sizeId;

  const ResetSizeRulesToItemLevelEvent({
    required this.itemId,
    required this.sizeId,
  });

  @override
  List<Object?> get props => [itemId, sizeId];
}

/// Create a new addon category
class CreateAddonCategoryEvent extends AddonManagementEvent {
  final String name;
  final String description;
  final List<AddonItem> items;

  const CreateAddonCategoryEvent({
    required this.name,
    required this.description,
    required this.items,
  });

  @override
  List<Object?> get props => [name, description, items];
}

/// Update an existing addon category
class UpdateAddonCategoryEvent extends AddonManagementEvent {
  final AddonCategory category;

  const UpdateAddonCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

/// Delete an addon category
class DeleteAddonCategoryEvent extends AddonManagementEvent {
  final String categoryId;

  const DeleteAddonCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Validate all rules for the current item
class ValidateAddonRulesEvent extends AddonManagementEvent {
  final String itemId;

  const ValidateAddonRulesEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

/// Reorder addon items within a category
class ReorderAddonItemsEvent extends AddonManagementEvent {
  final String categoryId;
  final List<String> itemIds; // New order

  const ReorderAddonItemsEvent({
    required this.categoryId,
    required this.itemIds,
  });

  @override
  List<Object?> get props => [categoryId, itemIds];
}
