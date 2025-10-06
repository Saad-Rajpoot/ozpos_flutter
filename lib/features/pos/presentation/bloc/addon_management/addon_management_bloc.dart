import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/addon_management_entities.dart';
import 'addon_management_event.dart';
import 'addon_management_state.dart';

class AddonManagementBloc extends Bloc<AddonManagementEvent, AddonManagementState> {
  final Uuid _uuid = const Uuid();

  AddonManagementBloc() : super(const AddonManagementInitial()) {
    on<LoadAddonCategoriesEvent>(_onLoadCategories);
    on<LoadItemAddonAttachmentsEvent>(_onLoadItemAttachments);
    on<AttachAddonCategoryEvent>(_onAttachCategory);
    on<RemoveAddonCategoryEvent>(_onRemoveCategory);
    on<UpdateAddonRuleEvent>(_onUpdateRule);
    on<ToggleAddonItemSelectionEvent>(_onToggleItemSelection);
    on<OverrideAddonItemPriceEvent>(_onOverridePrice);
    on<UpdateSelectionRulesEvent>(_onUpdateSelectionRules);
    on<DuplicateRulesToSizeEvent>(_onDuplicateRules);
    on<ResetSizeRulesToItemLevelEvent>(_onResetSizeRules);
    on<CreateAddonCategoryEvent>(_onCreateCategory);
    on<UpdateAddonCategoryEvent>(_onUpdateCategory);
    on<DeleteAddonCategoryEvent>(_onDeleteCategory);
    on<ValidateAddonRulesEvent>(_onValidateRules);
    on<ReorderAddonItemsEvent>(_onReorderItems);
  }

  Future<void> _onLoadCategories(
    LoadAddonCategoriesEvent event,
    Emitter<AddonManagementState> emit,
  ) async {
    emit(const AddonManagementLoading());
    
    try {
      // Load from repository (mock for now)
      final categories = _getMockCategories();
      
      emit(AddonManagementLoaded(
        categories: categories,
        itemAttachments: {},
      ));
    } catch (e) {
      emit(AddonManagementError('Failed to load categories: $e'));
    }
  }

  Future<void> _onLoadItemAttachments(
    LoadItemAddonAttachmentsEvent event,
    Emitter<AddonManagementState> emit,
  ) async {
    if (state is! AddonManagementLoaded) return;
    
    final currentState = state as AddonManagementLoaded;
    
    try {
      // Load attachments for this item from repository (mock for now)
      final attachments = <ItemAddonAttachment>[];
      
      final updatedAttachments = Map<String, List<ItemAddonAttachment>>.from(
        currentState.itemAttachments,
      );
      updatedAttachments[event.itemId] = attachments;
      
      emit(currentState.copyWith(itemAttachments: updatedAttachments));
    } catch (e) {
      emit(AddonManagementError('Failed to load attachments: $e'));
    }
  }

  Future<void> _onAttachCategory(
    AttachAddonCategoryEvent event,
    Emitter<AddonManagementState> emit,
  ) async {
    if (state is! AddonManagementLoaded) return;
    
    final currentState = state as AddonManagementLoaded;
    
    // Create a new rule for this category
    final newRule = AddonRule(
      id: _uuid.v4(),
      categoryId: event.categoryId,
      minSelection: 0,
      maxSelection: 999,
      isRequired: false,
      defaultItemIds: [],
      priceOverrides: {},
    );
    
    // Get existing attachments
    final itemAttachments = List<ItemAddonAttachment>.from(
      currentState.getItemAttachments(event.itemId),
    );
    
    // Check if attachment already exists
    final existingIndex = itemAttachments.indexWhere(
      (a) => a.sizeId == event.sizeId,
    );
    
    if (existingIndex >= 0) {
      // Update existing attachment
      final existing = itemAttachments[existingIndex];
      itemAttachments[existingIndex] = existing.copyWith(
        rules: [...existing.rules, newRule],
      );
    } else {
      // Create new attachment
      itemAttachments.add(ItemAddonAttachment(
        itemId: event.itemId,
        sizeId: event.sizeId,
        rules: [newRule],
        appliesToAllSizes: event.appliesToAllSizes,
      ));
    }
    
    final updatedAttachments = Map<String, List<ItemAddonAttachment>>.from(
      currentState.itemAttachments,
    );
    updatedAttachments[event.itemId] = itemAttachments;
    
    emit(currentState.copyWith(
      itemAttachments: updatedAttachments,
      hasUnsavedChanges: true,
    ));
  }

