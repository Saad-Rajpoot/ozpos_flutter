import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/menu_item_edit_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import 'menu_edit_event.dart';
import 'menu_edit_state.dart';

/// BLoC for managing menu item editing
class MenuEditBloc extends Bloc<MenuEditEvent, MenuEditState> {
  final MenuRepository menuRepository;

  MenuEditBloc({required this.menuRepository})
      : super(MenuEditState.initial()) {
    on<InitializeMenuEdit>(_onInitialize);
    on<LoadCategoriesAndBadges>(_onLoadCategoriesAndBadges);
    on<LoadAvailableItems>(_onLoadAvailableItems);
    on<UpdateItemName>(_onUpdateName);
    on<UpdateItemDescription>(_onUpdateDescription);
    on<UpdateItemCategory>(_onUpdateCategory);
    on<UpdateImageUrl>(_onUpdateImageUrl);
    on<UpdateImageFile>(_onUpdateImageFile);
    on<RemoveImage>(_onRemoveImage);
    on<ToggleBadge>(_onToggleBadge);
    on<SetHasSizes>(_onSetHasSizes);
    on<AddSize>(_onAddSize);
    on<UpdateSize>(_onUpdateSize);
    on<DeleteSize>(_onDeleteSize);
    on<SetDefaultSize>(_onSetDefaultSize);
    on<AddAddOnItemToSize>(_onAddAddOnItemToSize);
    on<RemoveAddOnItemFromSize>(_onRemoveAddOnItemFromSize);
    on<UpdateAddOnItemPrice>(_onUpdateAddOnItemPrice);
    on<ToggleAddOnItemEnabled>(_onToggleAddOnItemEnabled);
    on<UpdateBasePrice>(_onUpdateBasePrice);
    on<AddUpsellItem>(_onAddUpsellItem);
    on<RemoveUpsellItem>(_onRemoveUpsellItem);
    on<AddRelatedItem>(_onAddRelatedItem);
    on<RemoveRelatedItem>(_onRemoveRelatedItem);
    on<UpdateChannelAvailability>(_onUpdateChannelAvailability);
    on<UpdateKitchenSettings>(_onUpdateKitchenSettings);
    on<UpdateTaxCategory>(_onUpdateTaxCategory);
    on<UpdateSKU>(_onUpdateSKU);
    on<ToggleStockTracking>(_onToggleStockTracking);
    on<UpdateDietaryPreferences>(_onUpdateDietaryPreferences);
    on<NavigateToStep>(_onNavigateToStep);
    on<SaveDraft>(_onSaveDraft);
    on<SaveItem>(_onSaveItem);
    on<DuplicateItem>(_onDuplicateItem);
  }

  void _onInitialize(
      InitializeMenuEdit event, Emitter<MenuEditState> emit) async {
    emit(state.copyWith(status: MenuEditStatus.loading));

    final categoriesResult = await menuRepository.getMenuCategories();
    final itemsResult = await menuRepository.getMenuItems();

    categoriesResult.fold(
      (failure) => emit(state.copyWith(
        status: MenuEditStatus.error,
        errorMessage: 'Failed to load categories',
      )),
      (categories) {
        itemsResult.fold(
          (failure) => emit(state.copyWith(
            status: MenuEditStatus.error,
            errorMessage: 'Failed to load items',
          )),
          (items) {
            final item = event.existingItem ?? MenuItemEditEntity.empty();
            final validation = MenuEditState.validateItem(item);

            emit(state.copyWith(
              status: MenuEditStatus.editing,
              item: item,
              validation: validation,
              currentStep: 1,
              hasUnsavedChanges: false,
              categories: categories,
              availableItems: items,
              badges: _getMockBadges(),
              addOnCategories: _getMockAddOnCategories(),
            ));
          },
        );
      },
    );
  }

