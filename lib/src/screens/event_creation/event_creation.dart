import 'package:compete_hub/core/utils/app_colors.dart';
import 'package:compete_hub/src/models/event.dart';
import 'package:compete_hub/src/models/event_category.dart'
    as categories; // Add prefix
import 'package:compete_hub/src/providers/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../providers/auth_provider.dart';

class EventCreation extends StatefulWidget {
  const EventCreation({super.key});

  @override
  State<EventCreation> createState() => _EventCreationState();
}

class _EventCreationState extends State<EventCreation> {
  final _pageController = PageController();
  final List<GlobalKey<FormState>> _formKeys =
      List.generate(3, (_) => GlobalKey<FormState>());
  int _currentPage = 0;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _organizerInfoController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _entryFeeController = TextEditingController();
  final _eligibilityRulesController = TextEditingController();
  final _organizerWhatsAppController = TextEditingController();
  final _organizerEmailController = TextEditingController();
  final _bankDetailsController = TextEditingController();

  DateTime _startDateTime = DateTime.now();
  DateTime _endDateTime = DateTime.now().add(const Duration(hours: 2));
  DateTime _entryDeadline = DateTime.now();
  TournamentFormat _format = TournamentFormat.singleElimination;
  EventVisibility _visibility = EventVisibility.public;
  bool _isLoading = false;

  EventLocationType _locationType = EventLocationType.offline;
  EventFeeType _feeType = EventFeeType.free;
  categories.EventCategory _category =
      categories.EventCategory.games; // Update with prefix

