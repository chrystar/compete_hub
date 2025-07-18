import 'package:flutter/material.dart';
import '../../../core/utils/app_colors.dart';
import '../models/event.dart';

class RegistrationForm extends StatefulWidget {
  final Event event;
  final Function(Map<String, String> formData) onSubmit;

  const RegistrationForm({
    super.key,
    required this.event,
    required this.onSubmit,
  });

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _formData = <String, String>{};
  String _selectedGender = 'Male';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      color: colorScheme.background,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Registration Details',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Full Name',
              onSaved: (v) => _formData['fullName'] = v ?? '',
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              label: 'Email',
              onSaved: (v) => _formData['email'] = v ?? '',
              validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
              keyboardType: TextInputType.emailAddress,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              label: 'Phone',
              onSaved: (v) => _formData['phone'] = v ?? '',
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              keyboardType: TextInputType.phone,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                labelText: 'Gender',
                labelStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
                ),
              ),
              dropdownColor: colorScheme.surface,
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
              items: ['Male', 'Female']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedGender = v ?? 'Male'),
              onSaved: (v) => _formData['gender'] = v ?? 'Male',
            ),
            const SizedBox(height: 8),
            _buildTextField(
              label: 'Location',
              onSaved: (v) => _formData['location'] = v ?? '',
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 16),
            if (widget.event.feeType == EventFeeType.paid)
              Text(
                'Entry Fee: \$${widget.event.entryFee}',
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.primary, fontSize: 16),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _submit,
                child: Text(
                  widget.event.feeType == EventFeeType.paid
                      ? 'Continue to Payment'
                      : 'Register',
                  style: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
        ),
      ),
      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
      onSaved: onSaved,
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      widget.onSubmit(_formData);
    }
  }
}
