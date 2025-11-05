import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:flutter/material.dart' as material show TimeOfDay;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../bloc/combo_management_bloc.dart';
import '../../bloc/combo_management_state.dart';

class AvailabilityTab extends StatefulWidget {
  const AvailabilityTab({super.key});

  @override
  State<AvailabilityTab> createState() => _AvailabilityTabState();
}

class _AvailabilityViewState extends Equatable {
  const _AvailabilityViewState({
    this.orderTypes = const {
      'dineIn': true,
      'takeaway': true,
      'delivery': true,
      'online': true,
    },
    this.selectedTimeSlots = const {'Lunch'},
    this.selectedWeekdays = const {1, 2, 3, 4, 5, 6, 7},
    this.noEndDate = true,
  });

  final Map<String, bool> orderTypes;
  final Set<String> selectedTimeSlots;
  final Set<int> selectedWeekdays;
  final bool noEndDate;

  _AvailabilityViewState copyWith({
    Map<String, bool>? orderTypes,
    Set<String>? selectedTimeSlots,
    Set<int>? selectedWeekdays,
    bool? noEndDate,
  }) {
    return _AvailabilityViewState(
      orderTypes: orderTypes ?? Map<String, bool>.from(this.orderTypes),
      selectedTimeSlots:
          selectedTimeSlots ?? Set<String>.from(this.selectedTimeSlots),
      selectedWeekdays:
          selectedWeekdays ?? Set<int>.from(this.selectedWeekdays),
      noEndDate: noEndDate ?? this.noEndDate,
    );
  }

  @override
  List<Object?> get props => [
        orderTypes,
        selectedTimeSlots,
        selectedWeekdays,
        noEndDate,
      ];
}

class _AvailabilityTabState extends State<AvailabilityTab> {
  late final ValueNotifier<_AvailabilityViewState> _stateNotifier;

  @override
  void initState() {
    super.initState();
    _stateNotifier = ValueNotifier(const _AvailabilityViewState());
  }

  @override
  void dispose() {
    _stateNotifier.dispose();
    super.dispose();
  }