  void _onLoadCategoriesAndBadges(
      LoadCategoriesAndBadges event, Emitter<MenuEditState> emit) async {
    final result = await menuRepository.getMenuCategories();
    result.fold(
      (failure) => emit(state.copyWith(
        status: MenuEditStatus.error,
        errorMessage: 'Failed to load categories',
      )),
      (categories) => emit(state.copyWith(
        categories: categories,
        badges: _getMockBadges(),
        addOnCategories: _getMockAddOnCategories(),
      )),
    );
  }

  void _onLoadAvailableItems(
      LoadAvailableItems event, Emitter<MenuEditState> emit) async {
    final result = await menuRepository.getMenuItems();
    result.fold(
      (failure) => emit(state.copyWith(
        status: MenuEditStatus.error,
        errorMessage: 'Failed to load items',
      )),
      (items) => emit(state.copyWith(availableItems: items)),
    );
  }

  void _onUpdateName(UpdateItemName event, Emitter<MenuEditState> emit) {
    final updatedItem = state.item.copyWith(name: event.name);
    final validation = MenuEditState.validateItem(updatedItem);
    emit(state.copyWith(
        item: updatedItem, validation: validation, hasUnsavedChanges: true));
  }

  void _onUpdateDescription(
      UpdateItemDescription event, Emitter<MenuEditState> emit) {
    final updatedItem = state.item.copyWith(description: event.description);
    final validation = MenuEditState.validateItem(updatedItem);
    emit(state.copyWith(
        item: updatedItem, validation: validation, hasUnsavedChanges: true));
  }

  void _onUpdateCategory(
      UpdateItemCategory event, Emitter<MenuEditState> emit) {
    final updatedItem = state.item.copyWith(categoryId: event.categoryId);
    final validation = MenuEditState.validateItem(updatedItem);
    emit(state.copyWith(
        item: updatedItem, validation: validation, hasUnsavedChanges: true));
  }

  void _onUpdateImageUrl(UpdateImageUrl event, Emitter<MenuEditState> emit) {
    final updatedItem =
        state.item.copyWith(imageUrl: event.imageUrl, imageFile: null);
    final validation = MenuEditState.validateItem(updatedItem);
    emit(state.copyWith(
        item: updatedItem, validation: validation, hasUnsavedChanges: true));
  }

  void _onUpdateImageFile(UpdateImageFile event, Emitter<MenuEditState> emit) {
    final updatedItem =
        state.item.copyWith(imageFile: event.imageFile, imageUrl: null);
    final validation = MenuEditState.validateItem(updatedItem);
    emit(state.copyWith(
        item: updatedItem, validation: validation, hasUnsavedChanges: true));
  }

  void _onRemoveImage(RemoveImage event, Emitter<MenuEditState> emit) {
    final updatedItem = state.item.copyWith(imageUrl: null, imageFile: null);
    final validation = MenuEditState.validateItem(updatedItem);
    emit(state.copyWith(
        item: updatedItem, validation: validation, hasUnsavedChanges: true));
  }

  void _onToggleBadge(ToggleBadge event, Emitter<MenuEditState> emit) {
    final currentBadges = List<BadgeEntity>.from(state.item.badges);
    final exists = currentBadges.any((b) => b.id == event.badge.id);

    if (exists) {
      currentBadges.removeWhere((b) => b.id == event.badge.id);
    } else {
      currentBadges.add(event.badge);
    }

    final updatedItem = state.item.copyWith(badges: currentBadges);
    final validation = MenuEditState.validateItem(updatedItem);
    emit(state.copyWith(
        item: updatedItem, validation: validation, hasUnsavedChanges: true));
  }

  void _onSetHasSizes(SetHasSizes event, Emitter<MenuEditState> emit) {
    final updatedItem = state.item.copyWith(
      hasSizes: event.hasSizes,
      sizes: event.hasSizes ? state.item.sizes : [],
    );
    final validation = MenuEditState.validateItem(updatedItem);
    emit(state.copyWith(
        item: updatedItem, validation: validation, hasUnsavedChanges: true));
  }