  Future<void> _onRemoveCategory(
    RemoveAddonCategoryEvent event,
    Emitter<AddonManagementState> emit,
  ) async {
    if (state is! AddonManagementLoaded) return;
    
    final currentState = state as AddonManagementLoaded;
    
    final itemAttachments = List<ItemAddonAttachment>.from(
      currentState.getItemAttachments(event.itemId),
    );
    
    // Remove the rule from the appropriate attachment
    for (var i = 0; i < itemAttachments.length; i++) {
      if (itemAttachments[i].sizeId == event.sizeId) {
        final updatedRules = itemAttachments[i].rules
            .where((r) => r.categoryId != event.categoryId)
            .toList();
        
        if (updatedRules.isEmpty) {
          itemAttachments.removeAt(i);
        } else {
          itemAttachments[i] = itemAttachments[i].copyWith(rules: updatedRules);
        }
        break;
      }
    }
    
    final updatedAttachments = Map<String, List<ItemAddonAttachment>>.from(
      currentState.itemAttachments,
    );
    updatedAttachments[event.itemId] = itemAttachments;
    
    emit(currentState.copyWith(
      itemAttachments: updatedAttachments,
      hasUnsavedChanges: true,
    ));
  }

  Future<void> _onUpdateRule(
    UpdateAddonRuleEvent event,
    Emitter<AddonManagementState> emit,
  ) async {
    if (state is! AddonManagementLoaded) return;
    
    final currentState = state as AddonManagementLoaded;
    
    final itemAttachments = List<ItemAddonAttachment>.from(
      currentState.getItemAttachments(event.itemId),
    );
    
    // Find and update the rule
    for (var i = 0; i < itemAttachments.length; i++) {
      if (itemAttachments[i].sizeId == event.sizeId) {
        final rules = List<AddonRule>.from(itemAttachments[i].rules);
        final ruleIndex = rules.indexWhere((r) => r.id == event.rule.id);
        
        if (ruleIndex >= 0) {
          rules[ruleIndex] = event.rule;
          itemAttachments[i] = itemAttachments[i].copyWith(rules: rules);
        }
        break;
      }
    }
    
    final updatedAttachments = Map<String, List<ItemAddonAttachment>>.from(
      currentState.itemAttachments,
    );
    updatedAttachments[event.itemId] = itemAttachments;
    
    // Validate the updated rule
    final category = currentState.getCategoryById(event.rule.categoryId);
    final validationResults = Map<String, Map<String, AddonRuleValidation>>.from(
      currentState.validationResults,
    );
    
    if (category != null) {
      final validation = event.rule.validate(category);
      if (!validationResults.containsKey(event.itemId)) {
        validationResults[event.itemId] = {};
      }
      validationResults[event.itemId]![event.rule.categoryId] = validation;
    }
    
    emit(currentState.copyWith(
      itemAttachments: updatedAttachments,
      validationResults: validationResults,
      hasUnsavedChanges: true,
    ));
  }

  Future<void> _onToggleItemSelection(
    ToggleAddonItemSelectionEvent event,
    Emitter<AddonManagementState> emit,
  ) async {
    if (state is! AddonManagementLoaded) return;
    
    final currentState = state as AddonManagementLoaded;
    
    final itemAttachments = List<ItemAddonAttachment>.from(
      currentState.getItemAttachments(event.itemId),
    );
    
    // Find the rule and toggle the item
    for (var i = 0; i < itemAttachments.length; i++) {
      if (itemAttachments[i].sizeId == event.sizeId) {
        final rules = List<AddonRule>.from(itemAttachments[i].rules);
        final ruleIndex = rules.indexWhere((r) => r.categoryId == event.categoryId);
        
        if (ruleIndex >= 0) {
          final rule = rules[ruleIndex];
          final defaultIds = List<String>.from(rule.defaultItemIds);
          
          if (defaultIds.contains(event.addonItemId)) {
            defaultIds.remove(event.addonItemId);
          } else {
            defaultIds.add(event.addonItemId);
          }
          
          rules[ruleIndex] = rule.copyWith(defaultItemIds: defaultIds);
          itemAttachments[i] = itemAttachments[i].copyWith(rules: rules);
        }
        break;
      }
    }
    
    final updatedAttachments = Map<String, List<ItemAddonAttachment>>.from(
      currentState.itemAttachments,
    );
    updatedAttachments[event.itemId] = itemAttachments;
    
    emit(currentState.copyWith(
      itemAttachments: updatedAttachments,
      hasUnsavedChanges: true,
    ));
  }

