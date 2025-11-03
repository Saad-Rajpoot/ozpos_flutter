/// Application constants
class AppConstants {
  // API Endpoints
  static const String baseUrl = 'https://api.ozpos.com';

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshEndpoint = '/auth/refresh';

  // Addon endpoints
  static const String getAddonCategoriesEndpoint = '/addons/categories';

  // Menu endpoints
  static const String getMenuItemsEndpoint = '/menu/items';
  static const String getMenuCategoriesEndpoint = '/menu/categories';
  static const String getModifierGroupsEndpoint = '/menu/modifier-groups';

  // Order endpoints
  static const String createOrderEndpoint = '/orders';
  static const String getOrdersEndpoint = '/orders';
  static const String updateOrderEndpoint = '/orders/{id}';
  static const String payOrderEndpoint = '/orders/{id}/pay';

  // Table endpoints
  static const String getTablesEndpoint = '/tables';
  static const String getMoveTablesEndpoint = '/tables/move/available';
  static const String updateTableEndpoint = '/tables/{id}';
  static const String moveTableEndpoint = '/tables/move';
  static const String mergeTableEndpoint = '/tables/merge';

  // Combo endpoints
  static const String getCombosEndpoint = '/combos';
  static const String getComboSlotsEndpoint = '/combos/slots';
  static const String getComboAvailabilityEndpoint = '/combos/availability';
  static const String getComboLimitsEndpoint = '/combos/limits';
  static const String getComboOptionsEndpoint = '/combos/options';
  static const String getComboPricingEndpoint = '/combos/pricing';
  static const String createComboEndpoint = '/combos';
  static const String updateComboEndpoint = '/combos';
  static const String deleteComboEndpoint = '/combos';
  static const String duplicateComboEndpoint = '/combos/duplicate';

  // Reservation endpoints
  static const String getReservationsEndpoint = '/reservations';
  static const String createReservationEndpoint = '/reservations';
  static const String updateReservationEndpoint = '/reservations/{id}';

  // Delivery endpoints
  static const String getDeliveryJobsEndpoint = '/delivery/jobs';
  static const String getDriversEndpoint = '/delivery/drivers';
  static const String updateDriverLocationEndpoint =
      '/delivery/drivers/{id}/location';

  // Loyalty endpoints
  static const String getLoyaltyAccountEndpoint = '/loyalty/account';
  static const String redeemPointsEndpoint = '/loyalty/redeem';
  static const String earnPointsEndpoint = '/loyalty/earn';

  // Printer endpoints
  static const String getPrintersEndpoint = '/printers';
  static const String testPrintEndpoint = '/printers/{id}/test';
  static const String discoverBluetoothPrintersEndpoint =
      '/printers/discover/bluetooth';
  static const String discoverNetworkPrintersEndpoint =
      '/printers/discover/network';
  static const String addPrinterEndpoint = '/printers';
  static const String updatePrinterEndpoint = '/printers/{id}';
  static const String deletePrinterEndpoint = '/printers/{id}';
  static const String connectPrinterEndpoint = '/printers/{id}/connect';
  static const String disconnectPrinterEndpoint = '/printers/{id}/disconnect';
  static const String setDefaultPrinterEndpoint = '/printers/{id}/set-default';
  static const String printJobHistoryEndpoint = '/printers/jobs';
  static const String printJobStatusEndpoint = '/printers/jobs/{jobId}';

  // Reports endpoints
  static const String getReportsEndpoint = '/reports';
  static const String exportReportsEndpoint = '/reports/export';

  // Settings endpoints
  static const String getSettingsEndpoint = '/settings';
  static const String updateSettingsEndpoint = '/settings';

  // Customer display endpoints
  static const String customerDisplayEndpoint = '/customer-display';

  // Storage keys
  static const String tokenKey = 'token';
  static const String userKey = 'user';
  static const String settingsKey = 'settings';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Retry
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // Cache
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 100;

  // UI Constants
  static const double imageHeightRatio = 0.6; // Menu item card image ratio
  static const double popularBadgeSize = 16.0;
  static const double priceBadgeSize = 13.0;
  static const double letterSpacingSmall = 0.5;

  // Responsive breakpoints
  static const double desktopBreakpoint = 1024.0;
  static const double tabletBreakpoint = 768.0;
  static const double mobileBreakpoint = 600.0;

  // Grid configurations
  static const int gridColumnsUltraWide = 5;
  static const int gridColumnsDesktop = 4;
  static const int gridColumnsTablet = 3;
  static const int gridColumnsMobile = 2;

  // Spacing ratios
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 20.0;
  static const double spacingExtraLarge = 24.0;

  // Border radius
  static const double borderRadiusSmall = 6.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusExtraLarge = 16.0;

  // Opacity values
  static const double opacityFull = 1.0;
  static const double opacityHigh = 0.95;
  static const double opacityMedium = 0.5;
  static const double opacityLow = 0.1;
  static const double opacityVeryLow = 0.05;
}
