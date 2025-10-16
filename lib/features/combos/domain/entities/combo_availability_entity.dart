import 'package:equatable/equatable.dart';

enum OrderType { dineIn, takeaway, delivery, online }

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

class TimeWindow extends Equatable {
  final String id;
  final String name; // "Breakfast", "Lunch", "Dinner", "Custom"
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const TimeWindow({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  bool get isCustom => name == 'Custom';

  bool isActiveAt(TimeOfDay time) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final checkMinutes = time.hour * 60 + time.minute;

    if (startMinutes <= endMinutes) {
      // Same day window
      return checkMinutes >= startMinutes && checkMinutes <= endMinutes;
    } else {
      // Crosses midnight
      return checkMinutes >= startMinutes || checkMinutes <= endMinutes;
    }
  }

  @override
  List<Object?> get props => [id, name, startTime, endTime];
}

class TimeOfDay extends Equatable {
  final int hour; // 0-23
  final int minute; // 0-59

  const TimeOfDay({required this.hour, required this.minute});

  factory TimeOfDay.now() {
    final now = DateTime.now();
    return TimeOfDay(hour: now.hour, minute: now.minute);
  }

  String get formatted {
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final ampm = hour < 12 ? 'AM' : 'PM';
    return '$h:${minute.toString().padLeft(2, '0')} $ampm';
  }

  @override
  List<Object?> get props => [hour, minute];
}

class ComboAvailabilityEntity extends Equatable {
  // Visibility channels
  final bool posSystem;
  final bool onlineMenu;

  // Order types
  final List<OrderType> orderTypes;

  // Time restrictions
  final List<TimeWindow> timeWindows;

  // Day restrictions
  final List<DayOfWeek> daysOfWeek;

  // Date range restrictions
  final DateTime? startDate;
  final DateTime? endDate;

  const ComboAvailabilityEntity({
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

  // Factory constructors for common availability patterns

  static ComboAvailabilityEntity lunchOnly() {
    return ComboAvailabilityEntity(
      timeWindows: [
        TimeWindow(
          id: 'lunch',
          name: 'Lunch',
          startTime: TimeOfDay(hour: 11, minute: 0),
          endTime: TimeOfDay(hour: 15, minute: 0),
        ),
      ],
      daysOfWeek: [
        DayOfWeek.monday,
        DayOfWeek.tuesday,
        DayOfWeek.wednesday,
        DayOfWeek.thursday,
        DayOfWeek.friday,
      ],
    );
  }

  static ComboAvailabilityEntity weekendSpecial() {
    return ComboAvailabilityEntity(
      daysOfWeek: [DayOfWeek.saturday, DayOfWeek.sunday],
    );
  }

  static ComboAvailabilityEntity limitedTime({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return ComboAvailabilityEntity(startDate: startDate, endDate: endDate);
  }

  // Computed properties

  bool get isVisibleAnywhere => posSystem || onlineMenu;

  bool get hasTimeRestrictions => timeWindows.isNotEmpty;

  bool get hasDayRestrictions => daysOfWeek.length < 7;

  bool get hasDateRestrictions => startDate != null || endDate != null;

  bool get isLimitedTime => hasDateRestrictions;

  bool get isWeekendSpecial =>
      daysOfWeek.length == 2 &&
      daysOfWeek.contains(DayOfWeek.saturday) &&
      daysOfWeek.contains(DayOfWeek.sunday);

  bool get isWeekdaysOnly =>
      daysOfWeek.length == 5 &&
      !daysOfWeek.contains(DayOfWeek.saturday) &&
      !daysOfWeek.contains(DayOfWeek.sunday);

  bool get isCurrentlyAvailable {
    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
    final currentDay = _dayOfWeekFromDateTime(now);

    // Check date restrictions
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;

    // Check day restrictions
    if (!daysOfWeek.contains(currentDay)) return false;

    // Check time restrictions
    if (timeWindows.isNotEmpty) {
      return timeWindows.any((window) => window.isActiveAt(currentTime));
    }

    return true;
  }

  Duration? get timeUntilNextAvailability {
    if (isCurrentlyAvailable) return null;

    // This would require more complex logic to find the next valid time slot
    return null;
  }

  String get previewText {
    final parts = <String>[];

    // Visibility
    if (posSystem && onlineMenu) {
      parts.add('POS & Online');
    } else if (posSystem) {
      parts.add('POS Only');
    } else if (onlineMenu) {
      parts.add('Online Only');
    }

    // Time windows
    if (timeWindows.isNotEmpty) {
      parts.add(timeWindows.map((w) => w.name).join(', '));
    }

    // Days
    if (isWeekendSpecial) {
      parts.add('Weekends');
    } else if (isWeekdaysOnly) {
      parts.add('Weekdays');
    } else if (hasDayRestrictions) {
      parts.add('${daysOfWeek.length} days');
    }

    // Date range
    if (hasDateRestrictions) {
      if (startDate != null && endDate != null) {
        parts.add('${_formatDate(startDate!)}-${_formatDate(endDate!)}');
      } else if (startDate != null) {
        parts.add('From ${_formatDate(startDate!)}');
      } else if (endDate != null) {
        parts.add('Until ${_formatDate(endDate!)}');
      }
    }

    return parts.join(' · ');
  }

  List<String> get validationErrors {
    final List<String> errors = [];

    if (!isVisibleAnywhere) {
      errors.add('Combo must be visible on POS or Online');
    }

    if (orderTypes.isEmpty) {
      errors.add('At least one order type must be selected');
    }

    if (daysOfWeek.isEmpty) {
      errors.add('At least one day must be selected');
    }

    if (startDate != null && endDate != null && startDate!.isAfter(endDate!)) {
      errors.add('Start date must be before end date');
    }

    for (final window in timeWindows) {
      if (window.startTime.hour == window.endTime.hour &&
          window.startTime.minute == window.endTime.minute) {
        errors.add('Time window "${window.name}" has no duration');
      }
    }

    return errors;
  }

  // Helper methods

  DayOfWeek _dayOfWeekFromDateTime(DateTime date) {
    // DateTime.weekday: Monday = 1, Sunday = 7
    switch (date.weekday) {
      case 1:
        return DayOfWeek.monday;
      case 2:
        return DayOfWeek.tuesday;
      case 3:
        return DayOfWeek.wednesday;
      case 4:
        return DayOfWeek.thursday;
      case 5:
        return DayOfWeek.friday;
      case 6:
        return DayOfWeek.saturday;
      case 7:
        return DayOfWeek.sunday;
      default:
        return DayOfWeek.monday;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  ComboAvailabilityEntity copyWith({
    bool? posSystem,
    bool? onlineMenu,
    List<OrderType>? orderTypes,
    List<TimeWindow>? timeWindows,
    List<DayOfWeek>? daysOfWeek,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ComboAvailabilityEntity(
      posSystem: posSystem ?? this.posSystem,
      onlineMenu: onlineMenu ?? this.onlineMenu,
      orderTypes: orderTypes ?? this.orderTypes,
      timeWindows: timeWindows ?? this.timeWindows,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
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
