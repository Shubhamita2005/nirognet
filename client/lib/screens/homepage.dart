// lib/screens/homepage.dart
import 'package:flutter/material.dart';

// ✅ CHANGED: Converted to a StatelessWidget
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ✅ KEPT: This is needed by your UI
  static const Color _emergencyShadowColor = Color.fromARGB(255, 255, 0, 0);

  // ❌ REMOVED: _selectedIndex, _onItemTapped, _buildBottomNavigationBar, _buildNavBarItem

  @override
  Widget build(BuildContext context) {
    // ✅ CHANGED: Removed the Scaffold and bottomNavigationBar.
    // We are now returning the SingleChildScrollView directly.
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom App Bar / Header Section
          _buildHeader(context),
          const SizedBox(height: 16),

          // Daily Health Tips Card
          _buildDailyHealthTipsCard(context),
          const SizedBox(height: 24),

          // Health Summary Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning, Guest ! 👋',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Here's your health summary",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
                Text(
                  '10/9/2025\n11:11 am',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Recent Medicines & Health Symptoms Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRecentMedicinesCard(context),
                const SizedBox(width: 16), // Spacing between cards
                _buildHealthSymptomsCard(context),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Doctor Consultations Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildDoctorConsultationsCard(context),
          ),
          const SizedBox(height: 20),

          // Find Hospital & Emergency Services Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // Placeholder for map image
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.location_on,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Find Hospital Button
                      // Consider making this an ElevatedButton or OutlinedButton
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.teal),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.teal.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'FIND HOSPITAL',
                              style: TextStyle(
                                color: Colors.teal.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/emergency_assistant');
                      debugPrint('Emergency Services Tapped!');
                      // TODO: Implement emergency action (e.g., call, show contacts)
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Emergency Button (Red Circle)
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.red.shade700,
                                Colors.red.shade900,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _emergencyShadowColor.withAlpha(
                                  (255 * 0.4).round(),
                                ),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.medical_services_outlined,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Emergency\nServices', // Added newline for better fit
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: 15,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- All your helper methods remain the same ---

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16.0,
        MediaQuery.of(context).padding.top + 10,
        16.0,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Namaste Guest', // Consider fetching user name
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Kolkata 700025', // Consider making this dynamic or selectable
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      size: 28,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      debugPrint('Notifications tapped!');
                      // TODO: Navigate to Notifications screen
                    },
                  ),
                  Positioned(
                    // Consider showing count instead of just dot
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.person_outline,
                  size: 28,
                  color: Colors.black87,
                ),
                onPressed: () {
                  // ✅ Navigate to the profile route
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyHealthTipsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.lightBlue.shade200,
          width: 1,
        ), // Reduced border width
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1, // Reduced spread
            blurRadius: 4, // Reduced blur
            offset: const Offset(0, 2), // Reduced offset
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.orange.shade700,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'DAILY HEALTH TIPS',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            // Consider fetching tips dynamically
            'Stay hydrated! Drinking water first thing in the morning helps kickstart your metabolism and flush out toxins.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              // color: Colors.red.shade700, // Changed color for readability
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMedicinesCard(BuildContext context) {
    // This assumes fixed data. In a real app, fetch this.
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.medical_services_outlined,
                  color: Colors.black87,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Medicines', // Corrected typo
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildMedicineItem(context, 'Paracetamol (Crocin)', '15/1/2024'),
            _buildMedicineItem(context, 'Amoxicillin (Novamox)', '10/1/2024'),
            _buildMoreText(context, '+2 more'),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineItem(BuildContext context, String name, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$name\n$date',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black87,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSymptomsCard(BuildContext context) {
    // This assumes fixed data. In a real app, fetch this.
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: Colors.black87, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Health Symptoms',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildSymptomItem(
              context,
              'Headache and fever',
              '15/1/2024',
              'Resolved', // Capitalized
              Colors.green.shade600,
            ),
            _buildSymptomItem(
              context,
              'Cough', // Changed example symptom
              '25/10/2025', // Updated date
              'Improving',
              Colors.orange.shade700, // Changed color for 'Improving'
            ),
            _buildMoreText(context, '+1 more'), // Updated count
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomItem(
    BuildContext context,
    String name,
    String date,
    String status,
    Color statusColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black87,
                  fontSize: 11,
                ),
                children: [
                  TextSpan(text: '$name\n$date • '),
                  TextSpan(
                    text: status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorConsultationsCard(BuildContext context) {
    // This assumes fixed data. In a real app, fetch this.
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin, color: Colors.black87, size: 20),
              const SizedBox(width: 8),
              Text(
                'Doctor Consultations',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildConsultationItem(
            context,
            'Dr. Rajesh Kumar',
            '21/9/2025',
            'Upcoming',
            Colors.blue.shade600, // Changed color for 'Upcoming'
          ),
          _buildConsultationItem(
            context,
            'Dr. Priya Sharma',
            '15/1/2024',
            'Completed',
            Colors.green.shade600,
          ),
          _buildMoreText(context, '+0 more'), // Updated count
        ],
      ),
    );
  }

  Widget _buildConsultationItem(
    BuildContext context,
    String name,
    String date,
    String status,
    Color statusColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black87,
                  fontSize: 11,
                ),
                children: [
                  TextSpan(text: '$name\n$date • '),
                  TextSpan(
                    text: status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreText(BuildContext context, String text) {
    // Consider making this tappable to navigate to a full list
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, right: 4.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
