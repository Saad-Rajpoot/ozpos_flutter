import '../constants/app_constants.dart';

/// Pagination parameters for API requests
class PaginationParams {
  /// Current page number (1-indexed)
  final int page;

  /// Number of items per page
  final int limit;

  /// Optional sort field
  final String? sortBy;

  /// Optional sort direction (asc, desc)
  final String? sortOrder;

  const PaginationParams({
    this.page = 1,
    this.limit = AppConstants.defaultPageSize,
    this.sortBy,
    this.sortOrder,
  })  : assert(page > 0, 'Page must be greater than 0'),
        assert(limit > 0, 'Limit must be greater than 0'),
        assert(
          limit <= AppConstants.maxPageSize,
          'Limit cannot exceed ${AppConstants.maxPageSize}',
        );

  /// Create pagination params with custom limit
  factory PaginationParams.withLimit(int limit) {
    return PaginationParams(
      page: 1,
      limit: limit.clamp(1, AppConstants.maxPageSize),
    );
  }

  /// Create pagination params for next page
  PaginationParams nextPage() {
    return PaginationParams(
      page: page + 1,
      limit: limit,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  /// Create pagination params for previous page
  PaginationParams previousPage() {
    return PaginationParams(
      page: (page - 1).clamp(1, double.infinity).toInt(),
      limit: limit,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  /// Convert to query parameters map
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit.clamp(1, AppConstants.maxPageSize),
    };

    if (sortBy != null) {
      params['sort_by'] = sortBy;
    }

    if (sortOrder != null) {
      params['sort_order'] = sortOrder;
    }

    return params;
  }

  /// Create from query parameters map
  factory PaginationParams.fromQueryParams(Map<String, dynamic> params) {
    return PaginationParams(
      page: (params['page'] as int?) ?? 1,
      limit: (params['limit'] as int?) ?? AppConstants.defaultPageSize,
      sortBy: params['sort_by'] as String?,
      sortOrder: params['sort_order'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginationParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit &&
          sortBy == other.sortBy &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode =>
      page.hashCode ^
      limit.hashCode ^
      (sortBy?.hashCode ?? 0) ^
      (sortOrder?.hashCode ?? 0);

  @override
  String toString() =>
      'PaginationParams(page: $page, limit: $limit, sortBy: $sortBy, sortOrder: $sortOrder)';
}
