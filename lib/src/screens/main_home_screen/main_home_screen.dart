import 'package:compete_hub/core/utils/app_colors.dart';
import 'package:compete_hub/src/screens/Discover_Page/discover_page.dart';
import 'package:compete_hub/src/screens/event_creation/event_creation.dart';
import 'package:compete_hub/src/screens/home_screen/home_screen.dart';
import 'package:compete_hub/src/screens/my_event_page/my_event_page.dart';
import 'package:compete_hub/src/screens/profile_page/profile_page.dart';
import 'package:flutter/material.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  _MainHomeScreenState createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  // Index for the currently selected screen
  int _selectedIndex = 0;

  // List of screens corresponding to the navigation items
  final List<Widget> _screens = [
    const HomeScreen(),
    // Replace with your actual Home page
    const DiscoverPage(),
    // Replace with your actual Discover page
    const EventCreation(),
    //This is a placeholder, because the button is in the center, not a page.
    const MyEventPage(),
    // Replace with your actual My Events page
    const ProfilePage(),
    // Replace with your actual Profile page
  ];

  // Function to handle item selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display the selected screen
      backgroundColor:  AppColors.lightPrimary,
      body: _screens[_selectedIndex],
      // Bottom navigation bar
      bottomNavigationBar: SizedBox(
        height: 90,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top:  Radius.circular(20)),
          child: BottomAppBar(
            color: Colors.grey.shade900,
            shape: const CircularNotchedRectangle(),
            // Shape for the floating button
            notchMargin: 8.0,
            // Space between the bar and the floating button
            clipBehavior: Clip.hardEdge,
            child: BottomNavigationBar(
              backgroundColor: Colors.grey.shade900.withOpacity(0.1),
              // Background color of the bottom bar
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Discover',
                ),
                // Empty item for the placeholder - the button goes here
                BottomNavigationBarItem(
                  icon: Icon(null),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event),
                  label: 'My Events',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blue,
              // Color for the selected item
              unselectedItemColor: Colors.grey,
              // Color for unselected items
              onTap: _onItemTapped,
              //remove the labels.
              showSelectedLabels: false,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed, //makes the bottom bar fixed
            ),
          ),
        ),
      ),
      // Floating action button for the center item
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle the action for the center button (e.g., navigate to a new page)
          // ignore: avoid_print
          print('Center button pressed');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  const EventCreation(), // Replace with your actual Center page
            ),
          );
        },
        //tooltip: 'Create Event', // Tooltip for the button
        shape: const CircleBorder(),
        backgroundColor: Colors.blue,
        // Background color of the button
        foregroundColor: Colors.white,
        elevation: 5.0,
        child: const Icon(Icons.add), // Icon for the button
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked, // Position the button
    );
  }
}

