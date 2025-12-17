import 'package:equatable/equatable.dart';

/// Reservation status enum based on JSON structure
enum ReservationStatus { pending, confirmed, seated, cancelled }

/// Reservation source enum based on JSON structure
enum ReservationSource { phone, website, app }

/// Guest information
class Guest extends Equatable {
  final String name;
  final String phone;
  final String? email;
  final String? notes;

  const Guest({
    required this.name,
    required this.phone,
    this.email = '',
    this.notes = '',
  });

  @override
  List<Object?> get props => [name, phone, email, notes];

  Guest copyWith({String? name, String? phone, String? email, String? notes}) {
    return Guest(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
    );
  }
}

/// Party details
class Party extends Equatable {
  final int size;

  const Party({required this.size});

  @override
  List<Object?> get props => [size];

  Party copyWith({int? size}) {
    return Party(size: size ?? this.size);
  }
}

/// Reservation timing
class Timing extends Equatable {
  final DateTime startAt;
  final int durationMinutes;

  const Timing({required this.startAt, required this.durationMinutes});

  @override
  List<Object?> get props => [startAt, durationMinutes];

  Timing copyWith({DateTime? startAt, int? durationMinutes}) {
    return Timing(
      startAt: startAt ?? this.startAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}

/// Reservation preferences
class Preferences extends Equatable {
  final List<String> tags;

  const Preferences({required this.tags});

  @override
  List<Object?> get props => [tags];

  Preferences copyWith({List<String>? tags}) {
    return Preferences(tags: tags ?? this.tags);
  }
}

/// Reservation financials
class Financials extends Equatable {
  const Financials();

  @override
  List<Object?> get props => [];

  Financials copyWith() {
    return Financials();
  }
}

/// Reservation audit info
class Audit extends Equatable {
  final String createdBy;
  final DateTime createdAt;

  const Audit({required this.createdBy, required this.createdAt});

  @override
  List<Object?> get props => [createdBy, createdAt];

  Audit copyWith({String? createdBy, DateTime? createdAt}) {
    return Audit(
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Main Reservation Entity - matches JSON structure exactly
class ReservationEntity extends Equatable {
  final String reservationId;
  final String vendorId;
  final String branchId;
  final String tableId;
  final Guest guest;
  final Party party;
  final Timing timing;
  final ReservationStatus status;
  final ReservationSource source;
  final Preferences preferences;
  final Financials financials;
  final Audit audit;

  const ReservationEntity({
    required this.reservationId,
    required this.vendorId,
    required this.branchId,
    required this.tableId,
    required this.guest,
    required this.party,
    required this.timing,
    required this.status,
    required this.source,
    required this.preferences,
    required this.financials,
    required this.audit,
  });

  @override
  List<Object?> get props => [
    reservationId,
    vendorId,
    branchId,
    tableId,
    guest,
    party,
    timing,
    status,
    source,
    preferences,
    financials,
    audit,
  ];

  ReservationEntity copyWith({
    String? reservationId,
    String? vendorId,
    String? branchId,
    String? tableId,
    Guest? guest,
    Party? party,
    Timing? timing,
    ReservationStatus? status,
    ReservationSource? source,
    Preferences? preferences,
    Financials? financials,
    Audit? audit,
  }) {
    return ReservationEntity(
      reservationId: reservationId ?? this.reservationId,
      vendorId: vendorId ?? this.vendorId,
      branchId: branchId ?? this.branchId,
      tableId: tableId ?? this.tableId,
      guest: guest ?? this.guest,
      party: party ?? this.party,
      timing: timing ?? this.timing,
      status: status ?? this.status,
      source: source ?? this.source,
      preferences: preferences ?? this.preferences,
      financials: financials ?? this.financials,
      audit: audit ?? this.audit,
    );
  }
}
