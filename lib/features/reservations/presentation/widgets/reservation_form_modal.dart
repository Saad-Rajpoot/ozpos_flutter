import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../reservations/domain/entities/reservation_entity.dart';

class ReservationFormModal extends StatefulWidget {
  final ReservationEntity? reservation; // null for new, provided for edit

  const ReservationFormModal({super.key, this.reservation});

  @override
  State<ReservationFormModal> createState() => _ReservationFormModalState();
}

class _ReservationFormModalState extends State<ReservationFormModal> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _partySizeController;
  late final TextEditingController _notesController;

  // Form state
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  int _durationMinutes = 90;
  final List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();

    // Initialize with existing data or defaults
    final res = widget.reservation;
    _nameController = TextEditingController(text: res?.guest.name ?? '');
    _phoneController = TextEditingController(text: res?.guest.phone ?? '');
    _emailController = TextEditingController(text: res?.guest.email ?? '');
    _partySizeController = TextEditingController(
      text: res?.party.size.toString() ?? '2',
    );
    _notesController = TextEditingController(text: res?.guest.notes ?? '');

    if (res != null) {
      _selectedDate = res.timing.startAt;
      _selectedTime = TimeOfDay.fromDateTime(res.timing.startAt);
      _durationMinutes = res.timing.durationMinutes;
      _selectedTags.addAll(res.preferences.tags);
    } else {
      final now = DateTime.now();
      _selectedDate = now.add(const Duration(hours: 2));
      _selectedTime = TimeOfDay(hour: (now.hour + 2) % 24, minute: 0);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _partySizeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  DateTime get _fullDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  DateTime get _endDateTime =>
      _fullDateTime.add(Duration(minutes: _durationMinutes));

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 900,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Row(
          children: [
            // Left: Form
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Guest Information'),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Guest Name *',
                              _nameController,
                              'Enter full name',
                              validator: _requiredValidator,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    'Phone',
                                    _phoneController,
                                    '+1 XXX-XXX-XXXX',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    'Email',
                                    _emailController,
                                    'guest@example.com',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            _buildSectionTitle('Reservation Details'),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildDatePicker()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildTimePicker()),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    'Party Size *',
                                    _partySizeController,
                                    '0',
                                    keyboardType: TextInputType.number,
                                    validator: _partySizeValidator,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(child: _buildDurationPicker()),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTagsSection(),
                            const SizedBox(height: 32),

                            _buildSectionTitle('Additional Notes'),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _notesController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText:
                                    'Special requests, dietary restrictions, etc.',
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right: Summary
            Container(
              width: 320,
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                border: Border(left: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: _buildSummaryPanel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Text(
            widget.reservation == null ? 'New Reservation' : 'Edit Reservation',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              setState(() => _selectedDate = picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 12),
                Text(dateFormat.format(_selectedDate)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _selectedTime,
            );
            if (picked != null) {
              setState(() => _selectedTime = picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 18,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 12),
                Text(_selectedTime.format(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duration',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: _durationMinutes,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: [60, 90, 120, 150, 180, 240].map((mins) {
            return DropdownMenuItem(
              value: mins,
              child: Text(
                '${(mins / 60).toStringAsFixed(mins % 60 == 0 ? 0 : 1)}h',
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _durationMinutes = value!),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    final availableTags = [
      'Birthday',
      'Anniversary',
      'Allergy',
      'VIP',
      'Accessible',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag.toLowerCase());
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag.toLowerCase());
                  } else {
                    _selectedTags.remove(tag.toLowerCase());
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSummaryPanel() {
    final dateFormat = DateFormat('EEEE, MMM dd');
    final timeFormat = DateFormat('h:mm a');

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: const Text(
            'Reservation Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryItem(
                  'Guest',
                  _nameController.text.isEmpty ? '—' : _nameController.text,
                ),
                const SizedBox(height: 16),
                _buildSummaryItem(
                  'Date & Time',
                  '${dateFormat.format(_fullDateTime)}\n${timeFormat.format(_fullDateTime)}',
                ),
                const SizedBox(height: 16),
                _buildSummaryItem(
                  'Party Size',
                  _partySizeController.text.isEmpty
                      ? '—'
                      : '${_partySizeController.text} guests',
                ),
                const SizedBox(height: 16),
                _buildSummaryItem(
                  'Duration',
                  '${(_durationMinutes / 60).toStringAsFixed(_durationMinutes % 60 == 0 ? 0 : 1)} hours',
                ),
                const SizedBox(height: 16),
                _buildSummaryItem('End Time', timeFormat.format(_endDateTime)),
                if (_selectedTags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSummaryItem(
                    'Tags',
                    _selectedTags
                        .map((t) => t[0].toUpperCase() + t.substring(1))
                        .join(', '),
                  ),
                ],
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveReservation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Save Reservation'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _partySizeValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    final size = int.tryParse(value);
    if (size == null || size < 1) {
      return 'Must be at least 1';
    }
    if (size > 20) {
      return 'Maximum 20 guests';
    }
    return null;
  }

  void _saveReservation() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'partySize': int.parse(_partySizeController.text),
        'dateTime': _fullDateTime,
        'duration': _durationMinutes,
        'notes': _notesController.text,
        'tags': _selectedTags,
      };

      Navigator.pop(context, data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.reservation == null
                ? 'Reservation created successfully'
                : 'Reservation updated successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
