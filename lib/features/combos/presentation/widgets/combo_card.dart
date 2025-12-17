import 'package:flutter/material.dart';
import '../../domain/entities/combo_entity.dart';

class ComboCard extends StatelessWidget {
  final ComboEntity combo;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onToggleVisibility;
  final VoidCallback onDelete;
  final VoidCallback onAddToCart;

  const ComboCard({
    super.key,
    required this.combo,
    required this.onEdit,
    required this.onDuplicate,
    required this.onToggleVisibility,
    required this.onDelete,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(context),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        // Background gradient or color
        Container(
          height: 8,
          decoration: BoxDecoration(
            gradient: _getHeaderGradient(),
          ),
        ),
        // Corner ribbons
        if (combo.ribbons.isNotEmpty) ..._buildRibbons(),
      ],
    );
  }

  List<Widget> _buildRibbons() {
    final ribbons = combo.ribbons.take(2).toList(); // Max 2 ribbons
    return ribbons.asMap().entries.map((entry) {
      final index = entry.key;
      final ribbon = entry.value;
      return _buildRibbon(ribbon, isRight: index == 1);
    }).toList();
  }

  Widget _buildRibbon(String text, {bool isRight = false}) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (text.toLowerCase()) {
      case 'limited time':
        backgroundColor = const Color(0xFFEF4444); // Red
        break;
      case 'popular':
        backgroundColor = const Color(0xFF3B82F6); // Blue
        break;
      case 'best value':
        backgroundColor = const Color(0xFFF59E0B); // Amber/Orange
        break;
      case 'weekend special':
        backgroundColor = const Color(0xFF10B981); // Green
        break;
      case 'spicy':
        backgroundColor = const Color(0xFFDC2626); // Dark red
        break;
      default:
        backgroundColor = const Color(0xFF6B7280); // Gray
        break;
    }

    return Positioned(
      top: 12,
      right: isRight ? 12 : null,
      left: isRight ? null : 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textColor,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      combo.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${combo.finalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
              ),
              // Savings badge
              if (combo.savingsText != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    combo.savingsText!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            combo.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),

          // Component summary with checkmarks
          if (combo.componentSummary.isNotEmpty) ...[
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: combo.componentSummary.map((component) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        component,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          const Spacer(),

          // Eligibility pill
          if (combo.eligibilityText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6B7280).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    combo.eligibilityText!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          // Add to Cart button
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: onAddToCart,
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Points indicator
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.star,
                    size: 18,
                    color: Colors.orange[600],
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Text(
                    '+${combo.pointsReward ?? 150} pts',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Quick action buttons
          SizedBox(
            height: 44,
            width: 44,
            child: IconButton(
              onPressed: onEdit,
              icon: Icon(
                Icons.edit_outlined,
                color: Colors.grey[600],
                size: 18,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              tooltip: 'Edit Combo',
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            height: 44,
            width: 44,
            child: IconButton(
              onPressed: onDuplicate,
              icon: Icon(
                Icons.copy_outlined,
                color: Colors.grey[600],
                size: 18,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              tooltip: 'Duplicate Combo',
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            height: 44,
            width: 44,
            child: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                combo.status == ComboStatus.active
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: combo.status == ComboStatus.active
                    ? Colors.green[600]
                    : Colors.grey[600],
                size: 18,
              ),
              style: IconButton.styleFrom(
                backgroundColor: combo.status == ComboStatus.active
                    ? Colors.green[50]
                    : Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              tooltip: combo.status == ComboStatus.active
                  ? 'Hide Combo'
                  : 'Show Combo',
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            height: 44,
            width: 44,
            child: IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red[400],
                size: 18,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.red[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              tooltip: 'Delete Combo',
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getHeaderGradient() {
    // Different gradients based on combo type or category
    if (combo.ribbons.contains('Limited Time')) {
      return const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else if (combo.ribbons.contains('Popular')) {
      return const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else if (combo.ribbons.contains('Best Value')) {
      return const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }
  }
}
