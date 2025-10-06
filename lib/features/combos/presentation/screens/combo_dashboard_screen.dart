import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/combo_management_bloc.dart';
import '../bloc/combo_management_event.dart';
import '../bloc/combo_management_state.dart';
import '../../domain/entities/combo_entity.dart';
import '../widgets/combo_card.dart';
import '../widgets/combo_builder_modal.dart';
import '../../../../core/theme/app_theme.dart';

class ComboDashboardScreen extends StatefulWidget {
  const ComboDashboardScreen({super.key});

  @override
  State<ComboDashboardScreen> createState() => _ComboDashboardScreenState();
}

class _ComboDashboardScreenState extends State<ComboDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<ComboManagementBloc>().add(
      SearchCombos(query: _searchController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocConsumer<ComboManagementBloc, ComboManagementState>(
        listener: (context, state) {
          if (state.saveError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.saveError!),
                backgroundColor: Colors.red[600],
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildTopBar(context, state),
              _buildComboSection(context, state),
              Expanded(child: _buildComboGrid(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, ComboManagementState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        children: [
          // Title and unsaved changes indicator
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Menu Dashboard',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (state.hasUnsavedChanges) ...[
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Unsaved changes • ${state.unsavedChangesCount}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                // Search bar
                SizedBox(
                  width: 400,
                  height: 44,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search items, categories',
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 20,
                        color: Color(0xFF6B7280),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          const SizedBox(width: 16),
          _buildActionButton(
            icon: Icons.auto_awesome,
            label: 'New Meal Combo',
            onPressed: () => _showComboBuilder(context),
            isPrimary: true,
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            icon: Icons.add,
            label: 'Add New Item',
            onPressed: () {
              // TODO: Navigate to menu item wizard
            },
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            icon: Icons.save,
            label: 'Save All',
            onPressed: state.hasUnsavedChanges
                ? () => context.read<ComboManagementBloc>().add(
                    const SaveAllCombos(),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isPrimary = false,
  }) {
    return SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF8B5CF6) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : const Color(0xFF374151),
          elevation: 0,
          side: isPrimary ? null : const BorderSide(color: Color(0xFFD1D5DB)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildComboSection(BuildContext context, ComboManagementState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        children: [
          // Star icon and title
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.star, color: Color(0xFF8B5CF6), size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Meal Combos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${state.filteredCombos.length} combos',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '📈 Boost Sales',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF10B981),
              ),
            ),
          ),
          const Spacer(),
          // Create Combo button
          SizedBox(
            height: 36,
            child: ElevatedButton.icon(
              onPressed: () => _showComboBuilder(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text(
                'Create Combo',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComboGrid(BuildContext context, ComboManagementState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
      );
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading combos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.currentErrorMessage ?? 'Something went wrong',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<ComboManagementBloc>().add(
                const RefreshCombos(),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (state.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 1.1, // Slightly taller cards
        ),
        itemCount: state.filteredCombos.length,
        itemBuilder: (context, index) {
          final combo = state.filteredCombos[index];
          return ComboCard(
            combo: combo,
            onEdit: () => _editCombo(context, combo.id),
            onDuplicate: () => _duplicateCombo(context, combo.id),
            onToggleVisibility: () => _toggleComboVisibility(context, combo),
            onDelete: () => _deleteCombo(context, combo.id),
            onAddToCart: () => _addComboToCart(context, combo),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_menu,
              size: 48,
              color: Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No combos found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first meal combo to boost sales',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showComboBuilder(context),
            icon: const Icon(Icons.add),
            label: const Text('Create First Combo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1600) return 4;
    if (width > 1200) return 3;
    if (width > 800) return 2;
    return 1;
  }

  void _showComboBuilder(BuildContext context) {
    context.read<ComboManagementBloc>().add(const StartComboEdit());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ComboBuilderModal(),
    );
  }

  void _editCombo(BuildContext context, String comboId) {
    context.read<ComboManagementBloc>().add(StartComboEdit(comboId: comboId));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ComboBuilderModal(),
    );
  }

  void _duplicateCombo(BuildContext context, String comboId) {
    context.read<ComboManagementBloc>().add(DuplicateCombo(comboId: comboId));
  }

  void _toggleComboVisibility(BuildContext context, ComboEntity combo) {
    final newStatus = combo.status == ComboStatus.active
        ? ComboStatus.hidden
        : ComboStatus.active;

    context.read<ComboManagementBloc>().add(
      ToggleComboVisibility(comboId: combo.id, newStatus: newStatus),
    );
  }

  void _deleteCombo(BuildContext context, String comboId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Combo'),
        content: const Text(
          'Are you sure you want to delete this combo? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ComboManagementBloc>().add(
                DeleteCombo(comboId: comboId),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addComboToCart(BuildContext context, ComboEntity combo) {
    // TODO: Implement POS guided selector
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${combo.name}" to cart'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }
}
