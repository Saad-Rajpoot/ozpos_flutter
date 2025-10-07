import 'package:flutter/material.dart';
import '../delivery_tokens.dart';

enum VehicleType { bike, car, scooter, van }

class AddDriverModal extends StatefulWidget {
  const AddDriverModal({super.key});

  @override
  State<AddDriverModal> createState() => _AddDriverModalState();
}

class _AddDriverModalState extends State<AddDriverModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  VehicleType? _selectedVehicle;
  String _selectedRole = 'Self-managed';
  final List<String> _selectedZones = [];

  bool _sendWelcomeSms = true;
  bool _enableGpsTracking = true;
  bool _allowCashPayments = false;

  @override
  void initState() {
    super.initState();
    _generateCredentials();
  }

  void _generateCredentials() {
    _usernameController.text = 'Auto-generated or custom';
    _passwordController.text = 'auto-generated-123';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DeliveryTokens.radiusXl),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(DeliveryTokens.spacingXl),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: DeliveryTokens.borderColor),
                ),
              ),
              child: Row(
                children: [
                  const Text('Add Driver', style: DeliveryTokens.headingMedium),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(DeliveryTokens.spacingXl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo upload
                      Center(child: _buildPhotoUpload()),
                      const SizedBox(height: 24),

                      // Driver Name & Phone
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

                      // Vehicle Type
                      const Text(
                        'Vehicle Type *',
                        style: DeliveryTokens.labelMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildVehicleOption(
                              VehicleType.bike,
                              Icons.pedal_bike,
                              'Bike',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildVehicleOption(
                              VehicleType.car,
                              Icons.directions_car,
                              'Car',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildVehicleOption(
                              VehicleType.scooter,
                              Icons.electric_scooter,
                              'Scooter',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildVehicleOption(
                              VehicleType.van,
                              Icons.local_shipping,
                              'Van',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Login Credentials
                      const Text(
                        'Login Credentials',
                        style: DeliveryTokens.headingSmall,
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
                        style: DeliveryTokens.caption,
                      ),
                      const SizedBox(height: 24),

                      // Driver Role
                      const Text(
                        'Driver Role',
                        style: DeliveryTokens.labelMedium,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedRole,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: DeliveryTokens.dividerColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              DeliveryTokens.radiusMd,
                            ),
                            borderSide: const BorderSide(
                              color: DeliveryTokens.borderColor,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items:
                            [
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
                        onChanged: (value) =>
                            setState(() => _selectedRole = value!),
                      ),
                      const SizedBox(height: 24),

                      // Zone Assignment
                      const Text(
                        'Zone Assignment',
                        style: DeliveryTokens.labelMedium,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: DeliveryTokens.dividerColor,
                          hintText: 'Select delivery zones',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              DeliveryTokens.radiusMd,
                            ),
                            borderSide: const BorderSide(
                              color: DeliveryTokens.borderColor,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items:
                            [
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
                              !_selectedZones.contains(value)) {
                            setState(() => _selectedZones.add(value));
                          }
                        },
                      ),
                      if (_selectedZones.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedZones
                              .map(
                                (zone) => Chip(
                                  label: Text(zone),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () => setState(
                                    () => _selectedZones.remove(zone),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 8),
                      const Text(
                        'Drivers will receive orders primarily from their assigned zones',
                        style: DeliveryTokens.caption,
                      ),
                      const SizedBox(height: 24),

                      // Quick Setup Options
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(
                            DeliveryTokens.radiusLg,
                          ),
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
                              value: _sendWelcomeSms,
                              onChanged: (val) =>
                                  setState(() => _sendWelcomeSms = val!),
                              title: const Text(
                                'Send welcome SMS with login details',
                                style: DeliveryTokens.bodyMedium,
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              activeColor: const Color(0xFF8B5CF6),
                            ),
                            CheckboxListTile(
                              value: _enableGpsTracking,
                              onChanged: (val) =>
                                  setState(() => _enableGpsTracking = val!),
                              title: const Text(
                                'Enable GPS tracking',
                                style: DeliveryTokens.bodyMedium,
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              activeColor: const Color(0xFF8B5CF6),
                            ),
                            CheckboxListTile(
                              value: _allowCashPayments,
                              onChanged: (val) =>
                                  setState(() => _allowCashPayments = val!),
                              title: const Text(
                                'Allow cash payments',
                                style: DeliveryTokens.bodyMedium,
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
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

            // Footer
            Container(
              padding: const EdgeInsets.all(DeliveryTokens.spacingXl),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: DeliveryTokens.borderColor),
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
                          color: DeliveryTokens.borderColor,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveDriver,
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
  }

  Widget _buildPhotoUpload() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: DeliveryTokens.dividerColor,
            borderRadius: BorderRadius.circular(DeliveryTokens.radiusLg),
            border: Border.all(
              color: DeliveryTokens.borderColor,
              style: BorderStyle.solid,
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.person,
            size: 48,
            color: DeliveryTokens.textTertiary,
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
          style: DeliveryTokens.caption,
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
        Text(label, style: DeliveryTokens.labelMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: DeliveryTokens.dividerColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DeliveryTokens.radiusMd),
              borderSide: const BorderSide(color: DeliveryTokens.borderColor),
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

  Widget _buildVehicleOption(VehicleType type, IconData icon, String label) {
    final isSelected = _selectedVehicle == type;

    return InkWell(
      onTap: () => setState(() => _selectedVehicle = type),
      borderRadius: BorderRadius.circular(DeliveryTokens.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEFF6FF)
              : DeliveryTokens.dividerColor,
          borderRadius: BorderRadius.circular(DeliveryTokens.radiusLg),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : DeliveryTokens.borderColor,
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
                  : DeliveryTokens.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : DeliveryTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveDriver() {
    if (_formKey.currentState!.validate() && _selectedVehicle != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Driver ${_nameController.text} added successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a vehicle type'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