  void _onAddSize(AddSize event, Emitter<MenuEditState> emit) {
    final newSizes = List<SizeEditEntity>.from(state.item.sizes);
    final isFirstSize = newSizes.isEmpty;

    newSizes.add(SizeEditEntity(
      name: '',
      dineInPrice: 0.0,
      isDefault: isFirstSize,
      addOnItems: const [],
    ));

    final updatedItem = state.item.copyWith(sizes: newSizes);
    final validation = MenuEditState.validateItem(updatedItem);
    emit(state.copyWith(
        item: updatedItem, validation: validation, hasUnsavedChanges: true));
  }

  void _onUpdateSize(UpdateSize event, Emitter<MenuEditState> emit) {
    final newSizes = List<SizeEditEntity>.from(state.item.sizes);
    if (event.index >= 0 && event.index < newSizes.length) {
      newSizes[event.index] = event.size;
      final updatedItem = state.item.copyWith(sizes: newSizes);
      final validation = MenuEditState.validateItem(updatedItem);
      emit(state.copyWith(
          item: updatedItem, validation: validation, hasUnsavedChanges: true));
    }
  }

  void _onDeleteSize(DeleteSize event, Emitter<MenuEditState> emit) {
    final newSizes = List<SizeEditEntity>.from(state.item.sizes);
    if (event.index >= 0 && event.index < newSizes.length) {
      final wasDefault = newSizes[event.index].isDefault;
      newSizes.removeAt(event.index);
      if (wasDefault && newSizes.isNotEmpty) {
        newSizes[0] = newSizes[0].copyWith(isDefault: true);
      }
      final updatedItem = state.item.copyWith(sizes: newSizes);
      final validation = MenuEditState.validateItem(updatedItem);
      emit(state.copyWith(
          item: updatedItem, validation: validation, hasUnsavedChanges: true));
    }
  }

  void _onSetDefaultSize(SetDefaultSize event, Emitter<MenuEditState> emit) {
    final newSizes = List<SizeEditEntity>.from(state.item.sizes);
    if (event.index >= 0 && event.index < newSizes.length) {
      for (int i = 0; i < newSizes.length; i++) {
        newSizes[i] = newSizes[i].copyWith(isDefault: i == event.index);
      }
      final updatedItem = state.item.copyWith(sizes: newSizes);
      final validation = MenuEditState.validateItem(updatedItem);
      emit(state.copyWith(
          item: updatedItem, validation: validation, hasUnsavedChanges: true));
    }
  }

  void _onAddAddOnItemToSize(
      AddAddOnItemToSize event, Emitter<MenuEditState> emit) {
    final newSizes = List<SizeEditEntity>.from(state.item.sizes);
    if (event.sizeIndex >= 0 && event.sizeIndex < newSizes.length) {
      final currentAddOns =
          List<AddOnItemEditEntity>.from(newSizes[event.sizeIndex].addOnItems);
      final exists =
          currentAddOns.any((item) => item.itemId == event.addOnItem.itemId);
      if (!exists) {
        currentAddOns.add(event.addOnItem);
        newSizes[event.sizeIndex] =
            newSizes[event.sizeIndex].copyWith(addOnItems: currentAddOns);
        final updatedItem = state.item.copyWith(sizes: newSizes);
        final validation = MenuEditState.validateItem(updatedItem);
        emit(state.copyWith(
            item: updatedItem,
            validation: validation,
            hasUnsavedChanges: true));
      }
    }
  }

  void _onRemoveAddOnItemFromSize(
      RemoveAddOnItemFromSize event, Emitter<MenuEditState> emit) {
    final newSizes = List<SizeEditEntity>.from(state.item.sizes);
    if (event.sizeIndex >= 0 && event.sizeIndex < newSizes.length) {
      final currentAddOns =
          List<AddOnItemEditEntity>.from(newSizes[event.sizeIndex].addOnItems);
      currentAddOns.removeWhere((item) => item.itemId == event.itemId);
      newSizes[event.sizeIndex] =
          newSizes[event.sizeIndex].copyWith(addOnItems: currentAddOns);
      final updatedItem = state.item.copyWith(sizes: newSizes);
      final validation = MenuEditState.validateItem(updatedItem);
      emit(state.copyWith(
          item: updatedItem, validation: validation, hasUnsavedChanges: true));
    }
  }

