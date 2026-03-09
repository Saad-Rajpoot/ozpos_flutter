import '../../../menu/domain/entities/menu_item_entity.dart';

/// Input for building a book-order cart item (avoids presentation dependency).
class BookOrderItemInput {
  final String id;
  final MenuItemEntity menuItem;
  final int quantity;
  final double unitPrice;
  final Map<String, List<String>> selectedModifiers;
  final String modifierSummary;
  /// Note for the kitchen (sent as special_instructions to backend).
  final String? specialInstructions;

  const BookOrderItemInput({
    required this.id,
    required this.menuItem,
    required this.quantity,
    required this.unitPrice,
    required this.selectedModifiers,
    this.modifierSummary = '',
    this.specialInstructions,
  });
}
