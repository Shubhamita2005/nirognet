import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/doctor.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback? onBook;
  final bool isBooking;

  const DoctorCard({
    super.key,
    required this.doctor,
    this.onBook,
    this.isBooking = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =========================
          // DOCTOR NAME
          // =========================
          Text(
            doctor.name,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blueAccent,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            "Available for consultation",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 10),

          // =========================
          // HOSPITAL
          // =========================
          Text(
            "🏥 ${doctor.hospital}",
            style: GoogleFonts.poppins(fontSize: 14),
          ),

          const SizedBox(height: 8),

          // =========================
          // SLOTS
          // =========================
          ...doctor.slots.map(
            (slot) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                "📅 ${slot['day']}   ⏰ ${slot['time']}",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // =========================
          // AVAILABILITY + BOOK BUTTON
          // =========================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                doctor.isAvailable ? "Available" : "Not Available",
                style: GoogleFonts.poppins(
                  color:
                      doctor.isAvailable ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),

              ElevatedButton(
                onPressed: doctor.isAvailable && !isBooking
                    ? onBook
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9EE3E0),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isBooking
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        "Book",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}