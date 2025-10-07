import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/menu_edit_bloc.dart';
import '../bloc/menu_edit_event.dart';
import '../bloc/menu_edit_state.dart';
import '../../domain/entities/menu_item_edit_entity.dart';

/// Step 1: Item Details - Name, Description, Category, Image, Badges
class Step1ItemDetails extends StatefulWidget {
  const Step1ItemDetails({super.key});

  @override
  State<Step1ItemDetails> createState() => _Step1ItemDetailsState();
}

class _Step1ItemDetailsState extends State<Step1ItemDetails> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _skuController;
  final ImagePicker _imagePicker = ImagePicker();
  String _lastItemId = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _skuController = TextEditingController();
  }

  void _updateControllers(MenuEditState state) {
    // Only update if the item has changed (to avoid cursor jumping)
    // Check both ID and name to detect when data is loaded
    final itemId = state.item.id ?? '';
    final itemIdentifier = '$itemId-${state.item.name}';

    if (itemIdentifier != _lastItemId) {
      _lastItemId = itemIdentifier;

      // Only update if text actually differs to prevent cursor jumping during typing
      if (_nameController.text != state.item.name) {
        _nameController.text = state.item.name;
      }
      if (_descriptionController.text != state.item.description) {
        _descriptionController.text = state.item.description;
      }
      if (_skuController.text != state.item.sku) {
        _skuController.text = state.item.sku;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuEditBloc, MenuEditState>(
      builder: (context, state) {
        _updateControllers(state);
        return SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Banner
                if (state.validation.errors.isNotEmpty ||
                    state.validation.warnings.isNotEmpty)
                  _buildInfoBanner(state),
                if (state.validation.errors.isNotEmpty ||
                    state.validation.warnings.isNotEmpty)
                  const SizedBox(height: 24),

                // Image Upload Section
                _buildImageSection(state),
                const SizedBox(height: 32),

                // Item Name
                _buildTextField(
                  label: 'Item Name *',
                  controller: _nameController,
                  required: true,
                  hint: 'e.g., Margherita Pizza',
                  error: state.validation.errors.any((e) => e.contains('name')),
                  onChanged: (value) {
                    context.read<MenuEditBloc>().add(UpdateItemName(value));
                  },
                ),
                const SizedBox(height: 24),

                // Description
                _buildTextField(
                  label: 'Description',
                  controller: _descriptionController,
                  hint: 'Describe this item...',
                  maxLines: 4,
                  onChanged: (value) {
                    context.read<MenuEditBloc>().add(
                      UpdateItemDescription(value),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Category Selector
                _buildCategorySelector(state),
                const SizedBox(height: 24),

                // SKU
                _buildTextField(
                  label: 'SKU',
                  controller: _skuController,
                  hint: 'Item code or SKU',
                  onChanged: (value) {
                    context.read<MenuEditBloc>().add(UpdateSKU(value));
                  },
                ),
                const SizedBox(height: 24),

                // Badges Section
                _buildBadgesSection(state),
                const SizedBox(height: 32),

                // Pricing Configuration Section
                _buildPricingSection(state),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoBanner(MenuEditState state) {
    if (state.validation.errors.isEmpty && state.validation.warnings.isEmpty) {
      return const SizedBox.shrink();
    }

    final hasErrors = state.validation.errors.isNotEmpty;
    final messages = hasErrors
        ? state.validation.errors
        : state.validation.warnings;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasErrors ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasErrors ? Colors.red.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasErrors ? Icons.error_outline : Icons.warning_amber_rounded,
            color: hasErrors ? Colors.red.shade700 : Colors.orange.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: messages.map((msg) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    msg,
                    style: TextStyle(
                      fontSize: 14,
                      color: hasErrors
                          ? Colors.red.shade900
                          : Colors.orange.shade900,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(MenuEditState state) {
    final hasImage = state.item.hasImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Item Image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Optional',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: hasImage
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildImageDisplay(state),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => _pickImage(),
                            icon: const Icon(Icons.edit, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              context.read<MenuEditBloc>().add(
                                const RemoveImage(),
                              );
                            },
                            icon: const Icon(Icons.close, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : _buildImagePlaceholder(),
        ),
      ],
    );
  }

  Widget _buildImageDisplay(MenuEditState state) {
    if (state.item.imageFile != null) {
      // Display local file
      return Image.file(
        state.item.imageFile!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      );
    } else if (state.item.displayImagePath != null &&
        state.item.displayImagePath!.isNotEmpty) {
      // Display network image
      return Image.network(
        state.item.displayImagePath!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      );
    }

    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return InkWell(
      onTap: () => _pickImage(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Click to upload image',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'PNG, JPG up to 5MB',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _imagePicker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1920,
                    maxHeight: 1080,
                    imageQuality: 85,
                  );
                  if (image != null && mounted) {
                    context.read<MenuEditBloc>().add(
                      UpdateImageFile(File(image.path)),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _imagePicker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1920,
                    maxHeight: 1080,
                    imageQuality: 85,
                  );
                  if (image != null && mounted) {
                    context.read<MenuEditBloc>().add(
                      UpdateImageFile(File(image.path)),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Enter Image URL'),
                onTap: () {
                  Navigator.pop(context);
                  _showUrlDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUrlDialog() {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Enter Image URL'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              hintText: 'https://example.com/image.jpg',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (urlController.text.isNotEmpty) {
                  context.read<MenuEditBloc>().add(
                    UpdateImageUrl(urlController.text),
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategorySelector(MenuEditState state) {
    final selectedCategoryId = state.item.categoryId;
    final categories = state.categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: state.validation.errors.any((e) => e.contains('Category'))
                  ? Colors.red.shade300
                  : Colors.grey.shade300,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedCategoryId.isNotEmpty ? selectedCategoryId : null,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
              hintText: 'Select a category',
            ),
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category.id,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                context.read<MenuEditBloc>().add(UpdateItemCategory(value));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesSection(MenuEditState state) {
    final availableBadges = state.badges;
    final selectedBadges = state.item.badges;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Badges',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Optional',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Highlight special features of this item',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: availableBadges.map((badge) {
            final isSelected = selectedBadges.any((b) => b.id == badge.id);
            return _buildBadgeChip(badge, isSelected);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBadgeChip(BadgeEntity badge, bool isSelected) {
    final color = _parseHexColor(badge.color);

    return InkWell(
      onTap: () {
        context.read<MenuEditBloc>().add(ToggleBadge(badge));
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge.icon != null) ...[
              Text(badge.icon!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
            ],
            Text(
              badge.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : const Color(0xFF374151),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_circle, size: 16, color: color),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection(MenuEditState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pricing Configuration',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Configure how this item will be priced',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 16),

        // Has Sizes Toggle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Multiple Sizes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.item.hasSizes
                          ? 'This item has multiple size options'
                          : 'This item has a single fixed price',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: state.item.hasSizes,
                onChanged: (value) {
                  context.read<MenuEditBloc>().add(SetHasSizes(value));
                },
              ),
            ],
          ),
        ),

        // Base Price Field (only shown when hasSizes is false)
        if (!state.item.hasSizes) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Price (All Channels) *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Same price will apply for dine-in, takeaway, and delivery',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                TextField(
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: '\$ ',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            state.validation.errors.any(
                              (e) => e.contains('price'),
                            )
                            ? Colors.red.shade300
                            : Colors.grey.shade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            state.validation.errors.any(
                              (e) => e.contains('price'),
                            )
                            ? Colors.red.shade300
                            : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF2196F3),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  controller: TextEditingController(
                    text: state.item.basePrice > 0
                        ? state.item.basePrice.toStringAsFixed(2)
                        : '',
                  ),
                  onChanged: (value) {
                    final price = double.tryParse(value) ?? 0.0;
                    context.read<MenuEditBloc>().add(UpdateBasePrice(price));
                  },
                ),
              ],
            ),
          ),
        ],

        // Info message about step 2
        if (state.item.hasSizes) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Configure size-specific pricing in Step 2',
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Color _parseHexColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool required = false,
    String? hint,
    int maxLines = 1,
    bool error = false,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error ? Colors.red.shade300 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error ? Colors.red.shade300 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error ? Colors.red : Colors.blue,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