  void _onUpdateAddOnItemPrice(
      UpdateAddOnItemPrice event, Emitter<MenuEditState> emit) {
    final newSizes = List<SizeEditEntity>.from(state.item.sizes);
    if (event.sizeIndex >= 0 && event.sizeIndex < newSizes.length) {
      final currentAddOns =
          List<AddOnItemEditEntity>.from(newSizes[event.sizeIndex].addOnItems);
      final itemIndex =
          currentAddOns.indexWhere((item) => item.itemId == event.itemId);
      if (itemIndex != -1) {
        currentAddOns[itemIndex] =
            currentAddOns[itemIndex].copyWith(price: event.price);
        newSizes[event.sizeIndex] =
            newSizes[event.sizeIndex].copyWith(addOnItems: currentAddOns);
        final updatedItem = state.item.copyWith(sizes: newSizes);
        final validation = MenuEditState.validateItem(updatedItem);
        emit(state.copyWith(
            item: updatedItem,
            validation: validation,
            hasUnsavedChanges: true));
      }
    }
  }

  void _onToggleAddOnItemEnabled(
      ToggleAddOnItemEnabled event, Emitter<MenuEditState> emit) {
    final newSizes = List<SizeEditEntity>.from(state.item.sizes);
    if (event.sizeIndex >= 0 && event.sizeIndex < newSizes.length) {
      final currentAddOns =
          List<AddOnItemEditEntity>.from(newSizes[event.sizeIndex].addOnItems);
      final itemIndex =
          currentAddOns.indexWhere((item) => item.itemId == event.itemId);
      if (itemIndex != -1) {
        currentAddOns[itemIndex] = currentAddOns[itemIndex]
            .copyWith(isEnabled: !currentAddOns[itemIndex].isEnabled);
        newSizes[event.sizeIndex] =
            newSizes[event.sizeIndex].copyWith(addOnItems: currentAddOns);
        final updatedItem = state.item.copyWith(sizes: newSizes);
        final validation = MenuEditState.validateItem(updatedItem);
        emit(state.copyWith(
            item: updatedItem,
            validation: validation,
            hasUnsavedChanges: true));
      }
    }
  }

  void _onUpdateBasePrice(UpdateBasePrice event, Emitter<MenuEditState> emit) {
    final updatedItem = state.item.copyWith(basePrice: event.basePrice);
    final validation = MenuEditState.validateItem(updatedItem);
    emit(state.copyWith(
        item: updatedItem, validation: validation, hasUnsavedChanges: true));
  }

  void _onAddUpsellItem(AddUpsellItem event, Emitter<MenuEditState> emit) {
    final currentUpsells = List<String>.from(state.item.upsellItemIds);
    if (!currentUpsells.contains(event.itemId)) {
      currentUpsells.add(event.itemId);
      final updatedItem = state.item.copyWith(upsellItemIds: currentUpsells);
      final validation = MenuEditState.validateItem(updatedItem);
      emit(state.copyWith(
          item: updatedItem, validation: validation, hasUnsavedChanges: true));
    }
  }

  void _onRemoveUpsellItem(
      RemoveUpsellItem event, Emitter<MenuEditState> emit) {
    final currentUpsells = List<String>.from(state.item.upsellItemIds);
    currentUpsells.remove(event.itemId);
    final updatedItem = state.item.copyWith(upsellItemIds: currentUpsells);
    final validation = MenuEditState.validateItem(updatedItem);
    emit(state.copyWith(
        item: updatedItem, validation: validation, hasUnsavedChanges: true));
  }

  void _onAddRelatedItem(AddRelatedItem event, Emitter<MenuEditState> emit) {
    final currentRelated = List<String>.from(state.item.relatedItemIds);
    if (!currentRelated.contains(event.itemId)) {
      currentRelated.add(event.itemId);
      final updatedItem = state.item.copyWith(relatedItemIds: currentRelated);
      final validation = MenuEditState.validateItem(updatedItem);
      emit(state.copyWith(
          item: updatedItem, validation: validation, hasUnsavedChanges: true));
    }
  }

