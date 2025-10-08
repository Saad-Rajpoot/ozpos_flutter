import 'package:equatable/equatable.dart';

abstract class AddonManagementEvent extends Equatable {
  const AddonManagementEvent();

  @override
  List<Object?> get props => [];
}

/// Load all addon categories from JSON file
class LoadAddonCategoriesEvent extends AddonManagementEvent {
  const LoadAddonCategoriesEvent();
}
