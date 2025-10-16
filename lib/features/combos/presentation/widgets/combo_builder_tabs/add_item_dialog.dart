import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/combo_management_bloc.dart';
import '../../bloc/combo_management_event.dart';
import '../../../domain/entities/combo_slot_entity.dart';

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  String _sourceType = 'specific'; // 'specific' or 'category'
  String _slotName = '';
  bool _required = true;
  bool _defaultIncluded = true;
  int _maxQuantity = 1;
  double _price = 0.0;
  final List<Map<String, dynamic>> _selectedItems = [];
  String? _selectedCategory;
  List<Map<String, dynamic>> _availableCategories = [];
  List<Map<String, dynamic>> _categoryItems = [];
  final Map<String, List<String>> _selectedSizes = {};
  final Map<String, List<String>> _selectedModifiers = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    // Mock categories - in real implementation, fetch from database
    _availableCategories = [
      {'id': 'pizza', 'name': 'Pizzas'},
      {'id': 'burgers', 'name': 'Burgers'},
      {'id': 'sides', 'name': 'Sides'},
      {'id': 'drinks', 'name': 'Drinks'},
      {'id': 'desserts', 'name': 'Desserts'},
    ];
  }

  void _loadItemsForCategory(String categoryId) {
    // Mock items for category - in real implementation, fetch from database
    final itemsByCategory = {
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
    };

    setState(() {
      _categoryItems = itemsByCategory[categoryId] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Add Combo Item',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Scrollable content area
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Slot Name
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Slot Name',
                        hintText: 'e.g., Main Item, Side, Drink',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => setState(() => _slotName = value),
                    ),
                    const SizedBox(height: 16),

                    // Source Type Selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                subtitle: const Text(
                                  'Choose individual menu items',
                                ),
                                value: 'specific',
                                // ignore: deprecated_member_use
                                groupValue: _sourceType,
                                // ignore: deprecated_member_use
                                onChanged: (value) =>
                                    setState(() => _sourceType = value!),
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Category'),
                                subtitle: const Text(
                                  'Any item from a category',
                                ),
                                value: 'category',
                                // ignore: deprecated_member_use
                                groupValue: _sourceType,
                                // ignore: deprecated_member_use
                                onChanged: (value) =>
                                    setState(() => _sourceType = value!),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Item/Category Selection
                    if (_sourceType == 'specific')
                      _buildSpecificItemsSection()
                    else
                      _buildCategorySection(),

                    const SizedBox(height: 16),

                    // Settings
                    _buildSettingsSection(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _canSave() ? _saveSlot : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Add Item'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificItemsSection() {
    // All available items from all categories
    final allAvailableItems = <Map<String, dynamic>>[];

    // Collect items from all categories
    final itemsByCategory = {
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
    };

    for (final items in itemsByCategory.values) {
      allAvailableItems.addAll(items);
    }

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
              final isSelected = _selectedItems.any(
                (selected) => selected['id'] == item['id'],
              );

              return ExpansionTile(
                leading: Checkbox(
                  value: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected!) {
                        _selectedItems.add(item);
                        if (_price == 0) _price = item['price'] as double;
                        // Initialize with default selections
                        _selectedSizes[item['id']] = (item['sizes'] as List)
                            .map((s) => s['id'] as String)
                            .toList();
                        _selectedModifiers[item['id']] = [];
                      } else {
                        _selectedItems.removeWhere(
                          (selected) => selected['id'] == item['id'],
                        );
                        _selectedSizes.remove(item['id']);
                        _selectedModifiers.remove(item['id']);
                      }
                    });
                  },
                ),
                title: Text(item['name'] as String),
                subtitle: Text(
                  '\$${(item['price'] as double).toStringAsFixed(2)}',
                ),
                children: isSelected ? [_buildItemSizesAndModifiers(item)] : [],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_selectedItems.length} item(s) selected',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
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
          value: _selectedCategory,
          items: _availableCategories.map((category) {
            return DropdownMenuItem(
              value: category['id'] as String,
              child: Text(category['name'] as String),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
              if (value != null) {
                _loadItemsForCategory(value);
              }
            });
          },
        ),
        if (_selectedCategory != null && _categoryItems.isNotEmpty) ...[
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
              itemCount: _categoryItems.length,
              itemBuilder: (context, index) {
                final item = _categoryItems[index];
                final isSelected = _selectedItems.any(
                  (selected) => selected['id'] == item['id'],
                );

                return ExpansionTile(
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (selected) {
                      setState(() {
                        if (selected!) {
                          _selectedItems.add(item);
                          if (_price == 0) _price = item['price'] as double;
                          _selectedSizes[item['id']] = (item['sizes'] as List)
                              .map((s) => s['id'] as String)
                              .toList();
                          _selectedModifiers[item['id']] = [];
                        } else {
                          _selectedItems.removeWhere(
                            (selected) => selected['id'] == item['id'],
                          );
                          _selectedSizes.remove(item['id']);
                          _selectedModifiers.remove(item['id']);
                        }
                      });
                    },
                  ),
                  title: Text(item['name'] as String),
                  subtitle: Text(
                    '\$${(item['price'] as double).toStringAsFixed(2)}',
                  ),
                  children:
                      isSelected ? [_buildItemSizesAndModifiers(item)] : [],
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildItemSizesAndModifiers(Map<String, dynamic> item) {
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
                    _selectedSizes[itemId]?.contains(sizeId) ?? false;

                return FilterChip(
                  label: Text(sizeName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSizes[itemId] ??= [];
                      if (selected) {
                        _selectedSizes[itemId]!.add(sizeId);
                      } else {
                        _selectedSizes[itemId]!.remove(sizeId);
                      }
                    });
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
                    _selectedModifiers[itemId]?.contains(modifierId) ?? false;

                return FilterChip(
                  label: Text(modifierName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedModifiers[itemId] ??= [];
                      if (selected) {
                        _selectedModifiers[itemId]!.add(modifierId);
                      } else {
                        _selectedModifiers[itemId]!.remove(modifierId);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
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
                value: _required,
                onChanged: (value) => setState(() => _required = value),
              ),
            ),
            Expanded(
              child: SwitchListTile(
                title: const Text('Default Included'),
                subtitle: const Text('Pre-selected for customer'),
                value: _defaultIncluded,
                onChanged: (value) => setState(() => _defaultIncluded = value),
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
                  text: _maxQuantity.toString(),
                ),
                onChanged: (value) =>
                    setState(() => _maxQuantity = int.tryParse(value) ?? 1),
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
                  text: _price > 0 ? _price.toString() : '',
                ),
                onChanged: (value) =>
                    setState(() => _price = double.tryParse(value) ?? 0.0),
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

  bool _canSave() {
    return _slotName.isNotEmpty &&
        ((_sourceType == 'specific' && _selectedItems.isNotEmpty) ||
            (_sourceType == 'category' && _selectedCategory != null));
  }

  void _saveSlot() {
    List<String> itemNames = [];
    List<String> itemIds = [];

    if (_sourceType == 'specific') {
      itemNames = _selectedItems.map((item) => item['name'] as String).toList();
      itemIds = _selectedItems.map((item) => item['id'] as String).toList();
    }

    String? categoryName;
    if (_sourceType == 'category' && _selectedCategory != null) {
      categoryName = _availableCategories.firstWhere(
        (cat) => cat['id'] == _selectedCategory,
      )['name'] as String;
    }

    final slot = ComboSlotEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _slotName,
      sourceType: _sourceType == 'specific'
          ? SlotSourceType.specific
          : SlotSourceType.category,
      specificItemIds: _sourceType == 'specific' ? itemIds : [],
      specificItemNames: _sourceType == 'specific' ? itemNames : [],
      categoryId: _sourceType == 'category' ? _selectedCategory : null,
      categoryName: categoryName,
      required: _required,
      defaultIncluded: _defaultIncluded,
      maxQuantity: _maxQuantity,
      defaultPrice: _price,
      sortOrder: 0,
      // Include size and modifier restrictions
      allowedSizeIds: _selectedSizes.values.expand((sizes) => sizes).toList(),
      modifierGroupAllowed: _selectedModifiers.values
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
