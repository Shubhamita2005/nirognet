import 'package:flutter/material.dart';

// Custom color palette based on the image
const Color _primaryGreen = Color(0xFF4ACF9D);
const Color _darkTextColor = Color(0xFF333333);
const Color _redCapsule = Color(0xFFE53935);

/// The main login selection page widget.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ensure the background is white as per the original image/theme
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // --- Custom Logo / Icon ---
              const NirogNetLogo(),
              const SizedBox(height: 30),

              // --- App Name ---
              const Text(
                'NirogNet',
                style: TextStyle(
                  color: _primaryGreen,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),

              // --- Subtitle ---
              const Text(
                'Login as....',
                style: TextStyle(
                  color: _darkTextColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 50),

              // --- Login Buttons ---
              LoginOptionButton(
                icon: Icons.person_outline,
                iconColor: _darkTextColor,
                label: 'Patient',
                onTap: () {
                  // ✅ --- CORRECTED NAVIGATION ---
                  // Navigates to the '/main' route (MainScaffold)
                  // and removes the login screen from history.
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/main',
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 20),

              LoginOptionButton(
                icon: Icons.medication_outlined,
                iconColor: _redCapsule,
                label: 'Pharmacy',
                onTap: () {
                  // TODO: Navigate to Pharmacy login page
                  debugPrint('Pharmacy selected');
                },
              ),
              const SizedBox(height: 20),

              LoginOptionButton(
                // Used a more appropriate icon for Doctor
                icon: Icons.medical_services_outlined,
                iconColor: Colors.blue.shade700,
                label: 'Doctor',
                onTap: () {
                  // TODO: Navigate to Doctor login page
                  debugPrint('Doctor selected');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A custom widget to represent the stylized pill/clock logo.
class NirogNetLogo extends StatelessWidget {
  const NirogNetLogo({super.key});

  @override
  Widget build(BuildContext context) {
    const double logoWidth = 180;
    const double logoHeight = 80;
    const double capsuleRadius = logoHeight / 2;

    return Container(
      width: logoWidth,
      height: logoHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(capsuleRadius),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(capsuleRadius),
        child: Stack(
          children: [
            // Left (Teal) half of the capsule
            Container(
              width:
                  logoWidth / 2 +
                  capsuleRadius / 2, // Slight overlap for rounded effect
              decoration: const BoxDecoration(
                color: _primaryGreen,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(capsuleRadius),
                  bottomLeft: Radius.circular(capsuleRadius),
                ),
              ),
            ),
            // Clock hands (positioned centrally)
            Positioned.fill(
              child: Center(
                child: CustomPaint(
                  painter: ClockHandPainter(),
                  size: const Size(logoWidth, logoHeight),
                ),
              ),
            ),
            // Dots on the pill edge
            const Positioned(
              top: 10,
              left: 10,
              child: CircleAvatar(radius: 3, backgroundColor: Colors.black),
            ),
            const Positioned(
              bottom: 10,
              left: 10,
              child: CircleAvatar(radius: 3, backgroundColor: Colors.black),
            ),
            const Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(radius: 3, backgroundColor: Colors.black),
            ),
            const Positioned(
              bottom: 10,
              right: 10,
              child: CircleAvatar(radius: 3, backgroundColor: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter to draw the stylized clock hands.
class ClockHandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Center dot
    canvas.drawCircle(center, 4, paint);

    // Hour hand (approx. pointing to 2 o'clock)
    canvas.drawLine(center, center + const Offset(15, -25), paint);

    // Minute hand (approx. pointing to 4 o'clock)
    canvas.drawLine(center, center + const Offset(25, 10), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Reusable button component for login options.
class LoginOptionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const LoginOptionButton({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4), // subtle shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: <Widget>[
              // Icon
              Icon(icon, color: iconColor, size: 30),
              const SizedBox(width: 15),
              // Label
              Text(
                label,
                style: const TextStyle(
                  color: _darkTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}