import 'package:equatable/equatable.dart';
import '../../domain/entities/combo_availability_entity.dart';

/// Model class for TimeOfDay JSON serialization/deserialization
class TimeOfDayModel extends Equatable {
  final int hour;
  final int minute;

  const TimeOfDayModel({required this.hour, required this.minute});

  /// Convert JSON to TimeOfDayModel
  factory TimeOfDayModel.fromJson(Map<String, dynamic> json) {
    return TimeOfDayModel(
      hour: json['hour'] as int,
      minute: json['minute'] as int,
    );
  }

  /// Convert TimeOfDayModel to JSON
  Map<String, dynamic> toJson() {
    return {'hour': hour, 'minute': minute};
  }

  /// Convert TimeOfDayModel to TimeOfDay entity
  TimeOfDay toEntity() {
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Create TimeOfDayModel from TimeOfDay entity
  factory TimeOfDayModel.fromEntity(TimeOfDay entity) {
    return TimeOfDayModel(hour: entity.hour, minute: entity.minute);
  }

  @override
  List<Object?> get props => [hour, minute];
}

/// Model class for TimeWindow JSON serialization/deserialization
class TimeWindowModel extends Equatable {
  final String id;
  final String name;
  final TimeOfDayModel startTime;
  final TimeOfDayModel endTime;

  const TimeWindowModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  /// Convert JSON to TimeWindowModel
  factory TimeWindowModel.fromJson(Map<String, dynamic> json) {
    return TimeWindowModel(
      id: json['id'] as String,
      name: json['name'] as String,
      startTime: TimeOfDayModel.fromJson(
        json['startTime'] as Map<String, dynamic>,
      ),
      endTime: TimeOfDayModel.fromJson(json['endTime'] as Map<String, dynamic>),
    );
  }

  /// Convert TimeWindowModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startTime': startTime.toJson(),
      'endTime': endTime.toJson(),
    };
  }

  /// Convert TimeWindowModel to TimeWindow entity
  TimeWindow toEntity() {
    return TimeWindow(
      id: id,
      name: name,
      startTime: startTime.toEntity(),
      endTime: endTime.toEntity(),
    );
  }

  /// Create TimeWindowModel from TimeWindow entity
  factory TimeWindowModel.fromEntity(TimeWindow entity) {
    return TimeWindowModel(
      id: entity.id,
      name: entity.name,
      startTime: TimeOfDayModel.fromEntity(entity.startTime),
      endTime: TimeOfDayModel.fromEntity(entity.endTime),
    );
  }

  @override
  List<Object?> get props => [id, name, startTime, endTime];
}

/// Model class for ComboAvailability JSON serialization/deserialization
class ComboAvailabilityModel extends Equatable {
  final bool posSystem;
  final bool onlineMenu;
  final List<OrderType> orderTypes;
  final List<TimeWindowModel> timeWindows;
  final List<DayOfWeek> daysOfWeek;
  final DateTime? startDate;
  final DateTime? endDate;

  const ComboAvailabilityModel({
    this.posSystem = true,
    this.onlineMenu = true,
    this.orderTypes = const [
      OrderType.dineIn,
      OrderType.takeaway,
      OrderType.delivery,
    ],
    this.timeWindows = const [],
    this.daysOfWeek = const [
      DayOfWeek.monday,
      DayOfWeek.tuesday,
      DayOfWeek.wednesday,
      DayOfWeek.thursday,
      DayOfWeek.friday,
      DayOfWeek.saturday,
      DayOfWeek.sunday,
    ],
    this.startDate,
    this.endDate,
  });

  /// Convert JSON to ComboAvailabilityModel
  factory ComboAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return ComboAvailabilityModel(
      posSystem: json['posSystem'] as bool? ?? true,
      onlineMenu: json['onlineMenu'] as bool? ?? true,
      orderTypes:
          (json['orderTypes'] as List<dynamic>?)
              ?.map(
                (e) => OrderType.values.firstWhere(
                  (type) => type.toString().split('.').last == e,
                ),
              )
              .toList() ??
          const [OrderType.dineIn, OrderType.takeaway, OrderType.delivery],
      timeWindows:
          (json['timeWindows'] as List<dynamic>?)
              ?.map(
                (window) =>
                    TimeWindowModel.fromJson(window as Map<String, dynamic>),
              )
              .toList() ??
          [],
      daysOfWeek:
          (json['daysOfWeek'] as List<dynamic>?)
              ?.map(
                (e) => DayOfWeek.values.firstWhere(
                  (day) => day.toString().split('.').last == e,
                ),
              )
              .toList() ??
          const [
            DayOfWeek.monday,
            DayOfWeek.tuesday,
            DayOfWeek.wednesday,
            DayOfWeek.thursday,
            DayOfWeek.friday,
            DayOfWeek.saturday,
            DayOfWeek.sunday,
          ],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
    );
  }

  /// Convert ComboAvailabilityModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'posSystem': posSystem,
      'onlineMenu': onlineMenu,
      'orderTypes': orderTypes
          .map((type) => type.toString().split('.').last)
          .toList(),
      'timeWindows': timeWindows.map((window) => window.toJson()).toList(),
      'daysOfWeek': daysOfWeek
          .map((day) => day.toString().split('.').last)
          .toList(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  /// Convert ComboAvailabilityModel to ComboAvailabilityEntity
  ComboAvailabilityEntity toEntity() {
    return ComboAvailabilityEntity(
      posSystem: posSystem,
      onlineMenu: onlineMenu,
      orderTypes: orderTypes,
      timeWindows: timeWindows.map((window) => window.toEntity()).toList(),
      daysOfWeek: daysOfWeek,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Create ComboAvailabilityModel from ComboAvailabilityEntity
  factory ComboAvailabilityModel.fromEntity(ComboAvailabilityEntity entity) {
    return ComboAvailabilityModel(
      posSystem: entity.posSystem,
      onlineMenu: entity.onlineMenu,
      orderTypes: entity.orderTypes,
      timeWindows: entity.timeWindows
          .map((window) => TimeWindowModel.fromEntity(window))
          .toList(),
      daysOfWeek: entity.daysOfWeek,
      startDate: entity.startDate,
      endDate: entity.endDate,
    );
  }

  @override
  List<Object?> get props => [
    posSystem,
    onlineMenu,
    orderTypes,
    timeWindows,
    daysOfWeek,
    startDate,
    endDate,
  ];
}
