import 'package:get_it/get_it.dart';

import '../../../features/checkout/presentation/bloc/cart_bloc.dart';

/// Cart feature module for dependency injection
/// Cart is a singleton because it persists across the entire app lifecycle
class CartModule {
  /// Initialize cart feature dependencies
  static Future<void> init(GetIt sl) async {
    // BLoC (Singleton - cart persists across entire app lifecycle)
    // This is appropriate for a POS system where the cart should persist
    // across navigation and be accessible from anywhere in the app
    sl.registerLazySingleton(
      () => CartBloc()..add(const InitializeCart()),
    );
  }
}

