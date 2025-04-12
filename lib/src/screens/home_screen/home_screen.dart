import 'package:compete_hub/core/utils/app_colors.dart';
import 'package:compete_hub/src/screens/profile_page/profile_page.dart';
import 'package:compete_hub/src/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';
import '../../widgets/event_card.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../models/event_category.dart' as event_category;
import '../../screens/event_details/event_details_screen.dart';
import '../../widgets/registration_form.dart';
import '../payment/payment_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  event_category.EventCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result.first);
    });
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.isNotEmpty) {
      _updateConnectionStatus(connectivityResult.first);
    } else {
      _updateConnectionStatus(ConnectivityResult.none);
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      _isOnline = result != ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.lightPrimary,
        automaticallyImplyLeading: false,
        title: const Text(
          'C-vents',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfilePage())),
            child: UserAvatar(
              color: const Color.fromARGB(255, 67, 81, 126),
              name: Provider.of<EventProvider>(context)
                      .currentUser
                      ?.displayName ??
                  'U',
              imageUrl:
                  Provider.of<EventProvider>(context).currentUser?.photoURL,
              size: 20,
            ),
          ),
        ),
        leadingWidth: 50,
        actionsIconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Icon(Icons.notifications, color: Colors.white),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(8),
              itemCount: event_category
                  .EventCategory.values.length, // Use prefixed version
              itemBuilder: (context, index) {
                final category = event_category
                    .EventCategory.values[index]; // Use prefixed version
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedCategory =
                          _selectedCategory == category ? null : category;
                    }),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: _selectedCategory == category
                              ? const Color.fromARGB(255, 85, 112, 201)
                              : const Color.fromARGB(255, 49, 60, 95),
                          child: Icon(
                            category.icon,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          category.toString().split('.').last,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<EventProvider>(
              builder: (context, eventProvider, child) {
                return StreamBuilder<List<Event>>(
                  stream: eventProvider.streamEvents(),
                  builder: (context, snapshot) {
                    // Add debug print for stream data
                    print('StreamBuilder received data: ${snapshot.hasData}');

                    if (snapshot.hasError) {
                      print('Stream error: ${snapshot.error}');
                      return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.white)),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      print('Stream is waiting for data');
                      return const Center(child: CircularProgressIndicator());
                    }

                    final events = snapshot.data ?? [];
                    print('Total events received: ${events.length}');
                    events.forEach((event) {
                      print('Raw Event Category: ${event.category.toString()}');
                    });

                    final filteredEvents = _selectedCategory == null
                        ? events
                        : events.where((event) {
                            // Compare just the category name
                            final eventCatName = event.category.name;
                            final selectedCatName = _selectedCategory?.name;
                            print('Comparing categories:');
                            print('Event category: $eventCatName');
                            print('Selected category: $selectedCatName');
                            return eventCatName == selectedCatName;
                          }).toList();

                    print('Filtered events count: ${filteredEvents.length}');
                    filteredEvents.forEach((event) {
                      print(
                          'Filtered Event: ${event.name}, Category: ${event.category}');
                    });

                    if (filteredEvents.isEmpty) {
                      return Center(
                        child: Text(
                          _selectedCategory == null
                              ? 'No events yet'
                              : 'No events in this category',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = filteredEvents[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailsScreen(event: event),
                            ),
                          ),
                          child: StreamBuilder<bool>(
                            stream: eventProvider
                                .isRegisteredForEventStream(event.id),
                            builder: (context, snapshot) {
                              final isRegistered = snapshot.data ?? false;
                              return EventCard(
                                event: event,
                                onRegister: isRegistered
                                    ? null
                                    : () => _registerForEvent(event),
                                isRegistered: isRegistered,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _registerForEvent(Event event) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RegistrationForm(
        event: event,
        onSubmit: (Map<String, String> formData) async {
          try {
            final registrationId =
                await Provider.of<EventProvider>(context, listen: false)
                    .registerForEvent(
              event.id,
              fullName: formData['fullName']!,
              email: formData['email']!,
              phone: formData['phone']!,
              gender: formData['gender']!,
              location: formData['location']!,
            );

            if (event.feeType == EventFeeType.paid && mounted) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(
                    event: event,
                    registrationId: registrationId,
                    onPaymentProofUploaded: (proofUrl) {
                      // Handle the uploaded payment proof URL here
                      print('Payment proof uploaded: $proofUrl');
                    },
                  ),
                ),
              );
            } else if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Successfully registered!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            // ...existing code...
          }
        },
      ),
    );
  }
}
