import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../constants/delivery_constants.dart';

enum VehicleType { bike, car, scooter, van }

class AddDriverModal extends StatefulWidget {
  const AddDriverModal({super.key});

  @override
  State<AddDriverModal> createState() => _AddDriverModalState();
}

class _AddDriverViewState extends Equatable {
  const _AddDriverViewState({
    this.selectedVehicle,
    this.selectedRole = 'Self-managed',
    this.selectedZones = const [],
    this.sendWelcomeSms = true,
    this.enableGpsTracking = true,
    this.allowCashPayments = false,
  });

  final VehicleType? selectedVehicle;
  final String selectedRole;
  final List<String> selectedZones;
  final bool sendWelcomeSms;
  final bool enableGpsTracking;
  final bool allowCashPayments;

  _AddDriverViewState copyWith({
    VehicleType? selectedVehicle,
    String? selectedRole,
    List<String>? selectedZones,
    bool? sendWelcomeSms,
    bool? enableGpsTracking,
    bool? allowCashPayments,
  }) {
    final zones = selectedZones ?? this.selectedZones;
    return _AddDriverViewState(
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      selectedRole: selectedRole ?? this.selectedRole,
      selectedZones: List<String>.from(zones),
      sendWelcomeSms: sendWelcomeSms ?? this.sendWelcomeSms,
      enableGpsTracking: enableGpsTracking ?? this.enableGpsTracking,
      allowCashPayments: allowCashPayments ?? this.allowCashPayments,
    );
  }

  @override
  List<Object?> get props => [
        selectedVehicle,
        selectedRole,
        selectedZones,
        sendWelcomeSms,
        enableGpsTracking,
        allowCashPayments,
      ];
}

