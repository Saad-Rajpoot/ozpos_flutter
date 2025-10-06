import 'package:equatable/equatable.dart';
import '../../domain/entities/combo_entity.dart';
import '../../domain/entities/combo_slot_entity.dart';
import '../../domain/entities/combo_pricing_entity.dart';
import '../../domain/entities/combo_availability_entity.dart';
import '../../domain/entities/combo_limits_entity.dart';

abstract class ComboManagementEvent extends Equatable {
  const ComboManagementEvent();

  @override
  List<Object?> get props => [];
}

// Loading events
class LoadCombos extends ComboManagementEvent {
  const LoadCombos();
}

class RefreshCombos extends ComboManagementEvent {
  const RefreshCombos();
}

// Combo CRUD events
class CreateCombo extends ComboManagementEvent {
  final ComboEntity combo;

  const CreateCombo({required this.combo});

  @override
  List<Object?> get props => [combo];
}

class UpdateCombo extends ComboManagementEvent {
  final ComboEntity combo;

  const UpdateCombo({required this.combo});

  @override
  List<Object?> get props => [combo];
}

class DeleteCombo extends ComboManagementEvent {
  final String comboId;

  const DeleteCombo({required this.comboId});

  @override
  List<Object?> get props => [comboId];
}

class DuplicateCombo extends ComboManagementEvent {
  final String comboId;
  final String? newName;

  const DuplicateCombo({required this.comboId, this.newName});

  @override
  List<Object?> get props => [comboId, newName];
}

class ToggleComboVisibility extends ComboManagementEvent {
  final String comboId;
  final ComboStatus newStatus;

  const ToggleComboVisibility({
    required this.comboId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [comboId, newStatus];
}

// Combo builder events
class StartComboEdit extends ComboManagementEvent {
  final String? comboId; // null for new combo

  const StartComboEdit({this.comboId});

  @override
  List<Object?> get props => [comboId];
}

class CancelComboEdit extends ComboManagementEvent {
  const CancelComboEdit();
}

class SaveComboChanges extends ComboManagementEvent {
  final bool exitAfterSave;

  const SaveComboChanges({this.exitAfterSave = false});

  @override
  List<Object?> get props => [exitAfterSave];
}

class SelectTab extends ComboManagementEvent {
  final String tabId;

  const SelectTab({required this.tabId});

  @override
  List<Object?> get props => [tabId];
}

// Basic details events
class UpdateComboName extends ComboManagementEvent {
  final String name;

  const UpdateComboName({required this.name});

  @override
  List<Object?> get props => [name];
}

class UpdateComboDescription extends ComboManagementEvent {
  final String description;

  const UpdateComboDescription({required this.description});

  @override
  List<Object?> get props => [description];
}

class UpdateComboImage extends ComboManagementEvent {
  final String? imageUrl;

  const UpdateComboImage({this.imageUrl});

  @override
  List<Object?> get props => [imageUrl];
}

class UpdateComboCategory extends ComboManagementEvent {
  final String? categoryTag;

  const UpdateComboCategory({this.categoryTag});

  @override
  List<Object?> get props => [categoryTag];
}

class UpdateComboPointsReward extends ComboManagementEvent {
  final int? pointsReward;

  const UpdateComboPointsReward({this.pointsReward});

  @override
  List<Object?> get props => [pointsReward];
}

// Slot management events
class AddComboSlot extends ComboManagementEvent {
  final ComboSlotEntity slot;

  const AddComboSlot({required this.slot});

  @override
  List<Object?> get props => [slot];
}

class UpdateComboSlot extends ComboManagementEvent {
  final String slotId;
  final ComboSlotEntity updatedSlot;

  const UpdateComboSlot({
    required this.slotId,
    required this.updatedSlot,
  });

  @override
  List<Object?> get props => [slotId, updatedSlot];
}

class RemoveComboSlot extends ComboManagementEvent {
  final String slotId;

  const RemoveComboSlot({required this.slotId});

  @override
  List<Object?> get props => [slotId];
}

class ReorderComboSlots extends ComboManagementEvent {
  final List<String> slotIds; // New order

  const ReorderComboSlots({required this.slotIds});

  @override
  List<Object?> get props => [slotIds];
}

class DuplicateComboSlot extends ComboManagementEvent {
  final String slotId;

  const DuplicateComboSlot({required this.slotId});

  @override
  List<Object?> get props => [slotId];
}

// Pricing events
class UpdateComboPricing extends ComboManagementEvent {
  final ComboPricingEntity pricing;

  const UpdateComboPricing({required this.pricing});

  @override
  List<Object?> get props => [pricing];
}

class RecalculatePricing extends ComboManagementEvent {
  const RecalculatePricing();
}

// Availability events
class UpdateComboAvailability extends ComboManagementEvent {
  final ComboAvailabilityEntity availability;

  const UpdateComboAvailability({required this.availability});

  @override
  List<Object?> get props => [availability];
}

// Limits events
class UpdateComboLimits extends ComboManagementEvent {
  final ComboLimitsEntity limits;

  const UpdateComboLimits({required this.limits});

  @override
  List<Object?> get props => [limits];
}

// Validation events
class ValidateCurrentCombo extends ComboManagementEvent {
  const ValidateCurrentCombo();
}

class MarkAsUnsaved extends ComboManagementEvent {
  const MarkAsUnsaved();
}

// Batch operations
class SaveAllCombos extends ComboManagementEvent {
  const SaveAllCombos();
}

class DiscardAllUnsavedChanges extends ComboManagementEvent {
  const DiscardAllUnsavedChanges();
}

// Search and filter events
class SearchCombos extends ComboManagementEvent {
  final String query;

  const SearchCombos({required this.query});

  @override
  List<Object?> get props => [query];
}

class FilterCombosByStatus extends ComboManagementEvent {
  final ComboStatus? status; // null for all

  const FilterCombosByStatus({this.status});

  @override
  List<Object?> get props => [status];
}

class FilterCombosByCategory extends ComboManagementEvent {
  final String? categoryTag; // null for all

  const FilterCombosByCategory({this.categoryTag});

  @override
  List<Object?> get props => [categoryTag];
}

class ClearFilters extends ComboManagementEvent {
  const ClearFilters();
}