  File? _bannerImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _bannerImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_formKeys[_currentPage].currentState?.validate() ?? false) {
      if (_currentPage < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() => _currentPage++);
      } else {
        _submitForm();
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  InputDecoration _getInputDecoration(String label, {String? hintText}) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      labelStyle: TextStyle(color: Colors.white),
      hintStyle: TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.deepPurple.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 2),
      ),
      floatingLabelStyle: TextStyle(color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.lightPrimary,
        title: const Text('Create Event'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / 3,
            backgroundColor: Colors.grey[300],
            color: Colors.deepPurple.shade400,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBasicInfoPage(),
                _buildDateTimePage(),
                _buildSettingsPage(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[0],
        child: Column(
          children: [
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _bannerImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _bannerImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_photo_alternate,
                              size: 50, color: Colors.white70),
                          SizedBox(height: 8),
                          Text('Add Event Banner',
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<categories.EventCategory>(
              // Update with prefix
              value: _category,
              decoration: _getInputDecoration('Event Category'),
              dropdownColor: Colors.deepPurple.shade300,
              style: TextStyle(color: Colors.white),
              items: categories.EventCategory.values.map((category) {
                // Update with prefix
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(category.icon, color: Colors.white),
                      SizedBox(width: 8),
                      Text(category.toString().split('.').last),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: _getInputDecoration('Event Name'),
              style: TextStyle(color: Colors.white),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter event name' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: _getInputDecoration('Description'),
              style: TextStyle(color: Colors.white),
              maxLines: 3,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter description' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EventLocationType>(
              value: _locationType,
              decoration: _getInputDecoration('Location Type'),
              dropdownColor: Colors.deepPurple.shade300,
              style: TextStyle(color: Colors.white),
              items: EventLocationType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _locationType = value);
              },
            ),
            if (_locationType == EventLocationType.offline) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: _getInputDecoration('Venue Location'),
                style: TextStyle(color: Colors.white),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter location' : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[1],
        child: Column(
          children: [
            _buildDateTimePicker(
              label: 'Start Date & Time',
              value: _startDateTime,
              onChanged: (date) => setState(() => _startDateTime = date),
            ),
            const SizedBox(height: 16),
            _buildDateTimePicker(
              label: 'End Date & Time',
              value: _endDateTime,
              onChanged: (date) => setState(() => _endDateTime = date),
            ),
            const SizedBox(height: 16),
            _buildDateTimePicker(
              label: 'Entry Deadline',
              value: _entryDeadline,
              onChanged: (date) => setState(() => _entryDeadline = date),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[2],
        child: Column(
          children: [
            DropdownButtonFormField<TournamentFormat>(
              value: _format,
              decoration: _getInputDecoration('Tournament Format'),
              dropdownColor: Colors.deepPurple.shade300,
              style: TextStyle(color: Colors.white),
              items: TournamentFormat.values.map((format) {
                return DropdownMenuItem(
                  value: format,
                  child: Text(format.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _format = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _organizerInfoController,
              decoration: _getInputDecoration('Organizer Info'),
              style: TextStyle(color: Colors.white),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter organizer info' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxParticipantsController,
              decoration: _getInputDecoration('Max Participants'),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true)
                  return 'Please enter max participants';
                if (int.tryParse(value!) == null)
                  return 'Please enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EventFeeType>(
              value: _feeType,
              decoration: _getInputDecoration('Entry Fee Type'),
              dropdownColor: Colors.deepPurple.shade300,
              style: TextStyle(color: Colors.white),
              items: EventFeeType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _feeType = value);
              },
            ),
            if (_feeType == EventFeeType.paid) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _entryFeeController,
                decoration: _getInputDecoration('Entry Fee Amount'),
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter fee amount';
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _organizerWhatsAppController,
                decoration: _getInputDecoration('WhatsApp Number'),
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter WhatsApp number'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _organizerEmailController,
                decoration: _getInputDecoration('Email'),
                validator: (value) =>
                    !value!.contains('@') ? 'Enter valid email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bankDetailsController,
                decoration: _getInputDecoration('Bank Details'),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter bank details' : null,
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _eligibilityRulesController,
              decoration: _getInputDecoration('Eligibility Rules',
                  hintText: 'Optional'),
              style: TextStyle(color: Colors.white),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EventVisibility>(
              value: _visibility,
              decoration: _getInputDecoration('Event Visibility'),
              dropdownColor: Colors.deepPurple.shade300,
              style: TextStyle(color: Colors.white),
              items: EventVisibility.values.map((visibility) {
                return DropdownMenuItem(
                  value: visibility,
                  child: Text(visibility.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _visibility = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            ElevatedButton(
              onPressed: _previousPage,
              child: const Text('Previous'),
            )
          else
            const SizedBox(),
          ElevatedButton(
            onPressed: _isLoading ? null : _nextPage,
            child: _isLoading
                ? const CircularProgressIndicator()
                : Text(_currentPage == 2 ? 'Create Event' : 'Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime value,
    required Function(DateTime) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.deepPurple.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          value.toString(),
          style: const TextStyle(color: Colors.white70),
        ),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: value,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(value),
            );
            if (time != null) {
              onChanged(DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              ));
            }
          }
        },
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKeys[_currentPage].currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Validate required fields for paid events
      if (_feeType == EventFeeType.paid) {
        if (_organizerWhatsAppController.text.isEmpty ||
            _organizerEmailController.text.isEmpty ||
            _bankDetailsController.text.isEmpty ||
            _entryFeeController.text.isEmpty) {
          throw Exception('All payment details are required for paid events');
        }
      }

      String? bannerUrl;
      if (_bannerImage != null) {
        bannerUrl = await Provider.of<EventProvider>(context, listen: false)
            .uploadEventBanner(_bannerImage!);
      }

      // Create and submit event
      final event = Event(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        startDateTime: _startDateTime,
        endDateTime: _endDateTime,
        locationType: _locationType,
        location: _locationType == EventLocationType.online
            ? null
            : _locationController.text.trim(),
        organizerInfo: _organizerInfoController.text.trim(),
        format: _format,
        maxParticipants: int.parse(_maxParticipantsController.text),
        feeType: _feeType,
        entryFee: _feeType == EventFeeType.free
            ? 0
            : double.parse(_entryFeeController.text),
        entryDeadline: _entryDeadline,
        eligibilityRules: _eligibilityRulesController.text.isEmpty
            ? null
            : _eligibilityRulesController.text.trim(),
        visibility: _visibility,
        category: _category,
        organizerId: Provider.of<AuthProviders>(context, listen: false)
                .currentUser
                ?.uid ??
            '',
        organizerWhatsApp: _feeType == EventFeeType.paid
            ? _organizerWhatsAppController.text.trim()
            : '',
        organizerEmail: _feeType == EventFeeType.paid
            ? _organizerEmailController.text.trim()
            : '',
        bankDetails: _feeType == EventFeeType.paid
            ? _bankDetailsController.text.trim()
            : '',
        bannerImageUrl: bannerUrl,
      );

      await Provider.of<EventProvider>(context, listen: false)
          .createEvent(event);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      throw Exception('Failed to create event: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
