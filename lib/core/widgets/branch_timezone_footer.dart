import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../di/injection_container.dart' as di;

/// Footer showing current date and time in the branch timezone from the API.
/// Shown in the sidebar at all times; uses device local time if timezone not set.
class BranchTimezoneFooter extends StatefulWidget {
  const BranchTimezoneFooter({super.key});

  @override
  State<BranchTimezoneFooter> createState() => _BranchTimezoneFooterState();
}

class _BranchTimezoneFooterState extends State<BranchTimezoneFooter> {
  String? _timezoneName;
  Timer? _timer;
  Timer? _timezoneReloadTimer;
  static final DateFormat _dateFormat = DateFormat('EEE d MMM yyyy');
  static final DateFormat _timeFormat = DateFormat('h:mm:ss a');

  @override
  void initState() {
    super.initState();
    _loadTimezone();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _timezoneReloadTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => _loadTimezone());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timezoneReloadTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTimezone() async {
    try {
      final prefs = di.sl<SharedPreferences>();
      final tzName = prefs.getString(AppConstants.branchTimezoneKey);
      if (mounted) setState(() => _timezoneName = tzName);
    } catch (_) {
      if (mounted) setState(() => _timezoneName = null);
    }
  }

  String _formatNowInZone() {
    if (_timezoneName != null && _timezoneName!.isNotEmpty) {
      try {
        final location = tz.getLocation(_timezoneName!);
        final now = tz.TZDateTime.now(location);
        return '${_dateFormat.format(now)}  ${_timeFormat.format(now)}';
      } catch (_) {
        // fallback to local
      }
    }
    final now = DateTime.now();
    return '${_dateFormat.format(now)}  ${_timeFormat.format(now)} (Local)';
  }

  String get _zoneLabel =>
      (_timezoneName != null && _timezoneName!.isNotEmpty)
          ? _timezoneName!
          : 'Local';

  void _showDateTimeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _DateTimeDialog(timezoneName: _timezoneName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sidebarBg,
      child: InkWell(
        onTap: () => _showDateTimeDialog(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.sidebarTextMuted.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _formatNowInZone(),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.sidebarTextMuted,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _zoneLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.sidebarTextMuted.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog showing full date and time (updates every second while open).
class _DateTimeDialog extends StatefulWidget {
  final String? timezoneName;

  const _DateTimeDialog({this.timezoneName});

  @override
  State<_DateTimeDialog> createState() => _DateTimeDialogState();
}

class _DateTimeDialogState extends State<_DateTimeDialog> {
  Timer? _timer;
  static final DateFormat _dateFormat = DateFormat('EEEE, d MMMM yyyy');
  static final DateFormat _timeFormat = DateFormat('h:mm:ss a');

  String _formatNow() {
    if (widget.timezoneName != null && widget.timezoneName!.isNotEmpty) {
      try {
        final location = tz.getLocation(widget.timezoneName!);
        final now = tz.TZDateTime.now(location);
        return '${_dateFormat.format(now)}\n${_timeFormat.format(now)}';
      } catch (_) {}
    }
    final now = DateTime.now();
    return '${_dateFormat.format(now)}\n${_timeFormat.format(now)} (Local)';
  }

  String get _zoneLabel =>
      (widget.timezoneName != null && widget.timezoneName!.isNotEmpty)
          ? widget.timezoneName!
          : 'Local';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.schedule, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Date & time'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatNow(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Timezone: $_zoneLabel',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
