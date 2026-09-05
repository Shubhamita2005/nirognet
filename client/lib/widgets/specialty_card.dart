import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/specialty.dart';

class SpecialtyCard extends StatelessWidget {
  final Specialty specialty;
  final VoidCallback onTap;

  const SpecialtyCard({
    super.key,
    required this.specialty,
    required this.onTap,
  });

  // =========================
  // ICON MAPPING
  // =========================
  IconData getIcon(String name) {
    switch (name.toLowerCase()) {
      case "cardiology":
        return Icons.favorite;
      case "dermatology":
        return Icons.spa;
      case "orthopedics":
        return Icons.accessibility_new;
      case "neurology":
        return Icons.psychology;
      case "pediatrics":
        return Icons.child_care;
      case "gynecology":
        return Icons.female;
      case "ophthalmology":
        return Icons.remove_red_eye;
      case "psychiatry":
        return Icons.psychology_alt;
      case "dentistry":
        return Icons.medical_services;
      default:
        return Icons.local_hospital;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 12,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // =========================
              // ICON
              // =========================
              Icon(
                getIcon(specialty.name),
                size: 32,
                color: Colors.blueAccent,
              ),

              const SizedBox(height: 10),

              // =========================
              // SPECIALTY NAME
              // =========================
              Text(
                specialty.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}