// lib/main_scaffold.dart
import 'package:flutter/material.dart';

// Screens
import 'screens/homepage.dart';
import 'screens/book_consultation_page.dart';
import 'screens/medicine_availability.dart';
import 'screens/health_records_page.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health Records")),
      body: const Center(child: Text("Health Records Screen")),
    );
  }
}

class MainScaffold extends StatefulWidget {
  final String token;

  const MainScaffold({
    super.key,
    required this.token,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // Screens list (AI not included)
  late final List<Widget> _screens;
    @override
void initState() {
  super.initState();

  _screens = [
    const HomeScreen(),
    BookConsultationScreen(token: widget.token),
    MedicineAvailabilityPage(),
    const HealthRecordsPage(),
  ];
}

  void _onItemTapped(int index) {
    // AI Symptom Checker (separate route)
    if (index == 2) {
      Navigator.pushNamed(context, '/ai_symptom');
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getCurrentScreen() {
    int listIndex = _selectedIndex;

    // Adjust index because AI (2) is not in list
    if (_selectedIndex > 2) {
      listIndex = _selectedIndex - 1;
    }

    return _screens[listIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal.shade700,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: <BottomNavigationBarItem>[
          _buildNavBarItem(0, Icons.home, 'HOME'),
          _buildNavBarItem(1, Icons.calendar_month, 'Book Consultation'),
          _buildNavBarItem(2, Icons.smart_toy_outlined, 'AI Symptom Checker'),
          _buildNavBarItem(
            3,
            Icons.local_pharmacy_outlined,
            'Medicine Availability',
          ),
          _buildNavBarItem(4, Icons.description_outlined, 'Health Records'),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavBarItem(
    int index,
    IconData iconData,
    String label,
  ) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? Colors.teal.shade100
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(iconData),
      ),
      label: label,
    );
  }
}