class _AddDriverModalState extends State<AddDriverModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late final ValueNotifier<_AddDriverViewState> _viewNotifier;

  @override
  void initState() {
    super.initState();
    _generateCredentials();
    _viewNotifier = ValueNotifier(const _AddDriverViewState());
  }

  void _generateCredentials() {
    _usernameController.text = 'Auto-generated or custom';
    _passwordController.text = 'auto-generated-123';
  }

  void _updateState(_AddDriverViewState newState) {
    _viewNotifier.value = newState;
  }

  @override
  void dispose() {
    _viewNotifier.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_AddDriverViewState>(
      valueListenable: _viewNotifier,
      builder: (context, viewState, _) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DeliveryConstants.radiusXl),
          ),
          child: Container(
            width: 600,
            constraints: const BoxConstraints(maxHeight: 800),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(DeliveryConstants.spacingXl),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: DeliveryConstants.borderColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Add Driver',
                        style: DeliveryConstants.headingMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(DeliveryConstants.spacingXl),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: _buildPhotoUpload()),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  'Driver Name *',
                                  _nameController,
                                  'Enter full name',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  'Phone Number *',
                                  _phoneController,
                                  '+61 4XX XXX XXX',
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Vehicle Type *',
                            style: DeliveryConstants.labelMedium,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildVehicleOption(
                                  icon: Icons.pedal_bike,
                                  label: 'Bike',
                                  isSelected: viewState.selectedVehicle ==
                                      VehicleType.bike,
                                  onTap: () => _updateState(
                                    viewState.copyWith(
                                      selectedVehicle: VehicleType.bike,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildVehicleOption(
                                  icon: Icons.directions_car,
                                  label: 'Car',
                                  isSelected: viewState.selectedVehicle ==
                                      VehicleType.car,
                                  onTap: () => _updateState(
                                    viewState.copyWith(
                                      selectedVehicle: VehicleType.car,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildVehicleOption(
                                  icon: Icons.electric_scooter,
                                  label: 'Scooter',
                                  isSelected: viewState.selectedVehicle ==
                                      VehicleType.scooter,
                                  onTap: () => _updateState(
                                    viewState.copyWith(
                                      selectedVehicle: VehicleType.scooter,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildVehicleOption(
                                  icon: Icons.local_shipping,
                                  label: 'Van',
                                  isSelected: viewState.selectedVehicle ==
                                      VehicleType.van,
                                  onTap: () => _updateState(
                                    viewState.copyWith(
                                      selectedVehicle: VehicleType.van,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Login Credentials',
                            style: DeliveryConstants.headingSmall,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  'Username',
                                  _usernameController,
                                  'Auto-generated or custom',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  'Password',
                                  _passwordController,
                                  'auto-generated-123',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Credentials will be sent to the driver via SMS. They can change their password later.',
                            style: DeliveryConstants.caption,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Driver Role',
                            style: DeliveryConstants.labelMedium,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: viewState.selectedRole,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: DeliveryConstants.dividerColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  DeliveryConstants.radiusMd,
                                ),
                                borderSide: const BorderSide(
                                  color: DeliveryConstants.borderColor,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: const [
                              'Self-managed',
                              'Company',
                              'Partner',
                              'Contractor',
                            ].map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                _updateState(
                                  viewState.copyWith(selectedRole: value),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Zone Assignment',
                            style: DeliveryConstants.labelMedium,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: DeliveryConstants.dividerColor,
                              hintText: 'Select delivery zones',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  DeliveryConstants.radiusMd,
                                ),
                                borderSide: const BorderSide(
                                  color: DeliveryConstants.borderColor,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: const [
                              'Downtown',
                              'Uptown',
                              'Suburbs',
                              'CBD',
                              'All Zones',
                            ].map((zone) {
                              return DropdownMenuItem(
                                value: zone,
                                child: Text(zone),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null &&
                                  !viewState.selectedZones.contains(value)) {
                                final updatedZones =
                                    List<String>.from(viewState.selectedZones)
                                      ..add(value);
                                _updateState(
                                  viewState.copyWith(
                                      selectedZones: updatedZones),
                                );
                              }
                            },
                          ),
                          if (viewState.selectedZones.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: viewState.selectedZones.map((zone) {
                                return Chip(
                                  label: Text(zone),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    final updatedZones = List<String>.from(
                                        viewState.selectedZones)
                                      ..remove(zone);
                                    _updateState(
                                      viewState.copyWith(
                                        selectedZones: updatedZones,
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 8),
                          const Text(
                            'Drivers will receive orders primarily from their assigned zones',
                            style: DeliveryConstants.caption,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(
                                  DeliveryConstants.radiusLg),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Quick Setup Options',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E40AF),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                CheckboxListTile(
                                  value: viewState.sendWelcomeSms,
                                  onChanged: (val) {
                                    if (val != null) {
                                      _updateState(
                                        viewState.copyWith(
                                          sendWelcomeSms: val,
                                        ),
                                      );
                                    }
                                  },
                                  title: const Text(
                                    'Send welcome SMS with login details',
                                    style: DeliveryConstants.bodyMedium,
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: const Color(0xFF8B5CF6),
                                ),
                                CheckboxListTile(
                                  value: viewState.enableGpsTracking,
                                  onChanged: (val) {
                                    if (val != null) {
                                      _updateState(
                                        viewState.copyWith(
                                          enableGpsTracking: val,
                                        ),
                                      );
                                    }
                                  },
                                  title: const Text(
                                    'Enable GPS tracking',
                                    style: DeliveryConstants.bodyMedium,
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: const Color(0xFF8B5CF6),
                                ),
                                CheckboxListTile(
                                  value: viewState.allowCashPayments,
                                  onChanged: (val) {
                                    if (val != null) {
                                      _updateState(
                                        viewState.copyWith(
                                          allowCashPayments: val,
                                        ),
                                      );
                                    }
                                  },
                                  title: const Text(
                                    'Allow cash payments',
                                    style: DeliveryConstants.bodyMedium,
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: const Color(0xFF8B5CF6),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(DeliveryConstants.spacingXl),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: DeliveryConstants.borderColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(
                              color: DeliveryConstants.borderColor,
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _saveDriver(viewState),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF97316),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Save Driver'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoUpload() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: DeliveryConstants.dividerColor,
            borderRadius: BorderRadius.circular(DeliveryConstants.radiusLg),
            border: Border.all(
              color: DeliveryConstants.borderColor,
              style: BorderStyle.solid,
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.person,
            size: 48,
            color: DeliveryConstants.textTertiary,
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photo upload - Coming soon'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.upload, size: 16),
          label: const Text('Upload Photo'),
        ),
        const Text(
          'Recommended: Square image, 200x200px minimum',
          style: DeliveryConstants.caption,
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DeliveryConstants.labelMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: DeliveryConstants.dividerColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DeliveryConstants.radiusMd),
              borderSide: const BorderSide(
                color: DeliveryConstants.borderColor,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (label.contains('*') && (value == null || value.isEmpty)) {
              return 'Required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildVehicleOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DeliveryConstants.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEFF6FF)
              : DeliveryConstants.dividerColor,
          borderRadius: BorderRadius.circular(DeliveryConstants.radiusLg),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : DeliveryConstants.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? const Color(0xFF3B82F6)
                  : DeliveryConstants.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : DeliveryConstants.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveDriver(_AddDriverViewState viewState) {
    if (_formKey.currentState!.validate() &&
        viewState.selectedVehicle != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Driver ${_nameController.text} added successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (viewState.selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a vehicle type'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
