import '../../domain/entities/menu_item_edit_entity.dart';
import '../../domain/entities/menu_category_entity.dart';
import '../../domain/entities/menu_item_entity.dart';

/// Status of the menu editing session
enum MenuEditStatus {
  initial,
  loading,
  editing,
  saving,
  saved,
  error,
}

/// State for menu item editing
class MenuEditState {
  final MenuEditStatus status;
  final MenuItemEditEntity item;
  final ValidationResult validation;
  final int currentStep;
  final bool hasUnsavedChanges;
  final String? errorMessage;
  
  // Available data for dropdowns/pickers
  final List<MenuCategoryEntity> categories;
  final List<BadgeEntity> badges;
  final List<AddOnCategoryEntity> addOnCategories;
  final List<MenuItemEntity> availableItems; // For upsells/related items

  const MenuEditState({
    required this.status,
    required this.item,
    required this.validation,
    required this.currentStep,
    required this.hasUnsavedChanges,
    this.errorMessage,
    required this.categories,
    required this.badges,
    required this.addOnCategories,
    required this.availableItems,
  });

  /// Create initial state
  factory MenuEditState.initial() {
    return MenuEditState(
      status: MenuEditStatus.initial,
      item: MenuItemEditEntity.empty(),
      validation: const ValidationResult(errors: [], warnings: []),
      currentStep: 1,
      hasUnsavedChanges: false,
      categories: [],
      badges: [],
      addOnCategories: [],
      availableItems: [],
    );
  }

  /// Create state with item
  factory MenuEditState.withItem(MenuItemEditEntity item) {
    final validation = validateItem(item);
    return MenuEditState(
      status: MenuEditStatus.editing,
      item: item,
      validation: validation,
      currentStep: 1,
      hasUnsavedChanges: false,
      categories: [],
      badges: [],
      addOnCategories: [],
      availableItems: [],
    );
  }

  /// Copy with modifications
  MenuEditState copyWith({
    MenuEditStatus? status,
    MenuItemEditEntity? item,
    ValidationResult? validation,
    int? currentStep,
    bool? hasUnsavedChanges,
    String? errorMessage,
    List<MenuCategoryEntity>? categories,
    List<BadgeEntity>? badges,
    List<AddOnCategoryEntity>? addOnCategories,
    List<MenuItemEntity>? availableItems,
  }) {
    return MenuEditState(
      status: status ?? this.status,
      item: item ?? this.item,
      validation: validation ?? this.validation,
      currentStep: currentStep ?? this.currentStep,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      errorMessage: errorMessage ?? this.errorMessage,
      categories: categories ?? this.categories,
      badges: badges ?? this.badges,
      addOnCategories: addOnCategories ?? this.addOnCategories,
      availableItems: availableItems ?? this.availableItems,
    );
  }

  /// Helper to validate item
  static ValidationResult validateItem(MenuItemEditEntity item) {
    final errors = <String>[];
    final warnings = <String>[];

    // Name validation
    if (item.name.trim().isEmpty) {
      errors.add('Item name is required');
    }

    // Category validation
    if (item.categoryId.isEmpty) {
      errors.add('Category must be selected');
    }

    // Size validation
    if (item.hasSizes) {
      if (item.sizes.isEmpty) {
        errors.add('Add at least one size');
      } else {
        final defaultSizes = item.sizes.where((s) => s.isDefault).length;
        if (defaultSizes == 0) {
          errors.add('One size must be marked as default');
        } else if (defaultSizes > 1) {
          errors.add('Only one size can be default');
        }

        // Validate each size has a name and price
        for (int i = 0; i < item.sizes.length; i++) {
          final size = item.sizes[i];
          if (size.name.trim().isEmpty) {
            errors.add('Size ${i + 1} must have a name');
          }
          if (size.dineInPrice <= 0) {
            errors.add('Size ${i + 1} must have a valid dine-in price');
          }
        }
      }
    }

    // Base price validation (for items without sizes)
    if (!item.hasSizes && item.basePrice <= 0) {
      errors.add('Base price must be greater than zero');
    }

    // Channel availability validation
    if (!item.dineInAvailable && !item.takeawayAvailable && !item.deliveryAvailable) {
      errors.add('Item must be available on at least one channel');
    }

    // Warnings
    if (item.description.trim().isEmpty) {
      warnings.add('Consider adding a description');
    }

    if (item.badges.isEmpty) {
      warnings.add('Consider adding badges to highlight special features');
    }

    if (item.hasSizes) {
      final totalAddOns = item.sizes.fold<int>(
        0,
        (sum, size) => sum + size.addOnItems.length,
      );
      if (totalAddOns == 0) {
        warnings.add('Consider adding add-ons to increase customization options');
      }
    }

    return ValidationResult(errors: errors, warnings: warnings);
  }

  /// Get price range for display
  String get priceDisplay {
    if (item.hasSizes && item.sizes.isNotEmpty) {
      final prices = item.sizes.map((s) => s.dineInPrice).toList();
      final minPrice = prices.reduce((a, b) => a < b ? a : b);
      final maxPrice = prices.reduce((a, b) => a > b ? a : b);
      
      if (minPrice == maxPrice) {
        return '\$${minPrice.toStringAsFixed(2)}';
      }
      return '\$${minPrice.toStringAsFixed(2)} - \$${maxPrice.toStringAsFixed(2)}';
    } else {
      return '\$${item.basePrice.toStringAsFixed(2)}';
    }
  }

  /// Get total add-on items count
  int get totalAddOnItems {
    if (!item.hasSizes) return 0;
    return item.sizes.fold<int>(
      0,
      (sum, size) => sum + size.addOnItems.length,
    );
  }

  /// Check if can proceed to next step
  bool get canProceedToNextStep {
    // Step 1: Need name and category
    if (currentStep == 1) {
      return item.name.trim().isNotEmpty && item.categoryId.isNotEmpty;
    }
    // Step 2: If has sizes, need at least one valid size
    if (currentStep == 2 && item.hasSizes) {
      return item.sizes.isNotEmpty &&
          item.sizes.any((s) => s.isDefault) &&
          item.sizes.every((s) => s.name.trim().isNotEmpty && s.dineInPrice > 0);
    }
    // Other steps can always proceed
    return true;
  }

  /// Check if can save
  bool get canSave {
    return validation.isValid && item.name.trim().isNotEmpty;
  }
  
  /// Get category name by ID
  String getCategoryName(String categoryId) {
    final category = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => MenuCategoryEntity(
        id: categoryId,
        name: 'Unknown',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return category.name;
  }
  
  /// Get menu item by ID (for upsells/related)
  MenuItemEntity? getMenuItem(String itemId) {
    try {
      return availableItems.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }
}
