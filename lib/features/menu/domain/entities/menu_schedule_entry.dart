/// One row of opening hours: day name and time range.
class MenuScheduleEntry {
  final String dayName;
  final String timeRange;
  final bool isToday;

  const MenuScheduleEntry({
    required this.dayName,
    required this.timeRange,
    required this.isToday,
  });
}
