import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/combo_management_bloc.dart';
import '../../bloc/combo_management_event.dart';
import '../../../domain/entities/combo_slot_entity.dart';

const List<Map<String, dynamic>> _kMockCategories = [
  {'id': 'pizza', 'name': 'Pizzas'},
  {'id': 'burgers', 'name': 'Burgers'},
  {'id': 'sides', 'name': 'Sides'},
  {'id': 'drinks', 'name': 'Drinks'},
  {'id': 'desserts', 'name': 'Desserts'},
];

const Map<String, List<Map<String, dynamic>>> _kItemsByCategory = {
  'pizza': [
    {
      'id': 'pizza1',
      'name': 'Margherita Pizza',
      'price': 12.50,
      'sizes': [
        {'id': 'small', 'name': 'Small'},
        {'id': 'medium', 'name': 'Medium'},
        {'id': 'large', 'name': 'Large'},
      ],
      'modifiers': [
        {'id': 'extra_cheese', 'name': 'Extra Cheese'},
        {'id': 'olives', 'name': 'Olives'},
      ],
    },
    {
      'id': 'pizza2',
      'name': 'Pepperoni Pizza',
      'price': 14.00,
      'sizes': [
        {'id': 'small', 'name': 'Small'},
        {'id': 'medium', 'name': 'Medium'},
        {'id': 'large', 'name': 'Large'},
      ],
      'modifiers': [
        {'id': 'extra_cheese', 'name': 'Extra Cheese'},
        {'id': 'extra_pepperoni', 'name': 'Extra Pepperoni'},
      ],
    },
  ],
  'burgers': [
    {
      'id': 'burger1',
      'name': 'Classic Burger',
      'price': 11.00,
      'sizes': [
        {'id': 'regular', 'name': 'Regular'},
        {'id': 'large', 'name': 'Large'},
      ],
      'modifiers': [
        {'id': 'cheese', 'name': 'Cheese'},
        {'id': 'bacon', 'name': 'Bacon'},
        {'id': 'lettuce', 'name': 'Lettuce'},
      ],
    },
    {
      'id': 'burger2',
      'name': 'BBQ Burger',
      'price': 12.50,
      'sizes': [
        {'id': 'regular', 'name': 'Regular'},
        {'id': 'large', 'name': 'Large'},
      ],
      'modifiers': [
        {'id': 'cheese', 'name': 'Cheese'},
        {'id': 'onion_rings', 'name': 'Onion Rings'},
      ],
    },
  ],
  'sides': [
    {
      'id': 'fries1',
      'name': 'French Fries',
      'price': 4.50,
      'sizes': [
        {'id': 'small', 'name': 'Small'},
        {'id': 'large', 'name': 'Large'},
      ],
      'modifiers': [
        {'id': 'salt', 'name': 'Extra Salt'},
        {'id': 'ketchup', 'name': 'Ketchup'},
      ],
    },
    {
      'id': 'wings1',
      'name': 'Buffalo Wings',
      'price': 16.50,
      'sizes': [
        {'id': '6pc', 'name': '6 pieces'},
        {'id': '12pc', 'name': '12 pieces'},
      ],
      'modifiers': [
        {'id': 'hot_sauce', 'name': 'Hot Sauce'},
        {'id': 'ranch', 'name': 'Ranch Dip'},
      ],
    },
  ],
  'drinks': [
    {
      'id': 'drink1',
      'name': 'Coca Cola',
      'price': 2.50,
      'sizes': [
        {'id': 'regular', 'name': 'Regular'},
        {'id': 'large', 'name': 'Large'},
      ],
      'modifiers': [
        {'id': 'ice', 'name': 'Extra Ice'},
        {'id': 'lemon', 'name': 'Lemon'},
      ],
    },
  ],
  'desserts': [
    {
      'id': 'dessert1',
      'name': 'Chocolate Cake',
      'price': 6.50,
      'sizes': [
        {'id': 'slice', 'name': 'Slice'},
      ],
      'modifiers': [
        {'id': 'ice_cream', 'name': 'Add Ice Cream'},
      ],
    },
  ],
};

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  late final ValueNotifier<_AddItemViewState> _stateNotifier;

  @override
  void initState() {
    super.initState();
    _stateNotifier = ValueNotifier(_AddItemViewState.initial());
  }

  @override
  void dispose() {
    _stateNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_AddItemViewState>(
      valueListenable: _stateNotifier,
      builder: (context, viewState, _) {
        return Dialog(
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Add Combo Item',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Slot Name',
                            hintText: 'e.g., Main Item, Side, Drink',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => _updateState(
                            viewState.copyWith(slotName: value),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Item Source:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Specific Items'),
                                subtitle:
                                    const Text('Choose individual menu items'),
                                value: 'specific',
                                groupValue: viewState.sourceType,
                                onChanged: (value) => _updateState(
                                  viewState.copyWith(
                                      sourceType: value ?? 'specific'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Category'),
                                subtitle:
                                    const Text('Any item from a category'),
                                value: 'category',
                                groupValue: viewState.sourceType,
                                onChanged: (value) => _updateState(
                                  viewState.copyWith(
                                      sourceType: value ?? 'category'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (viewState.sourceType == 'specific')
                          _SpecificItemsSection(
                            viewState: viewState,
                            onStateChanged: _updateState,
                          )
                        else
                          _CategorySection(
                            viewState: viewState,
                            onStateChanged: _updateState,
                          ),
                        const SizedBox(height: 16),
                        _SettingsSection(
                          viewState: viewState,
                          onStateChanged: _updateState,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed:
                          viewState.canSave ? () => _saveSlot(viewState) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Add Item'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateState(_AddItemViewState newState) {
    _stateNotifier.value = newState;
  }

  void _saveSlot(_AddItemViewState viewState) {
    List<String> itemNames = [];
    List<String> itemIds = [];

    if (viewState.sourceType == 'specific') {
      itemNames = viewState.selectedItems
          .map((item) => item['name'] as String)
          .toList();
      itemIds =
          viewState.selectedItems.map((item) => item['id'] as String).toList();
    }

    String? categoryName;
    if (viewState.sourceType == 'category' &&
        viewState.selectedCategory != null) {
      categoryName = viewState.availableCategories.firstWhere(
        (cat) => cat['id'] == viewState.selectedCategory,
      )['name'] as String;
    }

    final slot = ComboSlotEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: viewState.slotName,
      sourceType: viewState.sourceType == 'specific'
          ? SlotSourceType.specific
          : SlotSourceType.category,
      specificItemIds: viewState.sourceType == 'specific' ? itemIds : [],
      specificItemNames: viewState.sourceType == 'specific' ? itemNames : [],
      categoryId: viewState.sourceType == 'category'
          ? viewState.selectedCategory
          : null,
      categoryName: categoryName,
      required: viewState.isRequired,
      defaultIncluded: viewState.defaultIncluded,
      maxQuantity: viewState.maxQuantity,
      defaultPrice: viewState.price,
      sortOrder: 0,
      allowedSizeIds:
          viewState.selectedSizes.values.expand((sizes) => sizes).toList(),
      modifierGroupAllowed: viewState.selectedModifiers.values
          .expand((mods) => mods)
          .fold<Map<String, bool>>({}, (map, modId) {
        map[modId] = true;
        return map;
      }),
    );

    context.read<ComboManagementBloc>().add(AddComboSlot(slot: slot));
    Navigator.of(context).pop();
  }
}

class _AddItemViewState extends Equatable {
  const _AddItemViewState({
    required this.sourceType,
    required this.slotName,
    required this.isRequired,
    required this.defaultIncluded,
    required this.maxQuantity,
    required this.price,
    required this.selectedItems,
    required this.selectedCategory,
    required this.availableCategories,
    required this.categoryItems,
    required this.selectedSizes,
    required this.selectedModifiers,
  });

  final String sourceType;
  final String slotName;
  final bool isRequired;
  final bool defaultIncluded;
  final int maxQuantity;
  final double price;
  final List<Map<String, dynamic>> selectedItems;
  final String? selectedCategory;
  final List<Map<String, dynamic>> availableCategories;
  final List<Map<String, dynamic>> categoryItems;
  final Map<String, List<String>> selectedSizes;
  final Map<String, List<String>> selectedModifiers;

  bool get canSave =>
      slotName.isNotEmpty &&
      ((sourceType == 'specific' && selectedItems.isNotEmpty) ||
          (sourceType == 'category' && selectedCategory != null));

  _AddItemViewState copyWith({
    String? sourceType,
    String? slotName,
    bool? isRequired,
    bool? defaultIncluded,
    int? maxQuantity,
    double? price,
    List<Map<String, dynamic>>? selectedItems,
    String? selectedCategory,
    List<Map<String, dynamic>>? availableCategories,
    List<Map<String, dynamic>>? categoryItems,
    Map<String, List<String>>? selectedSizes,
    Map<String, List<String>>? selectedModifiers,
  }) {
    return _AddItemViewState(
      sourceType: sourceType ?? this.sourceType,
      slotName: slotName ?? this.slotName,
      isRequired: isRequired ?? this.isRequired,
      defaultIncluded: defaultIncluded ?? this.defaultIncluded,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      price: price ?? this.price,
      selectedItems:
          selectedItems ?? List<Map<String, dynamic>>.from(this.selectedItems),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      availableCategories: availableCategories ??
          List<Map<String, dynamic>>.from(this.availableCategories),
      categoryItems:
          categoryItems ?? List<Map<String, dynamic>>.from(this.categoryItems),
      selectedSizes: selectedSizes ??
          this
              .selectedSizes
              .map((key, value) => MapEntry(key, List<String>.from(value))),
      selectedModifiers: selectedModifiers ??
          this.selectedModifiers.map(
                (key, value) => MapEntry(key, List<String>.from(value)),
              ),
    );
  }

  static _AddItemViewState initial() {
    return _AddItemViewState(
      sourceType: 'specific',
      slotName: '',
      isRequired: true,
      defaultIncluded: true,
      maxQuantity: 1,
      price: 0.0,
      selectedItems: const [],
      selectedCategory: null,
      availableCategories: _kMockCategories,
      categoryItems: const [],
      selectedSizes: const {},
      selectedModifiers: const {},
    );
  }

  @override
  List<Object?> get props => [
        sourceType,
        slotName,
        isRequired,
        defaultIncluded,
        maxQuantity,
        price,
        selectedItems,
        selectedCategory,
        availableCategories,
        categoryItems,
        selectedSizes,
        selectedModifiers,
      ];
}

class _SpecificItemsSection extends StatelessWidget {
  const _SpecificItemsSection({
    required this.viewState,
    required this.onStateChanged,
  });

  final _AddItemViewState viewState;
  final void Function(_AddItemViewState) onStateChanged;

  @override
  Widget build(BuildContext context) {
    final allAvailableItems =
        _kItemsByCategory.values.expand((list) => list).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Items:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: allAvailableItems.length,
            itemBuilder: (context, index) {
              final item = allAvailableItems[index];
              final itemId = item['id'] as String;
              final isSelected = viewState.selectedItems.any(
                (selected) => selected['id'] == itemId,
              );

              return ExpansionTile(
                leading: Checkbox(
                  value: isSelected,
                  onChanged: (selected) {
                    final updatedItems = List<Map<String, dynamic>>.from(
                      viewState.selectedItems,
                    );
                    final updatedSizes = Map<String, List<String>>.from(
                      viewState.selectedSizes,
                    );
                    final updatedModifiers = Map<String, List<String>>.from(
                      viewState.selectedModifiers,
                    );

                    if (selected == true) {
                      updatedItems.add(item);
                      if (viewState.price == 0) {
                        onStateChanged(
                            viewState.copyWith(price: item['price'] as double));
                      }
                      updatedSizes[itemId] = (item['sizes'] as List)
                          .map((s) => s['id'] as String)
                          .toList();
                      updatedModifiers[itemId] = [];
                    } else {
                      updatedItems
                          .removeWhere((selected) => selected['id'] == itemId);
                      updatedSizes.remove(itemId);
                      updatedModifiers.remove(itemId);
                    }

                    onStateChanged(
                      viewState.copyWith(
                        selectedItems: updatedItems,
                        selectedSizes: updatedSizes,
                        selectedModifiers: updatedModifiers,
                      ),
                    );
                  },
                ),
                title: Text(item['name'] as String),
                subtitle:
                    Text('	${(item['price'] as double).toStringAsFixed(2)}'),
                children: isSelected
                    ? [
                        _ItemSizesModifiers(
                          item: item,
                          selectedSizes: viewState.selectedSizes,
                          selectedModifiers: viewState.selectedModifiers,
                          onStateChanged: onStateChanged,
                          currentState: viewState,
                        ),
                      ]
                    : [],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${viewState.selectedItems.length} item(s) selected',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.viewState,
    required this.onStateChanged,
  });

  final _AddItemViewState viewState;
  final void Function(_AddItemViewState) onStateChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Category:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Choose a category',
          ),
          value: viewState.selectedCategory,
          items: viewState.availableCategories.map((category) {
            return DropdownMenuItem(
              value: category['id'] as String,
              child: Text(category['name'] as String),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) {
              onStateChanged(
                viewState.copyWith(
                  selectedCategory: null,
                  categoryItems: const [],
                ),
              );
            } else {
              onStateChanged(
                viewState.copyWith(
                  selectedCategory: value,
                  categoryItems: _kItemsByCategory[value] ?? const [],
                ),
              );
            }
          },
        ),
        if (viewState.selectedCategory != null &&
            viewState.categoryItems.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Items in this category:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: viewState.categoryItems.length,
              itemBuilder: (context, index) {
                final item = viewState.categoryItems[index];
                final itemId = item['id'] as String;
                final isSelected = viewState.selectedItems.any(
                  (selected) => selected['id'] == itemId,
                );

                return ExpansionTile(
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (selected) {
                      final updatedItems = List<Map<String, dynamic>>.from(
                        viewState.selectedItems,
                      );
                      final updatedSizes = Map<String, List<String>>.from(
                        viewState.selectedSizes,
                      );
                      final updatedModifiers = Map<String, List<String>>.from(
                        viewState.selectedModifiers,
                      );

                      if (selected == true) {
                        updatedItems.add(item);
                        if (viewState.price == 0) {
                          onStateChanged(viewState.copyWith(
                              price: item['price'] as double));
                        }
                        updatedSizes[itemId] = (item['sizes'] as List)
                            .map((s) => s['id'] as String)
                            .toList();
                        updatedModifiers[itemId] = [];
                      } else {
                        updatedItems.removeWhere(
                            (selected) => selected['id'] == itemId);
                        updatedSizes.remove(itemId);
                        updatedModifiers.remove(itemId);
                      }

                      onStateChanged(
                        viewState.copyWith(
                          selectedItems: updatedItems,
                          selectedSizes: updatedSizes,
                          selectedModifiers: updatedModifiers,
                        ),
                      );
                    },
                  ),
                  title: Text(item['name'] as String),
                  subtitle: Text(
                    '\$${(item['price'] as double).toStringAsFixed(2)}',
                  ),
                  children: isSelected
                      ? [
                          _ItemSizesModifiers(
                              item: item,
                              selectedSizes: viewState.selectedSizes,
                              selectedModifiers: viewState.selectedModifiers,
                              onStateChanged: onStateChanged,
                              currentState: viewState)
                        ]
                      : [],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _ItemSizesModifiers extends StatelessWidget {
  const _ItemSizesModifiers({
    required this.item,
    required this.selectedSizes,
    required this.selectedModifiers,
    required this.onStateChanged,
    required this.currentState,
  });

  final Map<String, dynamic> item;
  final Map<String, List<String>> selectedSizes;
  final Map<String, List<String>> selectedModifiers;
  final void Function(_AddItemViewState) onStateChanged;
  final _AddItemViewState currentState;

  @override
  Widget build(BuildContext context) {
    final itemId = item['id'] as String;
    final sizes = item['sizes'] as List<dynamic>;
    final modifiers = item['modifiers'] as List<dynamic>;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sizes.isNotEmpty) ...[
            const Text(
              'Available Sizes:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: sizes.map((size) {
                final sizeId = size['id'] as String;
                final sizeName = size['name'] as String;
                final isSelected =
                    selectedSizes[itemId]?.contains(sizeId) ?? false;

                return FilterChip(
                  label: Text(sizeName),
                  selected: isSelected,
                  onSelected: (selected) {
                    final updatedSizes = Map<String, List<String>>.from(
                      selectedSizes,
                    );
                    if (selected) {
                      updatedSizes[itemId] ??= [];
                      updatedSizes[itemId]!.add(sizeId);
                    } else {
                      updatedSizes[itemId]!.remove(sizeId);
                    }
                    onStateChanged(
                      currentState.copyWith(selectedSizes: updatedSizes),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          if (modifiers.isNotEmpty) ...[
            const Text(
              'Available Modifiers:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: modifiers.map((modifier) {
                final modifierId = modifier['id'] as String;
                final modifierName = modifier['name'] as String;
                final isSelected =
                    selectedModifiers[itemId]?.contains(modifierId) ?? false;

                return FilterChip(
                  label: Text(modifierName),
                  selected: isSelected,
                  onSelected: (selected) {
                    final updatedModifiers = Map<String, List<String>>.from(
                      selectedModifiers,
                    );
                    if (selected) {
                      updatedModifiers[itemId] ??= [];
                      updatedModifiers[itemId]!.add(modifierId);
                    } else {
                      updatedModifiers[itemId]!.remove(modifierId);
                    }
                    onStateChanged(
                      currentState.copyWith(
                          selectedModifiers: updatedModifiers),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.viewState,
    required this.onStateChanged,
  });

  final _AddItemViewState viewState;
  final void Function(_AddItemViewState) onStateChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item Settings:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),

        // Settings Row 1
        Row(
          children: [
            Expanded(
              child: SwitchListTile(
                title: const Text('Required'),
                subtitle: const Text('Customer must select'),
                value: viewState.isRequired,
                onChanged: (value) => onStateChanged(
                  viewState.copyWith(isRequired: value),
                ),
              ),
            ),
            Expanded(
              child: SwitchListTile(
                title: const Text('Default Included'),
                subtitle: const Text('Pre-selected for customer'),
                value: viewState.defaultIncluded,
                onChanged: (value) => onStateChanged(
                  viewState.copyWith(defaultIncluded: value),
                ),
              ),
            ),
          ],
        ),

        // Settings Row 2
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Max Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: viewState.maxQuantity.toString(),
                ),
                onChanged: (value) => onStateChanged(
                  viewState.copyWith(maxQuantity: int.tryParse(value) ?? 1),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Price (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: viewState.price > 0 ? viewState.price.toString() : '',
                ),
                onChanged: (value) => onStateChanged(
                  viewState.copyWith(price: double.tryParse(value) ?? 0.0),
                ),
              ),
            ),
          ],
        ),

        // Size & Modifier Controls (Collapsed - would be expanded in real implementation)
        const SizedBox(height: 16),
        ExpansionTile(
          title: const Text('Size Controls'),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('Small'),
                    value: true,
                    onChanged: (value) {},
                  ),
                  CheckboxListTile(
                    title: const Text('Medium'),
                    value: true,
                    onChanged: (value) {},
                  ),
                  CheckboxListTile(
                    title: const Text('Large'),
                    value: true,
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('Modifier Controls'),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('Extra Cheese'),
                    value: true,
                    onChanged: (value) {},
                  ),
                  CheckboxListTile(
                    title: const Text('Toppings'),
                    value: false,
                    onChanged: (value) {},
                  ),
                  CheckboxListTile(
                    title: const Text('Sauce Options'),
                    value: true,
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
