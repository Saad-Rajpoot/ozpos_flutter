import 'package:equatable/equatable.dart';
import '../../domain/entities/reservation_entity.dart';

class ReservationModel extends Equatable {
  final String reservationId;
  final String vendorId;
  final String branchId;
  final String tableId;
  final GuestModel guest;
  final PartyModel party;
  final TimingModel timing;
  final String status;
  final String source;
  final PreferencesModel preferences;
  final FinancialsModel financials;
  final AuditModel audit;

  const ReservationModel({
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

  // JSON serialization
  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      reservationId: json['reservationId'] as String? ?? '',
      vendorId: json['vendorId'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      tableId: json['tableId'] as String? ?? '',
      guest: GuestModel.fromJson(json['guest'] as Map<String, dynamic>? ?? {}),
      party: PartyModel.fromJson(json['party'] as Map<String, dynamic>? ?? {}),
      timing: TimingModel.fromJson(
        json['timing'] as Map<String, dynamic>? ?? {},
      ),
      status: json['status'] as String? ?? 'pending',
      source: json['source'] as String? ?? 'phone',
      preferences: PreferencesModel.fromJson(
        json['preferences'] as Map<String, dynamic>? ?? {},
      ),
      financials: FinancialsModel.fromJson(
        json['financials'] as Map<String, dynamic>? ?? {},
      ),
      audit: AuditModel.fromJson(json['audit'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reservationId': reservationId,
      'vendorId': vendorId,
      'branchId': branchId,
      'tableId': tableId,
      'guest': guest.toJson(),
      'party': party.toJson(),
      'timing': timing.toJson(),
      'status': status,
      'source': source,
      'preferences': preferences.toJson(),
      'financials': financials.toJson(),
      'audit': audit.toJson(),
    };
  }

  // Entity conversion
  ReservationEntity toEntity() {
    try {
      final entity = ReservationEntity(
        reservationId: reservationId,
        vendorId: vendorId,
        branchId: branchId,
        tableId: tableId,
        guest: guest.toEntity(),
        party: party.toEntity(),
        timing: timing.toEntity(),
        status: ReservationStatus.values.firstWhere(
          (e) => e.toString().split('.').last == status,
          orElse: () => ReservationStatus.pending,
        ),
        source: ReservationSource.values.firstWhere(
          (e) => e.toString().split('.').last == source,
          orElse: () => ReservationSource.phone,
        ),
        preferences: preferences.toEntity(),
        financials: financials.toEntity(),
        audit: audit.toEntity(),
      );
      return entity;
    } catch (e) {
      rethrow;
    }
  }

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
}

class GuestModel extends Equatable {
  final String name;
  final String phone;
  final String? email;
  final String? notes;

  const GuestModel({
    required this.name,
    required this.phone,
    this.email,
    this.notes,
  });

  factory GuestModel.fromJson(Map<String, dynamic> json) {
    return GuestModel(
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {'name': name, 'phone': phone};
    if (email != null) map['email'] = email ?? '';
    if (notes != null) map['notes'] = notes ?? '';
    return map;
  }

  Guest toEntity() {
    return Guest(
      name: name,
      phone: phone,
      email: email ?? '',
      notes: notes ?? '',
    );
  }

  @override
  List<Object?> get props => [name, phone, email, notes];
}

class PartyModel extends Equatable {
  final int size;
  final bool? specialNeeds;

  const PartyModel({required this.size, this.specialNeeds});

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      size: json['size'] as int? ?? 1,
      specialNeeds: json['specialNeeds'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {'size': size};
    return map;
  }

  Party toEntity() {
    return Party(size: size);
  }

  @override
  List<Object?> get props => [size, specialNeeds];
}

class TimingModel extends Equatable {
  final String startAt;
  final int durationMinutes;

  const TimingModel({required this.startAt, required this.durationMinutes});

  factory TimingModel.fromJson(Map<String, dynamic> json) {
    return TimingModel(
      startAt: json['startAt'] as String? ?? DateTime.now().toIso8601String(),
      durationMinutes: json['durationMinutes'] as int? ?? 60,
    );
  }

  Map<String, dynamic> toJson() {
    return {'startAt': startAt, 'durationMinutes': durationMinutes};
  }

  Timing toEntity() {
    return Timing(
      startAt: DateTime.parse(startAt),
      durationMinutes: durationMinutes,
    );
  }

  @override
  List<Object?> get props => [startAt, durationMinutes];
}

class PreferencesModel extends Equatable {
  final List<String> tags;

  const PreferencesModel({required this.tags});

  factory PreferencesModel.fromJson(Map<String, dynamic> json) {
    return PreferencesModel(
      tags: List<String>.from(json['tags'] as List<dynamic>? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'tags': tags};
  }

  Preferences toEntity() {
    return Preferences(tags: tags);
  }

  @override
  List<Object?> get props => [tags];
}

class FinancialsModel extends Equatable {
  final double? cancellationFee;
  final double? depositAmount;
  final String? depositStatus;

  const FinancialsModel({
    this.cancellationFee,
    this.depositAmount,
    this.depositStatus,
  });

  factory FinancialsModel.fromJson(Map<String, dynamic> json) {
    return FinancialsModel(
      cancellationFee: json['cancellationFee']?.toDouble(),
      depositAmount: json['depositAmount']?.toDouble(),
      depositStatus: json['depositStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (cancellationFee != null) {
      map['cancellationFee'] = cancellationFee;
    }
    if (depositAmount != null) {
      map['depositAmount'] = depositAmount;
    }
    if (depositStatus != null) {
      map['depositStatus'] = depositStatus;
    }
    return map;
  }

  Financials toEntity() {
    return Financials();
  }

  @override
  List<Object?> get props => [cancellationFee, depositAmount, depositStatus];
}

class AuditModel extends Equatable {
  final String createdBy;
  final String createdAt;

  const AuditModel({required this.createdBy, required this.createdAt});

  factory AuditModel.fromJson(Map<String, dynamic> json) {
    return AuditModel(
      createdBy: json['createdBy'] as String? ?? 'system',
      createdAt:
          json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'createdBy': createdBy, 'createdAt': createdAt};
  }

  Audit toEntity() {
    return Audit(createdBy: createdBy, createdAt: DateTime.parse(createdAt));
  }

  @override
  List<Object?> get props => [createdBy, createdAt];
}
