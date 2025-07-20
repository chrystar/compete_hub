import 'package:compete_hub/core/utils/app_colors.dart';
import 'package:compete_hub/src/screens/profile_page/profile_page.dart';
import 'package:compete_hub/src/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';
import '../../widgets/event_card.dart';
import '../../models/event_category.dart' as event_category;
import '../../screens/event_details/event_details_screen.dart';
import '../../widgets/registration_form.dart';
import '../payment/payment_screen.dart';
import '../../models/registration.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  event_category.EventCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _initializeTabController();
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'C-vents',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfilePage())),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: UserAvatar(
                color: colorScheme.primary,
                name: Provider.of<EventProvider>(context)
                        .currentUser
                        ?.displayName ??
                    'U',
                imageUrl:
                    Provider.of<EventProvider>(context).currentUser?.photoURL,
                size: 18,
              ),
            ),
          ),
        ),
        leadingWidth: 56,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              dividerColor: colorScheme.outline,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              labelStyle: textTheme.labelMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: textTheme.labelMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Something went wrong',
                              style: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please try again later',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      print('Stream is waiting for data');
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        ),
                      );
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedCategory == null
                                  ? Icons.event_outlined
                                  : Icons.category_outlined,
                              size: 64,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedCategory == null
                                  ? 'No events yet'
                                  : 'No events in this category',
                              style: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Check back later for new events',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Container(
                      color: colorScheme.background,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredEvents.length,
                        itemBuilder: (context, index) {
                          final event = filteredEvents[index];
                          final userId = Provider.of<EventProvider>(context, listen: false).currentUserId;
                          return StreamBuilder<List<Registration>>(
                            stream: eventProvider.getEventRegistrations(event.id),
                            builder: (context, regSnapshot) {
                              PaymentStatus? paymentStatus;
                              Registration? reg;
                              if (regSnapshot.hasData) {
                                final regs = regSnapshot.data!;
                                for (final r in regs) {
                                  if (r.userId == userId) {
                                    reg = r;
                                    break;
                                  }
                                }
                                paymentStatus = reg?.paymentStatus;
                              }
                              final isRegistered = reg != null;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: isRegistered
                                    ? BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.lightPrimary.withOpacity(0.05),
                                            AppColors.lightPrimaryVariant.withOpacity(0.02),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      )
                                    : null,
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EventDetailsScreen(event: event),
                                    ),
                                  ),
                                  child: EventCard(
                                    event: event,
                                    onRegister: isRegistered ? null : () => _registerForEvent(event),
                                    isRegistered: isRegistered,
                                    paymentStatus: paymentStatus,
                                    registrationId: reg?.id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
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

            print('Registration successful, event feeType: ${event.feeType}');
            if (event.feeType == EventFeeType.paid && mounted) {
              print('About to pop registration modal for paid event');
              Navigator.pop(context);
              print('Modal popped, about to navigate to PaymentScreen');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(
                    event: event,
                    registrationId: registrationId['registrationId'] as String,
                    onPaymentProofUploaded: (proofUrl) {
                      print('Payment proof uploaded: $proofUrl');
                    },
                  ),
                ),
              ).then((_) => print('Returned from PaymentScreen'));
              print('Navigation to PaymentScreen triggered');
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
            print('Error during registration or navigation: $e');
          }
        },
      ),
    );
  }
}
