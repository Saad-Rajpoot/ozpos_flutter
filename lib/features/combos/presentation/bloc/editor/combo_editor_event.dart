import '../../../../../core/base/base_bloc.dart';
import '../../../domain/entities/combo_availability_entity.dart';
import '../../../domain/entities/combo_entity.dart';
import '../../../domain/entities/combo_limits_entity.dart';
import '../../../domain/entities/combo_pricing_entity.dart';
import '../../../domain/entities/combo_slot_entity.dart';

abstract class ComboEditorEvent extends BaseEvent {
  const ComboEditorEvent();
}

class ComboEditingStarted extends ComboEditorEvent {
  final String? comboId;

  const ComboEditingStarted({this.comboId});

  @override
  List<Object?> get props => [comboId];
}

class ComboEditingCancelled extends ComboEditorEvent {
  const ComboEditingCancelled();
}

class ComboSaveRequested extends ComboEditorEvent {
  final bool exitAfterSave;

  const ComboSaveRequested({this.exitAfterSave = false});

  @override
  List<Object?> get props => [exitAfterSave];
}

class ComboTabSelected extends ComboEditorEvent {
  final String tabId;

  const ComboTabSelected({required this.tabId});

  @override
  List<Object?> get props => [tabId];
}

class ComboNameChanged extends ComboEditorEvent {
  final String name;

  const ComboNameChanged({required this.name});

  @override
  List<Object?> get props => [name];
}

class ComboDescriptionChanged extends ComboEditorEvent {
  final String description;

  const ComboDescriptionChanged({required this.description});

  @override
  List<Object?> get props => [description];
}

class ComboImageChanged extends ComboEditorEvent {
  final String? imageUrl;

  const ComboImageChanged({this.imageUrl});

  @override
  List<Object?> get props => [imageUrl];
}

class ComboCategoryChanged extends ComboEditorEvent {
  final String? categoryTag;

  const ComboCategoryChanged({this.categoryTag});

  @override
  List<Object?> get props => [categoryTag];
}

class ComboPointsRewardChanged extends ComboEditorEvent {
  final int? pointsReward;

  const ComboPointsRewardChanged({this.pointsReward});

  @override
  List<Object?> get props => [pointsReward];
}

class ComboSlotAdded extends ComboEditorEvent {
  final ComboSlotEntity slot;

  const ComboSlotAdded({required this.slot});

  @override
  List<Object?> get props => [slot];
}

class ComboSlotUpdated extends ComboEditorEvent {
  final String slotId;
  final ComboSlotEntity updatedSlot;

  const ComboSlotUpdated({
    required this.slotId,
    required this.updatedSlot,
  });

  @override
  List<Object?> get props => [slotId, updatedSlot];
}

class ComboSlotRemoved extends ComboEditorEvent {
  final String slotId;

  const ComboSlotRemoved({required this.slotId});

  @override
  List<Object?> get props => [slotId];
}

class ComboSlotsReordered extends ComboEditorEvent {
  final List<String> slotIds;

  const ComboSlotsReordered({required this.slotIds});

  @override
  List<Object?> get props => [slotIds];
}

class ComboSlotDuplicated extends ComboEditorEvent {
  final String slotId;

  const ComboSlotDuplicated({required this.slotId});

  @override
  List<Object?> get props => [slotId];
}

class ComboPricingChanged extends ComboEditorEvent {
  final ComboPricingEntity pricing;

  const ComboPricingChanged({required this.pricing});

  @override
  List<Object?> get props => [pricing];
}

class ComboPricingRecalculated extends ComboEditorEvent {
  const ComboPricingRecalculated();
}

class ComboAvailabilityChanged extends ComboEditorEvent {
  final ComboAvailabilityEntity availability;

  const ComboAvailabilityChanged({required this.availability});

  @override
  List<Object?> get props => [availability];
}

class ComboLimitsChanged extends ComboEditorEvent {
  final ComboLimitsEntity limits;

  const ComboLimitsChanged({required this.limits});

  @override
  List<Object?> get props => [limits];
}

class ComboValidationRequested extends ComboEditorEvent {
  const ComboValidationRequested();
}

class ComboUnsavedMarked extends ComboEditorEvent {
  const ComboUnsavedMarked();
}

class ComboUnsavedResetRequested extends ComboEditorEvent {
  const ComboUnsavedResetRequested();
}

class ComboEditorCombosSynced extends ComboEditorEvent {
  final List<ComboEntity> combos;
  final ComboEntity? lastSavedCombo;
  final String? saveError;

  const ComboEditorCombosSynced({
    required this.combos,
    this.lastSavedCombo,
    this.saveError,
  });

  @override
  List<Object?> get props => [combos, lastSavedCombo, saveError];
}