  Future<void> _onOverridePrice(
    OverrideAddonItemPriceEvent event,
    Emitter<AddonManagementState> emit,
  ) async {
    if (state is! AddonManagementLoaded) return;
    
    final currentState = state as AddonManagementLoaded;
    
    final itemAttachments = List<ItemAddonAttachment>.from(
      currentState.getItemAttachments(event.itemId),
    );
    
    // Find the rule and update price override
    for (var i = 0; i < itemAttachments.length; i++) {
      if (itemAttachments[i].sizeId == event.sizeId) {
        final rules = List<AddonRule>.from(itemAttachments[i].rules);
        final ruleIndex = rules.indexWhere((r) => r.categoryId == event.categoryId);
        
        if (ruleIndex >= 0) {
          final rule = rules[ruleIndex];
          final overrides = Map<String, double>.from(rule.priceOverrides);
          
          if (event.overridePrice == null) {
            overrides.remove(event.addonItemId);
          } else {
            overrides[event.addonItemId] = event.overridePrice!;
          }
          
          rules[ruleIndex] = rule.copyWith(priceOverrides: overrides);
          itemAttachments[i] = itemAttachments[i].copyWith(rules: rules);
        }
        break;
      }
    }
    
    final updatedAttachments = Map<String, List<ItemAddonAttachment>>.from(
      currentState.itemAttachments,
    );
    updatedAttachments[event.itemId] = itemAttachments;
    
    emit(currentState.copyWith(
      itemAttachments: updatedAttachments,
      hasUnsavedChanges: true,
    ));
  }

  Future<void> _onUpdateSelectionRules(
    UpdateSelectionRulesEvent event,
    Emitter<AddonManagementState> emit,
  ) async {
    if (state is! AddonManagementLoaded) return;
    
    final currentState = state as AddonManagementLoaded;
    
    final itemAttachments = List<ItemAddonAttachment>.from(
      currentState.getItemAttachments(event.itemId),
    );
    
    // Find the rule and update selection rules
    for (var i = 0; i < itemAttachments.length; i++) {
      if (itemAttachments[i].sizeId == event.sizeId) {
        final rules = List<AddonRule>.from(itemAttachments[i].rules);
        final ruleIndex = rules.indexWhere((r) => r.categoryId == event.categoryId);
        
        if (ruleIndex >= 0) {
          rules[ruleIndex] = rules[ruleIndex].copyWith(
            minSelection: event.minSelection,
            maxSelection: event.maxSelection,
            isRequired: event.isRequired,
          );
          itemAttachments[i] = itemAttachments[i].copyWith(rules: rules);
        }
        break;
      }
    }
    
    final updatedAttachments = Map<String, List<ItemAddonAttachment>>.from(
      currentState.itemAttachments,
    );
    updatedAttachments[event.itemId] = itemAttachments;
    
    emit(currentState.copyWith(
      itemAttachments: updatedAttachments,
      hasUnsavedChanges: true,
    ));
  }

