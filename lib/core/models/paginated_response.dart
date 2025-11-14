/// Paginated response wrapper
///
/// Generic class to wrap paginated API responses
class PaginatedResponse<T> {
  /// List of items in current page
  final List<T> data;

  /// Current page number
  final int currentPage;

  /// Total number of pages
  final int totalPages;

  /// Total number of items across all pages
  final int totalItems;

  /// Number of items per page
  final int perPage;

  /// Whether there is a next page
  bool get hasNextPage => currentPage < totalPages;

  /// Whether there is a previous page
  bool get hasPreviousPage => currentPage > 1;

  /// Whether this is the first page
  bool get isFirstPage => currentPage == 1;

  /// Whether this is the last page
  bool get isLastPage => currentPage == totalPages;

  const PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.perPage,
  });

  /// Create from JSON response
  ///
  /// [json] - The JSON response from API
  /// [fromJson] - Function to convert JSON item to T
  /// [dataKey] - Key containing the data array (default: 'data')
  /// [pageKey] - Key containing current page (default: 'current_page')
  /// [totalPagesKey] - Key containing total pages (default: 'last_page' or 'total_pages')
  /// [totalItemsKey] - Key containing total items (default: 'total')
  /// [perPageKey] - Key containing items per page (default: 'per_page')
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson, {
    String dataKey = 'data',
    String pageKey = 'current_page',
    String totalPagesKey = 'last_page',
    String totalItemsKey = 'total',
    String perPageKey = 'per_page',
  }) {
    // Extract data array
    final dataJson = json[dataKey] as List<dynamic>? ?? [];
    final data =
        dataJson.map((item) => fromJson(item as Map<String, dynamic>)).toList();

    // Extract pagination metadata
    final currentPage = json[pageKey] as int? ?? 1;

    // Try multiple keys for total pages (different APIs use different keys)
    final totalPages = json[totalPagesKey] as int? ??
        json['total_pages'] as int? ??
        json['lastPage'] as int? ??
        1;

    final totalItems = json[totalItemsKey] as int? ??
        json['totalItems'] as int? ??
        json['total_count'] as int? ??
        data.length;

    final perPage = json[perPageKey] as int? ??
        json['perPage'] as int? ??
        json['limit'] as int? ??
        data.length;

    return PaginatedResponse<T>(
      data: data,
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      perPage: perPage,
    );
  }

  /// Create empty paginated response
  static PaginatedResponse<T> empty<T>() {
    return PaginatedResponse<T>(
      data: const [],
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
      perPage: 0,
    );
  }

  /// Combine two paginated responses (for appending next page)
  PaginatedResponse<T> combine(PaginatedResponse<T> other) {
    if (other.currentPage != currentPage + 1) {
      throw ArgumentError(
        'Cannot combine: other page (${other.currentPage}) is not next page (${currentPage + 1})',
      );
    }

    return PaginatedResponse<T>(
      data: [...data, ...other.data],
      currentPage: other.currentPage,
      totalPages: other.totalPages,
      totalItems: other.totalItems,
      perPage: other.perPage,
    );
  }

  @override
  String toString() =>
      'PaginatedResponse(currentPage: $currentPage, totalPages: $totalPages, '
      'totalItems: $totalItems, perPage: $perPage, items: ${data.length})';
}
