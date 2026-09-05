import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../models/doctor.dart';
import 'doctor_slots_page.dart';

class SpecialtyDoctorsScreen extends StatefulWidget {
  final int specialtyId;
  final String specialtyName;
  final String token;

  const SpecialtyDoctorsScreen({
    super.key,
    required this.specialtyId,
    required this.specialtyName,
    required this.token,
  });

  @override
  State<SpecialtyDoctorsScreen> createState() =>
      _SpecialtyDoctorsScreenState();
}

class _SpecialtyDoctorsScreenState
    extends State<SpecialtyDoctorsScreen> {
  List<Doctor> doctors = [];
  List<Doctor> filteredDoctors = [];

  bool isLoading = true;

  final TextEditingController searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  // =========================
  // FETCH DOCTORS (MERGED)
  // =========================
  Future<void> fetchDoctors() async {
    try {
      final url = Uri.parse(
        "http://10.0.2.2:5000/api/specialties/${widget.specialtyId}/doctors",
      );

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List<dynamic> data = [];

        if (decoded is List) {
          data = decoded;
        } else {
          data = decoded["doctors"] ?? [];
        }

        final Map<int, Doctor> doctorMap = {};

        for (var item in data) {
          final doctor = Doctor.fromJson(item);

          if (doctorMap.containsKey(doctor.id)) {
            doctorMap[doctor.id]!.slots.addAll(doctor.slots);
          } else {
            doctorMap[doctor.id] = doctor;
          }
        }

        final parsedDoctors = doctorMap.values.toList();

        setState(() {
          doctors = parsedDoctors;
          filteredDoctors = parsedDoctors;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  // =========================
  // SEARCH
  // =========================
  void filterDoctors(String query) {
    final q =
        query.toLowerCase().replaceAll("dr ", "").trim();

    setState(() {
      filteredDoctors = doctors.where((doc) {
        return doc.name
            .toLowerCase()
            .replaceAll("dr ", "")
            .contains(q);
      }).toList();
    });
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.specialtyName,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // SEARCH BAR
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF9EE3E0),
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: filterDoctors,
                      decoration: InputDecoration(
                        hintText: "Search doctor...",
                        hintStyle:
                            GoogleFonts.poppins(),
                        prefixIcon:
                            const Icon(Icons.search),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                // DOCTOR LIST
                Expanded(
                  child: filteredDoctors.isEmpty
                      ? const Center(
                          child:
                              Text("No doctors found"),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.all(16),
                          itemCount:
                              filteredDoctors.length,
                          itemBuilder:
                              (context, index) {
                            final doctor =
                                filteredDoctors[index];

                            final availableDays =
                                doctor.slots
                                    .map((slot) =>
                                        slot['day']
                                            .toString())
                                    .toSet()
                                    .join(', ');

                            final availableTimes =
                                doctor.slots
                                    .map((slot) =>
                                        slot['time']
                                            .toString())
                                    .toSet()
                                    .join(', ');

                            return Container(
                              margin:
                                  const EdgeInsets.only(
                                      bottom: 16),
                              padding:
                                  const EdgeInsets.all(
                                      16),
                              decoration:
                                  BoxDecoration(
                                color: const Color(
                                    0xFFF5F5F5),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            20),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    doctor.name,
                                    style:
                                        GoogleFonts
                                            .poppins(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                      color: Colors
                                          .blue,
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 4),
                                  Text(
                                    "Available for consultation",
                                    style:
                                        GoogleFonts
                                            .poppins(
                                      fontSize: 13,
                                      color: Colors
                                          .black54,
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 10),
                                  Text(
                                      "🏥 ${doctor.hospital}"),
                                  Text(
                                      "📅 $availableDays"),
                                  Text(
                                      "⏰ $availableTimes"),
                                  const SizedBox(
                                      height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      Text(
                                        doctor.isAvailable
                                            ? "Available"
                                            : "Not Available",
                                        style:
                                            GoogleFonts
                                                .poppins(
                                          color: doctor
                                                  .isAvailable
                                              ? Colors
                                                  .green
                                              : Colors
                                                  .red,
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: doctor
                                                .isAvailable
                                            ? () {
                                                Navigator
                                                    .push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (_) =>
                                                            DoctorSlotsPage(
                                                      doctor:
                                                          doctor,
                                                      token:
                                                          widget.token,
                                                    ),
                                                  ),
                                                );
                                              }
                                            : null,
                                        style:
                                            ElevatedButton
                                                .styleFrom(
                                          backgroundColor:
                                              const Color(
                                                  0xFF9EE3E0),
                                          foregroundColor:
                                              Colors
                                                  .black,
                                        ),
                                        child: const Text(
                                            "Book"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}