  Future<void> _onDuplicateRules(
    DuplicateRulesToSizeEvent event,
    Emitter<AddonManagementState> emit,
  ) async {
    if (state is! AddonManagementLoaded) return;
    
    final currentState = state as AddonManagementLoaded;
    
    final itemAttachments = List<ItemAddonAttachment>.from(
      currentState.getItemAttachments(event.itemId),
    );
    
    // Find source rules
    ItemAddonAttachment? sourceAttachment;
    for (final attachment in itemAttachments) {
      if (attachment.sizeId == event.sourceSizeId) {
        sourceAttachment = attachment;
        break;
      }
    }
    
    if (sourceAttachment == null) return;
    
    // Duplicate rules with new IDs
    final duplicatedRules = sourceAttachment.rules.map((rule) {
      return rule.copyWith(id: _uuid.v4());
    }).toList();
    
    // Check if target already has attachment
    final targetIndex = itemAttachments.indexWhere(
      (a) => a.sizeId == event.targetSizeId,
    );
    
    if (targetIndex >= 0) {
      itemAttachments[targetIndex] = itemAttachments[targetIndex].copyWith(
        rules: duplicatedRules,
      );
    } else {
      itemAttachments.add(ItemAddonAttachment(
        itemId: event.itemId,
        sizeId: event.targetSizeId,
        rules: duplicatedRules,
        appliesToAllSizes: false,
      ));
    }
    
    final updatedAttachments = Map<String, List<ItemAddonAttachment>>.from(
      currentState.itemAttachments,
    );
    updatedAttachments[event.itemId] = itemAttachments;
    
    emit(currentState.copyWith(
      itemAttachments: updatedAttachments,
      hasUnsavedChanges: true,
    ));
  }

  Future<void> _onResetSizeRules(
    ResetSizeRulesToItemLevelEvent event,
    Emitter<AddonManagementState> emit,
  ) async {
    if (state is! AddonManagementLoaded) return;
    
    final currentState = state as AddonManagementLoaded;
    
    final itemAttachments = List<ItemAddonAttachment>.from(
      currentState.getItemAttachments(event.itemId),
    );
    
    // Remove size-specific attachment
    itemAttachments.removeWhere((a) => a.sizeId == event.sizeId);
    
    final updatedAttachments = Map<String, List<ItemAddonAttachment>>.from(
      currentState.itemAttachments,
    );
    updatedAttachments[event.itemId] = itemAttachments;
    
    emit(currentState.copyWith(
      itemAttachments: updatedAttachments,
      hasUnsavedChanges: true,
    ));
  }

