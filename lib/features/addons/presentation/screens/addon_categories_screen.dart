import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/addon_management_bloc.dart';
import '../bloc/addon_management_event.dart';
import '../bloc/addon_management_state.dart';
import '../../domain/entities/addon_management_entities.dart';

/// Standalone screen for managing add-on categories system-wide
/// Accessible from Menu Editor screen for creating/editing reusable addon sets
///
/// Note: This screen is wrapped with BlocProvider in AppRouter
class AddonCategoriesScreen extends StatelessWidget {
  const AddonCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Add-on Categories',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: BlocBuilder<AddonManagementBloc, AddonManagementState>(
              builder: (context, state) {
                if (state is AddonManagementLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AddonManagementError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.message}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<AddonManagementBloc>().add(
                              const LoadAddonCategoriesEvent(),
                            );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is AddonManagementLoaded) {
                  if (state.categories.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return _buildCategoryList(context, state);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.category,
                  color: Colors.blue.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manage Add-on Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create reusable add-on sets that can be attached to menu items',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<AddonManagementBloc, AddonManagementState>(
            builder: (context, state) {
              if (state is AddonManagementLoaded) {
                final totalCategories = state.categories.length;
                final totalItems = state.categories.fold<int>(
                  0,
                  (sum, cat) => sum + cat.items.length,
                );

                return Row(
                  children: [
                    _buildStatCard(
                      'Categories',
                      totalCategories.toString(),
                      Icons.folder,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Total Items',
                      totalItems.toString(),
                      Icons.fastfood,
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Add-on Categories Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first add-on category to start organizing menu customizations',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, AddonManagementLoaded state) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: state.categories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final category = state.categories[index];
        return _buildCategoryCard(context, category);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, AddonCategory category) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade100, width: 1),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.all(20),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade600],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.category, color: Colors.white, size: 24),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            category.description,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                '${category.items.length} items',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        children: [const Divider(height: 24)],
      ),
    );
  }
}