  void _onRemoveRelatedItem(
      RemoveRelatedItem event, Emitter<MenuEditState> emit) {
    final currentRelated = List<String>.from(state.item.relatedItemIds);
    currentRelated.remove(event.itemId);
    final updatedItem = state.item.copyWith(relatedItemIds: currentRelated);
    final validation = MenuEditState.validateItem(updatedItem);
    emit(state.copyWith(
        item: updatedItem, validation: validation, hasUnsavedChanges: true));
  }

  void _onUpdateChannelAvailability(
      UpdateChannelAvailability event, Emitter<MenuEditState> emit) {
    final updatedItem = state.item.copyWith(
      dineInAvailable: event.dineInAvailable ?? state.item.dineInAvailable,
      takeawayAvailable:
          event.takeawayAvailable ?? state.item.takeawayAvailable,
      deliveryAvailable:
          event.deliveryAvailable ?? state.item.deliveryAvailable,
    );
    final validation = MenuEditState.validateItem(updatedItem);
    emit(state.copyWith(
        item: updatedItem, validation: validation, hasUnsavedChanges: true));
  }

  void _onUpdateKitchenSettings(
      UpdateKitchenSettings event, Emitter<MenuEditState> emit) {
    final updatedItem = state.item.copyWith(
      kitchenStation: event.kitchenStation ?? state.item.kitchenStation,
      prepTimeMinutes: event.prepTimeMinutes ?? state.item.prepTimeMinutes,
      specialInstructions:
          event.specialInstructions ?? state.item.specialInstructions,
    );
    final validation = MenuEditState.validateItem(updatedItem);
    emit(state.copyWith(
        item: updatedItem, validation: validation, hasUnsavedChanges: true));
  }

  void _onUpdateTaxCategory(
      UpdateTaxCategory event, Emitter<MenuEditState> emit) {
    final updatedItem = state.item.copyWith(taxCategory: event.taxCategory);
    final validation = MenuEditState.validateItem(updatedItem);
    emit(state.copyWith(
        item: updatedItem, validation: validation, hasUnsavedChanges: true));
  }

  void _onUpdateSKU(UpdateSKU event, Emitter<MenuEditState> emit) {
    final updatedItem = state.item.copyWith(sku: event.sku);
    final validation = MenuEditState.validateItem(updatedItem);
    emit(state.copyWith(
        item: updatedItem, validation: validation, hasUnsavedChanges: true));
  }

  void _onToggleStockTracking(
      ToggleStockTracking event, Emitter<MenuEditState> emit) {
    final updatedItem =
        state.item.copyWith(stockTracking: !state.item.stockTracking);
    final validation = MenuEditState.validateItem(updatedItem);
    emit(state.copyWith(
        item: updatedItem, validation: validation, hasUnsavedChanges: true));
  }

  void _onUpdateDietaryPreferences(
      UpdateDietaryPreferences event, Emitter<MenuEditState> emit) {
    final updatedItem = state.item.copyWith(
      isVegetarian: event.isVegetarian ?? state.item.isVegetarian,
      isVegan: event.isVegan ?? state.item.isVegan,
      isGlutenFree: event.isGlutenFree ?? state.item.isGlutenFree,
      isDairyFree: event.isDairyFree ?? state.item.isDairyFree,
      isNutFree: event.isNutFree ?? state.item.isNutFree,
      isHalal: event.isHalal ?? state.item.isHalal,
    );
    final validation = MenuEditState.validateItem(updatedItem);
    emit(state.copyWith(
        item: updatedItem, validation: validation, hasUnsavedChanges: true));
  }

  void _onNavigateToStep(NavigateToStep event, Emitter<MenuEditState> emit) {
    if (event.step >= 1 && event.step <= 5) {
      emit(state.copyWith(currentStep: event.step));
    }
  }

