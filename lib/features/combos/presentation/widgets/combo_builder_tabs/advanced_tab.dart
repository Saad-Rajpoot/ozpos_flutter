import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/combo_management_bloc.dart';
import '../../bloc/combo_management_event.dart';
import '../../bloc/combo_management_state.dart';
import '../../../domain/entities/combo_entity.dart';

class AdvancedTab extends StatefulWidget {
  const AdvancedTab({super.key});

  @override
  State<AdvancedTab> createState() => _AdvancedTabState();
}

class _AdvancedTabState extends State<AdvancedTab> {
  // State variables for advanced settings
  bool _isFeatured = false;
  bool _canStackWithDiscounts = true;
  bool _isExclusivePromo = false;
  bool _requireMembership = true;

  @override
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComboManagementBloc, ComboManagementState>(
      builder: (context, state) {
        final combo = state.editingCombo;
        if (combo == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Advanced Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Configure limits, stacking rules, and visibility controls',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 32),

              // Deal Status & Visibility
              _buildVisibilitySection(combo),
              const SizedBox(height: 32),

              // Customer Limits
              _buildCustomerLimitsSection(combo),
              const SizedBox(height: 32),

              // Stacking Rules
              _buildStackingRulesSection(combo),
              const SizedBox(height: 32),

              // Priority & Ordering
              _buildPrioritySection(combo),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVisibilitySection(ComboEntity combo) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deal Status & Visibility',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Control how this combo appears to customers and staff',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<ComboStatus>(
                      value: combo.status,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: ComboStatus.active,
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Color(0xFF10B981),
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text('Active - Visible to customers'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: ComboStatus.hidden,
                          child: Row(
                            children: [
                              Icon(
                                Icons.visibility_off,
                                color: Color(0xFFF59E0B),
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text('Hidden - Staff only'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: ComboStatus.draft,
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                color: Color(0xFF6B7280),
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text('Draft - Not available'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) => _updateComboStatus(value!),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Priority/Featured toggle
          Row(
            children: [
              Checkbox(
                value: _isFeatured,
                onChanged: (value) => _updateFeaturedStatus(value ?? false),
                activeColor: const Color(0xFF8B5CF6),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Featured Deal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    Text(
                      'Highlight this combo in menus and promotions',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerLimitsSection(ComboEntity combo) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Limits',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set limits on how customers can order this combo',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Max per Order',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'e.g. 3',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          _updateMaxPerOrder(int.tryParse(value)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Max per Day (per customer)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'e.g. 1',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          _updateMaxPerDay(int.tryParse(value)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Global daily limit
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Daily Limit (all customers)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '50',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          _updateDailyLimit(int.tryParse(value)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Leave empty for unlimited. Useful for limited-time offers.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStackingRulesSection(ComboEntity combo) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stacking & Discount Rules',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Control how this combo interacts with other promotions',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 20),

          Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _canStackWithDiscounts,
                    onChanged: (value) =>
                        _updateStackWithDiscounts(value ?? false),
                    activeColor: const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Can stack with other discounts',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        Text(
                          'Allow additional coupons or loyalty discounts',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isExclusivePromo,
                    onChanged: (value) => _updateExclusivePromo(value ?? false),
                    activeColor: const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exclusive promotion',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        Text(
                          'Prevent other combos in the same order',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _requireMembership,
                    onChanged: (value) =>
                        _updateRequireMembership(value ?? false),
                    activeColor: const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Require loyalty membership',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        Text(
                          'Only available to registered loyalty members',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySection(ComboEntity combo) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Display Priority & Ordering',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Control where this combo appears in menus and lists',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Display Priority',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: 'Medium',
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Low',
                          child: Text('Low - Bottom of list'),
                        ),
                        DropdownMenuItem(
                          value: 'Medium',
                          child: Text('Medium - Standard order'),
                        ),
                        DropdownMenuItem(
                          value: 'High',
                          child: Text('High - Top of list'),
                        ),
                        DropdownMenuItem(
                          value: 'Urgent',
                          child: Text('Urgent - Featured prominently'),
                        ),
                      ],
                      onChanged: (value) => _updatePriority(value!),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sort Order',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: '0 (auto)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          _updateSortOrder(int.tryParse(value) ?? 0),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF6B7280), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Higher priority combos appear first in menus. Sort order provides fine-grained control within priority levels.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Event handlers
  void _updateComboStatus(ComboStatus status) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Status updated to ${status.name}')));
  }

  void _updateFeaturedStatus(bool featured) {
    setState(() {
      _isFeatured = featured;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Featured: ${featured ? 'Enabled' : 'Disabled'}')),
    );
  }

  void _updateMaxPerOrder(int? max) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Max per order: ${max ?? 'unlimited'}')),
    );
  }

  void _updateMaxPerDay(int? max) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Max per day: ${max ?? 'unlimited'}')),
    );
  }

  void _updateDailyLimit(int? limit) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Daily limit: ${limit ?? 'unlimited'}')),
    );
  }

  void _updateStackWithDiscounts(bool canStack) {
    setState(() {
      _canStackWithDiscounts = canStack;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Stack with discounts: ${canStack ? 'Allowed' : 'Not allowed'}',
        ),
      ),
    );
  }

  void _updateExclusivePromo(bool exclusive) {
    setState(() {
      _isExclusivePromo = exclusive;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Exclusive promotion: ${exclusive ? 'Enabled' : 'Disabled'}',
        ),
      ),
    );
  }

  void _updateRequireMembership(bool required) {
    setState(() {
      _requireMembership = required;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Loyalty membership: ${required ? 'Required' : 'Not required'}',
        ),
      ),
    );
  }

  void _updatePriority(String priority) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Priority set to $priority')));
  }

  void _updateSortOrder(int order) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Sort order: $order')));
  }
}
