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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  late TabController _tabController;
  event_category.EventCategory? _selectedCategory;

  Future<void> _checkConnectivity() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    _updateConnectionStatus(connectivityResults.first);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      _isOnline = result != ConnectivityResult.none;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeTabController();
    _checkConnectivity();
    _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results.first);
    });
  }

  void _initializeTabController() {
    _tabController = TabController(
      length: event_category.EventCategory.values.length + 1,
      vsync: this,
    );
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedCategory = _tabController.index == 0
            ? null
            : event_category.EventCategory.values[_tabController.index - 1];
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          dividerColor: Colors.grey.shade900,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade600,
          tabs: [
            const Tab(text: 'All'),
            ...event_category.EventCategory.values.map((category) {
              return Tab(
                text: category.toString().split('.').last,
              );
            }).toList(),
          ],
        ),
      ),
      body: Column(
        children: [
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
                      padding: const EdgeInsets.only(left: 10, right: 10,),
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
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    if (eventProvider.isEventOrganizer(event.organizerId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot register for your own event'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
                    registrationId: registrationId['id'] as String,
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