  void _updateState(_AvailabilityViewState newState) {
    _stateNotifier.value = newState;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_AvailabilityViewState>(
      valueListenable: _stateNotifier,
      builder: (context, viewState, _) {
        return BlocBuilder<ComboManagementBloc, ComboManagementState>(
          buildWhen: (previous, current) {
            // Only rebuild if editing combo changes
            return previous.editingCombo != current.editingCombo;
          },
          builder: (context, state) {
            final combo = state.editingCombo;
            if (combo == null) return const SizedBox.shrink();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Availability & Restrictions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Control when and how this combo deal is available to customers',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 32),
                  _buildOrderTypeSection(combo, viewState),
                  const SizedBox(height: 32),
                  _buildTimeRestrictionsSection(combo, viewState),
                  const SizedBox(height: 32),
                  _buildWeekdaySection(combo, viewState),
                  const SizedBox(height: 32),
                  _buildDateRangeSection(combo, viewState),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderTypeSection(
    combo,
    _AvailabilityViewState viewState,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Types',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Which order types can use this combo? (Select one or more)',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3.5,
            children: [
              _buildOrderTypeCard(
                'Dine In',
                'Customers eating at restaurant',
                Icons.restaurant,
                viewState.orderTypes['dineIn'] ?? false,
                (value) => _updateOrderType(viewState, 'dineIn', value),
              ),
              _buildOrderTypeCard(
                'Takeaway',
                'Customers picking up orders',
                Icons.shopping_bag,
                viewState.orderTypes['takeaway'] ?? false,
                (value) => _updateOrderType(viewState, 'takeaway', value),
              ),
              _buildOrderTypeCard(
                'Delivery',
                'Orders delivered to customers',
                Icons.delivery_dining,
                viewState.orderTypes['delivery'] ?? false,
                (value) => _updateOrderType(viewState, 'delivery', value),
              ),
              _buildOrderTypeCard(
                'Online Order',
                'Orders placed online',
                Icons.computer,
                viewState.orderTypes['online'] ?? false,
                (value) => _updateOrderType(viewState, 'online', value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeCard(
    String title,
    String description,
    IconData icon,
    bool isEnabled,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEnabled
            ? const Color(0xFF10B981).withOpacity(0.1)
            : Colors.grey.withOpacity(0.05),
        border: Border.all(
          color: isEnabled ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
          width: isEnabled ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                isEnabled ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isEnabled
                        ? const Color(0xFF10B981)
                        : const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isEnabled,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF10B981),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRestrictionsSection(
    combo,
    _AvailabilityViewState viewState,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Time Restrictions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select one or more time periods when this combo is available',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _buildTimeSlotCard(
                'Breakfast',
                '07:00-11:00',
                Icons.wb_sunny,
                viewState.selectedTimeSlots.contains('Breakfast'),
                () => _toggleTimeSlot(viewState, 'Breakfast'),
              ),
              _buildTimeSlotCard(
                'Lunch',
                '11:00-15:00',
                Icons.lunch_dining,
                viewState.selectedTimeSlots.contains('Lunch'),
                () => _toggleTimeSlot(viewState, 'Lunch'),
              ),
              _buildTimeSlotCard(
                'Dinner',
                '18:00-22:00',
                Icons.dinner_dining,
                viewState.selectedTimeSlots.contains('Dinner'),
                () => _toggleTimeSlot(viewState, 'Dinner'),
              ),
              _buildTimeSlotCard(
                'Custom',
                'Set times',
                Icons.schedule,
                viewState.selectedTimeSlots.contains('Custom'),
                () => _showCustomTimeDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotCard(
    String title,
    String timeRange,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8B5CF6).withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color:
                isSelected ? const Color(0xFF8B5CF6) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? const Color(0xFF8B5CF6)
                      : const Color(0xFF9CA3AF),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF8B5CF6)
                          : const Color(0xFF111827),
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 16,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              timeRange,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdaySection(
    combo,
    _AvailabilityViewState viewState,
  ) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Days of Week',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select which days this combo deal is available',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 20),
          Row(
            children: weekdays.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              final isSelected = viewState.selectedWeekdays.contains(index + 1);

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < weekdays.length - 1 ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => _toggleWeekday(viewState, index + 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFF8B5CF6) : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF8B5CF6)
                              : const Color(0xFFE5E7EB),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSection(
    combo,
    _AvailabilityViewState viewState,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deal Duration',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set the start and end dates for this combo deal',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectStartDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Color(0xFF6B7280),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Jan 15, 2024',
                              style: TextStyle(color: Color(0xFF111827)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'End Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectEndDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Color(0xFF6B7280),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Dec 31, 2024',
                              style: TextStyle(color: Color(0xFF111827)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: viewState.noEndDate,
                onChanged: (value) {
                  if (value != null) {
                    _updateState(viewState.copyWith(noEndDate: value));
                  }
                },
                activeColor: const Color(0xFF8B5CF6),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'No end date (deal runs indefinitely)',
                  style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Event handlers
  void _updateOrderType(
    _AvailabilityViewState previous,
    String orderType,
    bool enabled,
  ) {
    final updated = Map<String, bool>.from(previous.orderTypes);
    updated[orderType] = enabled;
    _updateState(previous.copyWith(orderTypes: updated));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${enabled ? 'Enabled' : 'Disabled'} $orderType orders'),
      ),
    );
  }

  void _toggleTimeSlot(
    _AvailabilityViewState previous,
    String name,
  ) {
    final updated = Set<String>.from(previous.selectedTimeSlots);
    if (updated.contains(name)) {
      updated.remove(name);
    } else {
      updated.add(name);
    }
    _updateState(previous.copyWith(selectedTimeSlots: updated));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${updated.contains(name) ? 'Selected' : 'Deselected'} $name time slot',
        ),
      ),
    );
  }

  void _showCustomTimeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Time Period'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Start Time',
                hintText: '09:00',
              ),
              onTap: () async {
                await showTimePicker(
                  context: context,
                  initialTime: material.TimeOfDay.now(),
                );
                // Handle time selection
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'End Time',
                hintText: '17:00',
              ),
              onTap: () async {
                await showTimePicker(
                  context: context,
                  initialTime: material.TimeOfDay.now(),
                );
                // Handle time selection
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Custom time period added')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _toggleWeekday(
    _AvailabilityViewState previous,
    int weekday,
  ) {
    final updated = Set<int>.from(previous.selectedWeekdays);
    if (updated.contains(weekday)) {
      updated.remove(weekday);
    } else {
      updated.add(weekday);
    }
    _updateState(previous.copyWith(selectedWeekdays: updated));

    final weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = weekdayNames[weekday - 1];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${updated.contains(weekday) ? 'Selected' : 'Deselected'} $dayName',
        ),
      ),
    );
  }

  void _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Start date: ${date.toString().split(' ')[0]}')),
      );
    }
  }

  void _selectEndDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('End date: ${date.toString().split(' ')[0]}')),
      );
    }
  }
}
