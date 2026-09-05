import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SlotCard extends StatelessWidget {
  final String time;
  final bool available;
  final bool isSelected;
  final VoidCallback? onTap;

  const SlotCard({
    super.key,
    required this.time,
    required this.available,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final Color borderColor;

    if (!available) {
      bgColor = Colors.grey.shade300;
      textColor = Colors.grey.shade600;
      borderColor = Colors.grey.shade400;
    } else if (isSelected) {
      bgColor = const Color(0xFF9EE3E0);
      textColor = Colors.black;
      borderColor = Colors.teal;
    } else {
      bgColor = Colors.white;
      textColor = Colors.black87;
      borderColor = Colors.black12;
    }

    return GestureDetector(
      onTap: available ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time,
              color: textColor,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              time,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              available ? "Available" : "Booked",
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}