  Future<void> _onCreateCategory(
    CreateAddonCategoryEvent event,
    Emitter<AddonManagementState> emit,
  ) async {
    if (state is! AddonManagementLoaded) return;
    
    final currentState = state as AddonManagementLoaded;
    
    final newCategory = AddonCategory(
      id: _uuid.v4(),
      name: event.name,
      description: event.description,
      items: event.items,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    final categories = [...currentState.categories, newCategory];
    
    emit(currentState.copyWith(
      categories: categories,
      hasUnsavedChanges: true,
    ));
  }

  Future<void> _onUpdateCategory(
    UpdateAddonCategoryEvent event,
    Emitter<AddonManagementState> emit,
  ) async {
    if (state is! AddonManagementLoaded) return;
    
    final currentState = state as AddonManagementLoaded;
    
    final categories = currentState.categories.map((c) {
      if (c.id == event.category.id) {
        return event.category.copyWith(updatedAt: DateTime.now());
      }
      return c;
    }).toList();
    
    emit(currentState.copyWith(
      categories: categories,
      hasUnsavedChanges: true,
    ));
  }

  Future<void> _onDeleteCategory(
    DeleteAddonCategoryEvent event,
    Emitter<AddonManagementState> emit,
  ) async {
    if (state is! AddonManagementLoaded) return;
    
    final currentState = state as AddonManagementLoaded;
    
    final categories = currentState.categories
        .where((c) => c.id != event.categoryId)
        .toList();
    
    // Also remove all attachments using this category
    final updatedAttachments = <String, List<ItemAddonAttachment>>{};
    for (final entry in currentState.itemAttachments.entries) {
      final filtered = entry.value.map((attachment) {
        final rules = attachment.rules
            .where((r) => r.categoryId != event.categoryId)
            .toList();
        return attachment.copyWith(rules: rules);
      }).where((a) => a.rules.isNotEmpty).toList();
      
      if (filtered.isNotEmpty) {
        updatedAttachments[entry.key] = filtered;
      }
    }
    
    emit(currentState.copyWith(
      categories: categories,
      itemAttachments: updatedAttachments,
      hasUnsavedChanges: true,
    ));
  }

  Future<void> _onValidateRules(
    ValidateAddonRulesEvent event,
    Emitter<AddonManagementState> emit,
  ) async {
    if (state is! AddonManagementLoaded) return;
    
    final currentState = state as AddonManagementLoaded;
    
    final itemAttachments = currentState.getItemAttachments(event.itemId);
    final validationResults = <String, AddonRuleValidation>{};
    
    for (final attachment in itemAttachments) {
      for (final rule in attachment.rules) {
        final category = currentState.getCategoryById(rule.categoryId);
        if (category != null) {
          validationResults[rule.categoryId] = rule.validate(category);
        }
      }
    }
    
    final allValidations = Map<String, Map<String, AddonRuleValidation>>.from(
      currentState.validationResults,
    );
    allValidations[event.itemId] = validationResults;
    
    emit(currentState.copyWith(validationResults: allValidations));
  }

  Future<void> _onReorderItems(
    ReorderAddonItemsEvent event,
    Emitter<AddonManagementState> emit,
  ) async {
    if (state is! AddonManagementLoaded) return;
    
    final currentState = state as AddonManagementLoaded;
    
    final categories = currentState.categories.map((c) {
      if (c.id == event.categoryId) {
        final reorderedItems = <AddonItem>[];
        for (var i = 0; i < event.itemIds.length; i++) {
          final item = c.items.firstWhere((item) => item.id == event.itemIds[i]);
          reorderedItems.add(item.copyWith(sortOrder: i));
        }
        return c.copyWith(items: reorderedItems);
      }
      return c;
    }).toList();
    
    emit(currentState.copyWith(
      categories: categories,
      hasUnsavedChanges: true,
    ));
  }

  // Mock data for testing
  List<AddonCategory> _getMockCategories() {
    final now = DateTime.now();
    
    return [
      AddonCategory(
        id: 'cat_cheese',
        name: 'Cheese Options',
        description: 'Select your cheese preferences',
        items: [
          const AddonItem(
            id: 'cheese_cheddar',
            name: 'Cheddar',
            basePriceDelta: 1.50,
            sortOrder: 0,
          ),
          const AddonItem(
            id: 'cheese_swiss',
            name: 'Swiss',
            basePriceDelta: 2.00,
            sortOrder: 1,
          ),
          const AddonItem(
            id: 'cheese_mozzarella',
            name: 'Mozzarella',
            basePriceDelta: 1.75,
            sortOrder: 2,
          ),
          const AddonItem(
            id: 'cheese_blue',
            name: 'Blue Cheese',
            basePriceDelta: 2.50,
            sortOrder: 3,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),
      AddonCategory(
        id: 'cat_sauces',
        name: 'Sauces',
        description: 'Add your favorite sauces',
        items: [
          const AddonItem(
            id: 'sauce_bbq',
            name: 'BBQ Sauce',
            basePriceDelta: 0.50,
            sortOrder: 0,
          ),
          const AddonItem(
            id: 'sauce_mayo',
            name: 'Mayo',
            basePriceDelta: 0.30,
            sortOrder: 1,
          ),
          const AddonItem(
            id: 'sauce_mustard',
            name: 'Mustard',
            basePriceDelta: 0.30,
            sortOrder: 2,
          ),
          const AddonItem(
            id: 'sauce_hot',
            name: 'Hot Sauce',
            basePriceDelta: 0.50,
            sortOrder: 3,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),
      AddonCategory(
        id: 'cat_toppings',
        name: 'Extra Toppings',
        description: 'Customize with extra toppings',
        items: [
          const AddonItem(
            id: 'topping_bacon',
            name: 'Bacon',
            basePriceDelta: 2.00,
            sortOrder: 0,
          ),
          const AddonItem(
            id: 'topping_avocado',
            name: 'Avocado',
            basePriceDelta: 1.50,
            sortOrder: 1,
          ),
          const AddonItem(
            id: 'topping_mushroom',
            name: 'Mushrooms',
            basePriceDelta: 1.00,
            sortOrder: 2,
          ),
          const AddonItem(
            id: 'topping_onion',
            name: 'Grilled Onions',
            basePriceDelta: 0.75,
            sortOrder: 3,
          ),
          const AddonItem(
            id: 'topping_jalapeno',
            name: 'Jalapeños',
            basePriceDelta: 0.75,
            sortOrder: 4,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
