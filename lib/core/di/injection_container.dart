import 'package:get_it/get_it.dart';

import 'modules/core_module.dart';
import 'modules/menu_module.dart';
import 'modules/cart_module.dart';
import 'modules/checkout_module.dart';
import 'modules/combo_module.dart';
import 'modules/addon_module.dart';
import 'modules/table_module.dart';
import 'modules/reservation_module.dart';
import 'modules/report_module.dart';
import 'modules/order_module.dart';
import 'modules/delivery_module.dart';
import 'modules/printing_module.dart';
import 'modules/settings_module.dart';
import 'modules/customer_display_module.dart';

final sl = GetIt.instance;

/// Initialize dependency injection
/// This is the main entry point for DI setup
/// All feature modules are initialized here
Future<void> init() async {
  // Initialize core dependencies first (database, network, API client, etc.)
  await CoreModule.init(sl);

  // Initialize feature modules
  await MenuModule.init(sl);
  await CartModule.init(sl);
  await CheckoutModule.init(sl);
  await ComboModule.init(sl);
  await AddonModule.init(sl);
  await TableModule.init(sl);
  await ReservationModule.init(sl);
  await ReportModule.init(sl);
  await OrderModule.init(sl);
  await DeliveryModule.init(sl);
  await PrintingModule.init(sl);
  await SettingsModule.init(sl);
  await CustomerDisplayModule.init(sl);
}
