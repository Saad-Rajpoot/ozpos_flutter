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

  // Docket endpoints
  static const String getDocketsEndpoint = '/dockets';

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

  // Reports endpoints
  static const String getReportsEndpoint = '/reports';
  static const String exportReportsEndpoint = '/reports/export';

  // Settings endpoints
  static const String getSettingsEndpoint = '/settings';
  static const String updateSettingsEndpoint = '/settings';

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
}