  void _onSaveDraft(SaveDraft event, Emitter<MenuEditState> emit) async {
    emit(state.copyWith(status: MenuEditStatus.saving));
    await Future.delayed(const Duration(milliseconds: 500));
    emit(
        state.copyWith(status: MenuEditStatus.saved, hasUnsavedChanges: false));
  }

  void _onSaveItem(SaveItem event, Emitter<MenuEditState> emit) async {
    if (state.validation.isValid) {
      emit(state.copyWith(status: MenuEditStatus.saving));
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(
          status: MenuEditStatus.saved, hasUnsavedChanges: false));
    } else {
      emit(state.copyWith(
        status: MenuEditStatus.error,
        errorMessage: 'Please fix validation errors before saving',
      ));
    }
  }

  void _onDuplicateItem(DuplicateItem event, Emitter<MenuEditState> emit) {
    final duplicatedItem = state.item.copyWith(
      id: null,
      name: state.item.name,
    );
    final validation = MenuEditState.validateItem(duplicatedItem);
    emit(state.copyWith(
      item: duplicatedItem,
      validation: validation,
      hasUnsavedChanges: true,
      currentStep: 1,
    ));
  }

  List<BadgeEntity> _getMockBadges() {
    return const [
      BadgeEntity(id: 'new', label: 'New', color: '#4CAF50', isSystem: true),
      BadgeEntity(
          id: 'popular', label: 'Popular', color: '#FF9800', isSystem: true),
      BadgeEntity(
          id: 'spicy',
          label: 'Spicy',
          color: '#F44336',
          icon: '🌶️',
          isSystem: false),
      BadgeEntity(
          id: 'vegan',
          label: 'Vegan',
          color: '#8BC34A',
          icon: '🌱',
          isSystem: false),
      BadgeEntity(
          id: 'vegetarian',
          label: 'Vegetarian',
          color: '#8BC34A',
          icon: '🥗',
          isSystem: false),
      BadgeEntity(
          id: 'gluten-free',
          label: 'Gluten Free',
          color: '#2196F3',
          icon: '🌾',
          isSystem: false),
      BadgeEntity(
          id: 'halal',
          label: 'Halal',
          color: '#009688',
          icon: '☪️',
          isSystem: false),
      BadgeEntity(
          id: 'best-seller',
          label: 'Best Seller',
          color: '#FFD700',
          icon: '⭐',
          isSystem: true),
    ];
  }

  List<AddOnCategoryEntity> _getMockAddOnCategories() {
    return const [
      AddOnCategoryEntity(
        id: 'extras',
        name: 'Extras',
        description: 'Additional toppings and extras',
        items: [
          AddOnOptionEntity(id: 'cheese', name: 'Extra Cheese', basePrice: 2.0),
          AddOnOptionEntity(id: 'bacon', name: 'Bacon', basePrice: 3.0),
          AddOnOptionEntity(id: 'avocado', name: 'Avocado', basePrice: 2.5),
          AddOnOptionEntity(id: 'egg', name: 'Fried Egg', basePrice: 1.5),
        ],
      ),
      AddOnCategoryEntity(
        id: 'sauces',
        name: 'Sauces',
        description: 'Dipping sauces and condiments',
        items: [
          AddOnOptionEntity(id: 'ketchup', name: 'Ketchup', basePrice: 0.5),
          AddOnOptionEntity(id: 'mayo', name: 'Mayonnaise', basePrice: 0.5),
          AddOnOptionEntity(id: 'bbq', name: 'BBQ Sauce', basePrice: 0.75),
          AddOnOptionEntity(id: 'hot-sauce', name: 'Hot Sauce', basePrice: 0.5),
        ],
      ),
      AddOnCategoryEntity(
        id: 'sides',
        name: 'Sides',
        description: 'Additional side dishes',
        items: [
          AddOnOptionEntity(id: 'fries', name: 'French Fries', basePrice: 3.5),
          AddOnOptionEntity(id: 'salad', name: 'Garden Salad', basePrice: 4.0),
          AddOnOptionEntity(id: 'coleslaw', name: 'Coleslaw', basePrice: 2.5),
        ],
      ),
    ];
  }
}
