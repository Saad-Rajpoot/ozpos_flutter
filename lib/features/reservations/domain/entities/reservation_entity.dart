/// Reservation status enum
enum ReservationStatus {
  pending,
  confirmed,
  seated,
  completed,
  cancelled,
  noShow,
}

/// Reservation source enum
enum ReservationSource { walkIn, phone, website, app, integration }

/// Deposit status enum
enum DepositStatus { held, refunded, applied }

/// Guest information
class GuestInfo {
  final String name;
  final String? phone;
  final String? email;

  const GuestInfo({required this.name, this.phone, this.email});

  bool get hasContactInfo => phone != null || email != null;
}

/// Party details
class PartyDetails {
  final int size;
  final int? highChairs;
  final bool? specialNeeds;

  const PartyDetails({required this.size, this.highChairs, this.specialNeeds});

  bool get requiresAccessibility =>
      specialNeeds == true || (highChairs != null && highChairs! > 0);
}

/// Reservation timing
class ReservationTiming {
  final DateTime startAt;
  final int durationMinutes;
  final String timezone;

  const ReservationTiming({
    required this.startAt,
    this.durationMinutes = 90,
    this.timezone = 'UTC',
  });

  DateTime get endAt => startAt.add(Duration(minutes: durationMinutes));

  bool get isToday {
    final now = DateTime.now();
    return startAt.year == now.year &&
        startAt.month == now.month &&
        startAt.day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return startAt.year == tomorrow.year &&
        startAt.month == tomorrow.month &&
        startAt.day == tomorrow.day;
  }

  bool get isInPast => startAt.isBefore(DateTime.now());
}

/// Reservation preferences
class ReservationPreferences {
  final String? areaId;
  final String? tablePreferenceId;
  final bool autoAssign;
  final List<String> tags;

  const ReservationPreferences({
    this.areaId,
    this.tablePreferenceId,
    this.autoAssign = true,
    this.tags = const [],
  });

  bool get hasBirthdayTag => tags.contains('birthday');
  bool get hasAllergyTag => tags.contains('allergy');
}

/// Reservation financials
class ReservationFinancials {
  final double? depositAmount;
  final DepositStatus? depositStatus;
  final double? cancellationFee;

  const ReservationFinancials({
    this.depositAmount,
    this.depositStatus,
    this.cancellationFee,
  });

  bool get hasDeposit => depositAmount != null && depositAmount! > 0;
  bool get isDepositRefundable => depositStatus == DepositStatus.held;
}

/// Reservation audit info
class AuditInfo {
  final String createdBy;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AuditInfo({
    required this.createdBy,
    this.updatedBy,
    required this.createdAt,
    this.updatedAt,
  });
}

/// Main Reservation Entity
class ReservationEntity {
  // IDs & Links
  final String reservationId;
  final String vendorId;
  final String branchId;
  final String? orderId;
  final String? tableId;

  // Guest & Party
  final GuestInfo guest;
  final PartyDetails party;

  // Timing
  final ReservationTiming timing;

  // Status & Source
  final ReservationStatus status;
  final ReservationSource source;
  final String? externalRef;

  // Preferences
  final ReservationPreferences preferences;

  // Financials
  final ReservationFinancials financials;

  // Notes
  final String? notes;

  // Audit
  final AuditInfo audit;

  // Sync/Meta
  final bool isDirty;
  final String? syncStatus;
  final int version;
  final String? idempotencyKey;

  const ReservationEntity({
    required this.reservationId,
    required this.vendorId,
    required this.branchId,
    this.orderId,
    this.tableId,
    required this.guest,
    required this.party,
    required this.timing,
    required this.status,
    required this.source,
    this.externalRef,
    required this.preferences,
    required this.financials,
    this.notes,
    required this.audit,
    this.isDirty = false,
    this.syncStatus,
    this.version = 1,
    this.idempotencyKey,
  });

  // Business Logic
  bool get isActive =>
      status == ReservationStatus.pending ||
      status == ReservationStatus.confirmed ||
      status == ReservationStatus.seated;

  bool get canSeat =>
      (status == ReservationStatus.pending ||
          status == ReservationStatus.confirmed) &&
      !timing.isInPast;

  bool get canEdit =>
      status != ReservationStatus.completed &&
      status != ReservationStatus.cancelled;

  bool get canCancel =>
      status != ReservationStatus.completed &&
      status != ReservationStatus.cancelled &&
      status != ReservationStatus.noShow;

  bool get canCheckout => status == ReservationStatus.seated && orderId != null;

  bool get isSeated => status == ReservationStatus.seated;

  bool get hasTable => tableId != null;

  String get displayStatus {
    switch (status) {
      case ReservationStatus.pending:
        return 'Pending';
      case ReservationStatus.confirmed:
        return 'Confirmed';
      case ReservationStatus.seated:
        return 'Seated';
      case ReservationStatus.completed:
        return 'Completed';
      case ReservationStatus.cancelled:
        return 'Cancelled';
      case ReservationStatus.noShow:
        return 'No Show';
    }
  }

  String get displaySource {
    switch (source) {
      case ReservationSource.walkIn:
        return 'Walk-in';
      case ReservationSource.phone:
        return 'Phone';
      case ReservationSource.website:
        return 'Website';
      case ReservationSource.app:
        return 'App';
      case ReservationSource.integration:
        return 'Integration';
    }
  }

  // State Transitions
  bool canTransitionTo(ReservationStatus newStatus) {
    switch (status) {
      case ReservationStatus.pending:
        return newStatus == ReservationStatus.confirmed ||
            newStatus == ReservationStatus.seated ||
            newStatus == ReservationStatus.cancelled ||
            newStatus == ReservationStatus.noShow;

      case ReservationStatus.confirmed:
        return newStatus == ReservationStatus.seated ||
            newStatus == ReservationStatus.cancelled ||
            newStatus == ReservationStatus.noShow;

      case ReservationStatus.seated:
        return newStatus == ReservationStatus.completed ||
            newStatus == ReservationStatus.cancelled ||
            newStatus == ReservationStatus.noShow;

      case ReservationStatus.completed:
      case ReservationStatus.cancelled:
      case ReservationStatus.noShow:
        return false; // Terminal states
    }
  }

  // Copy with
  ReservationEntity copyWith({
    String? reservationId,
    String? vendorId,
    String? branchId,
    String? orderId,
    String? tableId,
    GuestInfo? guest,
    PartyDetails? party,
    ReservationTiming? timing,
    ReservationStatus? status,
    ReservationSource? source,
    String? externalRef,
    ReservationPreferences? preferences,
    ReservationFinancials? financials,
    String? notes,
    AuditInfo? audit,
    bool? isDirty,
    String? syncStatus,
    int? version,
    String? idempotencyKey,
  }) {
    return ReservationEntity(
      reservationId: reservationId ?? this.reservationId,
      vendorId: vendorId ?? this.vendorId,
      branchId: branchId ?? this.branchId,
      orderId: orderId ?? this.orderId,
      tableId: tableId ?? this.tableId,
      guest: guest ?? this.guest,
      party: party ?? this.party,
      timing: timing ?? this.timing,
      status: status ?? this.status,
      source: source ?? this.source,
      externalRef: externalRef ?? this.externalRef,
      preferences: preferences ?? this.preferences,
      financials: financials ?? this.financials,
      notes: notes ?? this.notes,
      audit: audit ?? this.audit,
      isDirty: isDirty ?? this.isDirty,
      syncStatus: syncStatus ?? this.syncStatus,
      version: version ?? this.version,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    );
  }
}
