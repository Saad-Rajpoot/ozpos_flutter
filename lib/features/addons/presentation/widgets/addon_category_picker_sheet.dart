import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/addon_management_entities.dart';
import '../bloc/addon_management_bloc.dart';
import '../bloc/addon_management_event.dart';
import '../bloc/addon_management_state.dart';

/// Bottom sheet for selecting addon categories to attach to an item or size
class AddonCategoryPickerSheet extends StatefulWidget {
  final String itemId;
  final String? sizeId; // null for item-level
  final String? sizeLabel; // Display label for the size

  const AddonCategoryPickerSheet({
    super.key,
    required this.itemId,
    this.sizeId,
    this.sizeLabel,
  });

  @override
  State<AddonCategoryPickerSheet> createState() =>
      _AddonCategoryPickerSheetState();

  static Future<void> show({
    required BuildContext context,
    required String itemId,
    String? sizeId,
    String? sizeLabel,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<AddonManagementBloc>(),
        child: AddonCategoryPickerSheet(
          itemId: itemId,
          sizeId: sizeId,
          sizeLabel: sizeLabel,
        ),
      ),
    );
  }
}

class _AddonCategoryPickerSheetState extends State<AddonCategoryPickerSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(child: _buildCategoryList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Add-on Set',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (widget.sizeLabel != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'for ${widget.sizeLabel}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search add-on sets...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildCategoryList() {
    return BlocBuilder<AddonManagementBloc, AddonManagementState>(
      builder: (context, state) {
        if (state is! AddonManagementLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final summaries = state.getCategorySummaries(
          widget.itemId,
          widget.sizeId,
        );
        final filteredSummaries = _searchQuery.isEmpty
            ? summaries
            : summaries
                  .where((s) => s.name.toLowerCase().contains(_searchQuery))
                  .toList();

        if (filteredSummaries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'No add-on sets available'
                      : 'No matching add-on sets',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filteredSummaries.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final summary = filteredSummaries[index];
            final category = state.getCategoryById(summary.id);

            if (category == null) return const SizedBox.shrink();

            return _buildCategoryCard(context, category, summary.isAttached);
          },
        );
      },
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    AddonCategory category,
    bool isAttached,
  ) {
    return Card(
      elevation: isAttached ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isAttached
            ? BorderSide(color: Colors.blue.shade200, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isAttached ? null : () => _onCategorySelected(context, category),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isAttached
                      ? Colors.blue.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isAttached ? Icons.check_circle : Icons.category,
                  color: isAttached ? Colors.blue : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.fastfood,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${category.items.length} items',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isAttached)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Attached',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Icon(Icons.add_circle_outline, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  void _onCategorySelected(BuildContext context, AddonCategory category) {
    context.read<AddonManagementBloc>().add(
      AttachAddonCategoryEvent(
        itemId: widget.itemId,
        sizeId: widget.sizeId,
        categoryId: category.id,
        appliesToAllSizes: widget.sizeId == null,
      ),
    );

    Navigator.of(context).pop();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${category.name} added successfully'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
