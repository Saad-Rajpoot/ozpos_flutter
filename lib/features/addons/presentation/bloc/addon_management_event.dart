import '../../../../core/base/base_bloc.dart';

abstract class AddonManagementEvent extends BaseEvent {
  const AddonManagementEvent();
}

/// Load all addon categories from JSON file
class LoadAddonCategoriesEvent extends AddonManagementEvent {
  const LoadAddonCategoriesEvent();
}
