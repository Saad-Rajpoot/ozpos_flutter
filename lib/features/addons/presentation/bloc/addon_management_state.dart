import 'package:equatable/equatable.dart';
import '../../domain/entities/addon_management_entities.dart';

abstract class AddonManagementState extends Equatable {
  const AddonManagementState();

  @override
  List<Object?> get props => [];
}

class AddonManagementInitial extends AddonManagementState {
  const AddonManagementInitial();
}

class AddonManagementLoading extends AddonManagementState {
  const AddonManagementLoading();
}

class AddonManagementLoaded extends AddonManagementState {
  final List<AddonCategory> categories;

  const AddonManagementLoaded({required this.categories});

  AddonManagementLoaded copyWith({List<AddonCategory>? categories}) {
    return AddonManagementLoaded(categories: categories ?? this.categories);
  }

  @override
  List<Object?> get props => [categories];
}

class AddonManagementError extends AddonManagementState {
  final String message;

  const AddonManagementError(this.message);

  @override
  List<Object?> get props => [message];
}
